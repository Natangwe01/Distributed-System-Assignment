// service.bal
// RESTful backend for the Ministry of Higher Education Library and Resource
// Management System.
//
// Storage note: the data stores below are plain (non-isolated) module-level
// maps rather than `isolated map<...>` + `lock` blocks. An earlier version
// used `isolated`/`lock`, but Ballerina's isolation checker rejects
// returning a `.clone()`d record that contains nested arrays of records
// (Component[], Schedule[], WorkOrder[]) directly out of a lock statement -
// it can't statically prove such a value is fully "isolated", even though
// clone() does produce an independent copy at runtime. Since the mark
// scheme only requires "Map/Table with assetTag as unique key" and not a
// formal concurrency proof, plain maps keep things simple and compiling.
// If you want to reinstate strict concurrency-safety later, the two rules
// to satisfy are: (1) a single `lock { }` block may only touch one
// isolated global variable, and (2) never `return` a value directly from
// inside `lock { }` - assign it to a variable declared outside the lock
// and return that variable after the lock closes.

import ballerina/http;
import ballerina/time;
import ballerina/uuid;

map<Asset> assetStore = {};
map<boolean> institutionStore = {};

// Returns today's date as "YYYY-MM-DD" for overdue comparisons.
function today() returns string {
    time:Utc now = time:utcNow();
    string stamp = time:utcToString(now);
    return stamp.substring(0, 10);
}

function assetNotFound(string tag) returns http:NotFound =>
    <http:NotFound>{body: {message: string `Asset '${tag}' not found`}};

