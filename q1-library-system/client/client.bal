// client.bal
// Command-line Ballerina client for the Library and Resource Management API.

import ballerina/http;
import ballerina/io;

configurable string serviceUrl = "http://localhost:8080/library";

final http:Client libraryClient = check new (serviceUrl);

public function main() returns error? {
    boolean running = true;
    while running {
        io:println("\n===== Library & Resource Management Client =====");
        io:println(" 1. Global view          - list every asset across the Ministry");
        io:println(" 2. Campus view           - filter assets by site/campus");
        io:println(" 3. Institution view      - filter assets by institution");
        io:println(" 4. Overdue dashboard     - assets with an overdue schedule");
        io:println(" 5. Loan an asset");
        io:println(" 6. Return an asset");
        io:println(" 7. Book an asset/room/lab");
        io:println(" 8. Schedule manager      - add a schedule");
        io:println(" 9. Schedule manager      - mark a schedule complete/edit it");
        io:println("10. Create a new asset");
        io:println("11. Institution admin     - add or remove an institution");
        io:println(" 0. Exit");
        string choice = io:readln("Choose an option: ");

        do {
            if choice == "1" {
                check globalView();
            } else if choice == "2" {
                check campusView();
            } else if choice == "3" {
                check institutionView();
            } else if choice == "4" {
                check overdueDashboard();
            } else if choice == "5" {
                check loanAsset();
            } else if choice == "6" {
                check returnAsset();
            } else if choice == "7" {
                check bookAsset();
            } else if choice == "8" {
                check addSchedule();
            } else if choice == "9" {
                check updateSchedule();
            } else if choice == "10" {
                check createAsset();
            } else if choice == "11" {
                check manageInstitution();
            } else if choice == "0" {
                running = false;
            } else {
                io:println("Invalid option, please try again.");
            }
        } on fail error e {
            io:println("Request failed: ", e.message());
        }
    }
    io:println("Goodbye.");
}

function printAsset(Asset a) {
    io:println(string `  [${a.assetTag}] ${a.name} - ${a.status}`);
    io:println(string `      institution: ${a.institution} | site: ${a.site} | acquired: ${a.dateAcquired}`);
    if a.schedules.length() > 0 {
        foreach Schedule sc in a.schedules {
            string flag = sc.completed ? "done" : "pending";
            io:println(string `      schedule ${sc.scheduleId} (${sc.'type}) due ${sc.dueDate} [${flag}]`);
        }
    }
    if a.workOrders.length() > 0 {
        foreach WorkOrder wo in a.workOrders {
            io:println(string `      work order ${wo.orderId} - ${wo.status}: ${wo.description}`);
        }
    }
}

function printAssetList(Asset[] assets) {
    if assets.length() == 0 {
        io:println("  (no assets found)");
        return;
    }
    foreach Asset a in assets {
        printAsset(a);
    }
}

function globalView() returns error? {
    Asset[] assets = check libraryClient->get("/assets");
    io:println(string `\nGlobal view - ${assets.length()} asset(s):`);
    printAssetList(assets);
}

function campusView() returns error? {
    string site = io:readln("Site/campus name: ");
    Asset[] assets = check libraryClient->get("/sites/" + site + "/assets");
    io:println(string `\nCampus view for '${site}' - ${assets.length()} asset(s):`);
    printAssetList(assets);
}

function institutionView() returns error? {
    string inst = io:readln("Institution name: ");
    Asset[] assets = check libraryClient->get("/institutions/" + inst + "/assets");
    io:println(string `\nInstitution view for '${inst}' - ${assets.length()} asset(s):`);
    printAssetList(assets);
}

function overdueDashboard() returns error? {
    Asset[] assets = check libraryClient->get("/assets/overdue");
    io:println(string `\nOverdue dashboard - ${assets.length()} asset(s) with an overdue schedule:`);
    printAssetList(assets);
}

function loanAsset() returns error? {
    string tag = io:readln("Asset tag to loan out: ");
    Asset|http:ClientError result = libraryClient->post("/assets/" + tag + "/loan", {});
    if result is Asset {
        io:println("Loaned out: ");
        printAsset(result);
    } else {
        io:println("Could not loan asset: ", result.message());
    }
}

function returnAsset() returns error? {
    string tag = io:readln("Asset tag being returned: ");
    Asset a = check libraryClient->post("/assets/" + tag + "/return", {});
    io:println("Returned: ");
    printAsset(a);
}

function bookAsset() returns error? {
    string tag = io:readln("Asset tag to book (e.g. a lab/room): ");
    string dueDate = io:readln("Booking date (YYYY-MM-DD): ");
    string desc = io:readln("Description (optional, press enter to skip): ");
    json payload = desc.trim() == "" ? {dueDate} : {dueDate, description: desc};
    Asset|http:ClientError result = libraryClient->post("/assets/" + tag + "/book", payload);
    if result is Asset {
        io:println("Booked: ");
        printAsset(result);
    } else {
        io:println("Could not book asset: ", result.message());
    }
}

function addSchedule() returns error? {
    string tag = io:readln("Asset tag: ");
    string scheduleType = io:readln("Schedule type (MAINTENANCE / SERVICING / BOOKING): ");
    string dueDate = io:readln("Due date (YYYY-MM-DD): ");
    string desc = io:readln("Description: ");
    json payload = {"type": scheduleType, dueDate, description: desc};
    Asset a = check libraryClient->post("/assets/" + tag + "/schedules", payload);
    io:println("Schedule added. Current schedules:");
    printAsset(a);
}

function updateSchedule() returns error? {
    string tag = io:readln("Asset tag: ");
    string scheduleId = io:readln("Schedule ID to update: ");
    string completedStr = io:readln("Mark as completed? (y/n, leave blank to skip): ");
    string newDueDate = io:readln("New due date (leave blank to skip): ");
    map<json> payload = {};
    if completedStr == "y" {
        payload["completed"] = true;
    } else if completedStr == "n" {
        payload["completed"] = false;
    }
    if newDueDate.trim() != "" {
        payload["dueDate"] = newDueDate;
    }
    Asset a = check libraryClient->put("/assets/" + tag + "/schedules/" + scheduleId, payload);
    io:println("Schedule updated:");
    printAsset(a);
}

function createAsset() returns error? {
    string name = io:readln("Asset name: ");
    string description = io:readln("Description: ");
    string institution = io:readln("Institution: ");
    string site = io:readln("Site/campus: ");
    string dateAcquired = io:readln("Date acquired (YYYY-MM-DD): ");
    json payload = {name, description, institution, site, dateAcquired, status: "AVAILABLE"};
    Asset a = check libraryClient->post("/assets", payload);
    io:println("Created asset:");
    printAsset(a);
}

function manageInstitution() returns error? {
    string action = io:readln("Type 'add' or 'remove': ");
    string name = io:readln("Institution name: ");
    if action == "add" {
        ApiMessage msg = check libraryClient->post("/institutions", {name});
        io:println(msg.message);
    } else if action == "remove" {
        ApiMessage msg = check libraryClient->delete("/institutions/" + name);
        io:println(msg.message);
    } else {
        io:println("Unknown action.");
    }
}