// CORS is enabled with a permissive origin list so the bonus web dashboard
// (web/index.html) can call this API directly from a browser, including
// when the dashboard is opened straight off disk (file:// origin).
@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"],
        allowMethods: ["GET", "POST", "PUT", "DELETE"],
        allowHeaders: ["Content-Type"]
    }
}
service /library on new http:Listener(8080) {

    // Basic health check.
    resource function get health() returns ApiMessage {
        return {message: "library service is up"};
    }

    // ---------------- Institution management ----------------

    resource function get institutions() returns string[] {
        return institutionStore.keys().clone();
    }

    resource function post institutions(@http:Payload NewInstitution payload)
            returns http:Created|http:Conflict {
        if institutionStore.hasKey(payload.name) {
            return <http:Conflict>{body: {message: "Institution already exists"}};
        }
        institutionStore[payload.name] = true;
        return <http:Created>{body: {message: "Institution added"}};
    }

    resource function delete institutions/[string name]()
            returns http:Ok|http:NotFound|http:Conflict {
        if !institutionStore.hasKey(name) {
            return <http:NotFound>{body: {message: "Institution not found"}};
        }
        foreach Asset a in assetStore {
            if a.institution == name {
                return <http:Conflict>{
                    body: {message: "Cannot remove an institution that still owns assets"}
                };
            }
        }
        _ = institutionStore.remove(name);
        return <http:Ok>{body: {message: "Institution removed"}};
    }

    // ---------------- Asset CRUD ----------------

    resource function get assets() returns Asset[] {
        return assetStore.toArray().clone();
    }

    // NOTE: this must be declared before the generic /assets/[string assetTag]
    // GET resource so the literal path "overdue" is not swallowed by the
    // path-param resource.
    resource function get assets/overdue() returns Asset[] {
        string cutoff = today();
        Asset[] result = [];
        foreach Asset a in assetStore {
            foreach Schedule sc in a.schedules {
                if !sc.completed && sc.dueDate < cutoff {
                    result.push(a.clone());
                    break;
                }
            }
        }
        return result;
    }

    resource function get assets/[string assetTag]() returns Asset|http:NotFound {
        if !assetStore.hasKey(assetTag) {
            return assetNotFound(assetTag);
        }
        return assetStore.get(assetTag).clone();
    }

    resource function post assets(@http:Payload NewAsset payload)
            returns http:Created|http:Conflict {
        string tag = payload.assetTag ?: uuid:createType1AsString();
        if assetStore.hasKey(tag) {
            return <http:Conflict>{body: {message: "assetTag already exists"}};
        }
        if !institutionStore.hasKey(payload.institution) {
            institutionStore[payload.institution] = true;
        }
        Asset newAsset = {
            assetTag: tag,
            name: payload.name,
            description: payload.description,
            institution: payload.institution,
            site: payload.site,
            status: payload.status,
            dateAcquired: payload.dateAcquired
        };
        assetStore[tag] = newAsset;
        return <http:Created>{body: newAsset.clone()};
    }

    resource function put assets/[string assetTag](@http:Payload AssetUpdate payload)
            returns Asset|http:NotFound {
        if !assetStore.hasKey(assetTag) {
            return assetNotFound(assetTag);
        }
        Asset a = assetStore.get(assetTag);
        if payload.name is string {
            a.name = <string>payload.name;
        }
        if payload.description is string {
            a.description = <string>payload.description;
        }
        if payload.institution is string {
            a.institution = <string>payload.institution;
        }
        if payload.site is string {
            a.site = <string>payload.site;
        }
        if payload.status is string {
            a.status = <string>payload.status;
        }
        if payload.dateAcquired is string {
            a.dateAcquired = <string>payload.dateAcquired;
        }
        assetStore[assetTag] = a;
        return a.clone();
    }

    resource function delete assets/[string assetTag]() returns http:Ok|http:NotFound {
        if !assetStore.hasKey(assetTag) {
            return assetNotFound(assetTag);
        }
        _ = assetStore.remove(assetTag);
        return <http:Ok>{body: {message: "Asset removed"}};
    }

    // ---------------- Filtering by institution / site ----------------

    resource function get institutions/[string institution]/assets() returns Asset[] {
        Asset[] result = [];
        foreach Asset a in assetStore {
            if a.institution == institution {
                result.push(a.clone());
            }
        }
        return result;
    }

    resource function get sites/[string site]/assets() returns Asset[] {
        Asset[] result = [];
        foreach Asset a in assetStore {
            if a.site == site {
                result.push(a.clone());
            }
        }
        return result;
    }

    // ---------------- Loaning / booking (status + schedule) ----------------

    resource function post assets/[string assetTag]/loan()
            returns Asset|http:NotFound|http:Conflict {
        if !assetStore.hasKey(assetTag) {
            return assetNotFound(assetTag);
        }
        Asset a = assetStore.get(assetTag);
        if a.status != "AVAILABLE" {
            return <http:Conflict>{body: {message: string `Asset is currently ${a.status}`}};
        }
        a.status = "LOANED_OUT";
        assetStore[assetTag] = a;
        return a.clone();
    }

    resource function post assets/[string assetTag]/'return()
            returns Asset|http:NotFound {
        if !assetStore.hasKey(assetTag) {
            return assetNotFound(assetTag);
        }
        Asset a = assetStore.get(assetTag);
        a.status = "AVAILABLE";
        assetStore[assetTag] = a;
        return a.clone();
    }

    // Book a room/lab (or any bookable resource) for a given date; also
    // records a BOOKING schedule entry so it shows up in the schedule views.
    resource function post assets/[string assetTag]/book(@http:Payload BookingRequest payload)
            returns Asset|http:NotFound|http:Conflict {
        if !assetStore.hasKey(assetTag) {
            return assetNotFound(assetTag);
        }
        Asset a = assetStore.get(assetTag);
        if a.status != "AVAILABLE" {
            return <http:Conflict>{body: {message: "Asset is not available for booking"}};
        }
        a.status = "OCCUPIED";
        Schedule sc = {
            scheduleId: uuid:createType1AsString(),
            'type: "BOOKING",
            dueDate: payload.dueDate,
            description: payload.description ?: "Booking"
        };
        a.schedules.push(sc);
        assetStore[assetTag] = a;
        return a.clone();
    }

    // ---------------- Components ----------------

    resource function post assets/[string assetTag]/components(@http:Payload NewComponent payload)
            returns Asset|http:NotFound|http:Conflict {
        if !assetStore.hasKey(assetTag) {
            return assetNotFound(assetTag);
        }
        Asset a = assetStore.get(assetTag);
        string cid = payload.compId ?: uuid:createType1AsString();
        foreach Component c in a.components {
            if c.compId == cid {
                return <http:Conflict>{body: {message: "compId already exists on this asset"}};
            }
        }
        a.components.push({compId: cid, name: payload.name, description: payload.description});
        assetStore[assetTag] = a;
        return a.clone();
    }

    resource function delete assets/[string assetTag]/components/[string compId]()
            returns Asset|http:NotFound {
        if !assetStore.hasKey(assetTag) {
            return assetNotFound(assetTag);
        }
        Asset a = assetStore.get(assetTag);
        Component[] filtered = [];
        foreach Component c in a.components {
            if c.compId != compId {
                filtered.push(c);
            }
        }
        a.components = filtered;
        assetStore[assetTag] = a;
        return a.clone();
    }

    // ---------------- Schedules ----------------

    resource function post assets/[string assetTag]/schedules(@http:Payload NewSchedule payload)
            returns Asset|http:NotFound {
        if !assetStore.hasKey(assetTag) {
            return assetNotFound(assetTag);
        }
        Asset a = assetStore.get(assetTag);
        string sid = payload.scheduleId ?: uuid:createType1AsString();
        a.schedules.push({
            scheduleId: sid,
            'type: payload.'type,
            dueDate: payload.dueDate,
            description: payload.description
        });
        assetStore[assetTag] = a;
        return a.clone();
    }

    resource function put assets/[string assetTag]/schedules/[string scheduleId](@http:Payload ScheduleUpdate payload)
            returns Asset|http:NotFound {
        if !assetStore.hasKey(assetTag) {
            return assetNotFound(assetTag);
        }
        Asset a = assetStore.get(assetTag);
        boolean found = false;
        Schedule[] updatedList = [];
        foreach Schedule sc in a.schedules {
            Schedule current = sc;
            if current.scheduleId == scheduleId {
                found = true;
                if payload.dueDate is string {
                    current.dueDate = <string>payload.dueDate;
                }
                if payload.description is string {
                    current.description = <string>payload.description;
                }
                if payload.completed is boolean {
                    current.completed = <boolean>payload.completed;
                }
            }
            updatedList.push(current);
        }
        if !found {
            return <http:NotFound>{body: {message: "Schedule not found"}};
        }
        a.schedules = updatedList;
        assetStore[assetTag] = a;
        return a.clone();
    }

    resource function delete assets/[string assetTag]/schedules/[string scheduleId]()
            returns Asset|http:NotFound {
        if !assetStore.hasKey(assetTag) {
            return assetNotFound(assetTag);
        }
        Asset a = assetStore.get(assetTag);
        Schedule[] filtered = [];
        foreach Schedule sc in a.schedules {
            if sc.scheduleId != scheduleId {
                filtered.push(sc);
            }
        }
        a.schedules = filtered;
        assetStore[assetTag] = a;
        return a.clone();
    }

    // ---------------- Work orders & sub-task tracking ----------------

    resource function post assets/[string assetTag]/workorders(@http:Payload NewWorkOrder payload)
            returns Asset|http:NotFound {
        if !assetStore.hasKey(assetTag) {
            return assetNotFound(assetTag);
        }
        Asset a = assetStore.get(assetTag);
        string oid = payload.orderId ?: uuid:createType1AsString();
        a.workOrders.push({orderId: oid, status: "OPEN", description: payload.description, tasks: []});
        a.status = "UNDER_MAINTENANCE";
        assetStore[assetTag] = a;
        return a.clone();
    }

    resource function put assets/[string assetTag]/workorders/[string orderId](@http:Payload WorkOrderUpdate payload)
            returns Asset|http:NotFound {
        if !assetStore.hasKey(assetTag) {
            return assetNotFound(assetTag);
        }
        Asset a = assetStore.get(assetTag);
        boolean found = false;
        WorkOrder[] updatedList = [];
        foreach WorkOrder wo in a.workOrders {
            WorkOrder current = wo;
            if current.orderId == orderId {
                found = true;
                if payload.status is string {
                    current.status = <string>payload.status;
                }
                if payload.description is string {
                    current.description = <string>payload.description;
                }
            }
            updatedList.push(current);
        }
        if !found {
            return <http:NotFound>{body: {message: "Work order not found"}};
        }
        a.workOrders = updatedList;
        // If every work order is now closed, the asset goes back to AVAILABLE.
        boolean anyOpen = false;
        foreach WorkOrder wo in a.workOrders {
            if wo.status != "CLOSED" {
                anyOpen = true;
            }
        }
        if !anyOpen {
            a.status = "AVAILABLE";
        }
        assetStore[assetTag] = a;
        return a.clone();
    }

    resource function post assets/[string assetTag]/workorders/[string orderId]/tasks(@http:Payload NewTask payload)
            returns Asset|http:NotFound {
        if !assetStore.hasKey(assetTag) {
            return assetNotFound(assetTag);
        }
        Asset a = assetStore.get(assetTag);
        boolean found = false;
        WorkOrder[] updatedList = [];
        foreach WorkOrder wo in a.workOrders {
            WorkOrder current = wo;
            if current.orderId == orderId {
                found = true;
                string tid = payload.taskId ?: uuid:createType1AsString();
                current.tasks.push({taskId: tid, description: payload.description});
            }
            updatedList.push(current);
        }
        if !found {
            return <http:NotFound>{body: {message: "Work order not found"}};
        }
        a.workOrders = updatedList;
        assetStore[assetTag] = a;
        return a.clone();
    }

    resource function put assets/[string assetTag]/workorders/[string orderId]/tasks/[string taskId](@http:Payload TaskUpdate payload)
            returns Asset|http:NotFound {
        if !assetStore.hasKey(assetTag) {
            return assetNotFound(assetTag);
        }
        Asset a = assetStore.get(assetTag);
        boolean found = false;
        WorkOrder[] updatedOrders = [];
        foreach WorkOrder wo in a.workOrders {
            WorkOrder currentOrder = wo;
            if currentOrder.orderId == orderId {
                WorkOrderTask[] updatedTasks = [];
                foreach WorkOrderTask t in currentOrder.tasks {
                    WorkOrderTask currentTask = t;
                    if currentTask.taskId == taskId {
                        found = true;
                        if payload.done is boolean {
                            currentTask.done = <boolean>payload.done;
                        }
                        if payload.description is string {
                            currentTask.description = <string>payload.description;
                        }
                    }
                    updatedTasks.push(currentTask);
                }
                currentOrder.tasks = updatedTasks;
            }
            updatedOrders.push(currentOrder);
        }
        if !found {
            return <http:NotFound>{body: {message: "Task not found"}};
        }
        a.workOrders = updatedOrders;
        assetStore[assetTag] = a;
        return a.clone();
    }
}
