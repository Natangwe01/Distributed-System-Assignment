// types.bal
// Data model for the Library and Resource Management System.
// Status values used across the system: AVAILABLE, LOANED_OUT, OCCUPIED,
// UNDER_MAINTENANCE, DISPOSED.

public type Component record {|
    string compId;
    string name;
    string description;
|};

public type Schedule record {|
    string scheduleId;
    string 'type; // "MAINTENANCE", "SERVICING", "BOOKING"
    string dueDate; // ISO date, e.g. "2026-09-01"
    string description;
    boolean completed = false;
|};

public type WorkOrderTask record {|
    string taskId;
    string description;
    boolean done = false;
|};

public type WorkOrder record {|
    string orderId;
    string status; // "OPEN", "IN_PROGRESS", "CLOSED"
    string description;
    WorkOrderTask[] tasks = [];
|};

// Full asset record as stored server-side and returned to clients.
public type Asset record {|
    string assetTag;
    string name;
    string description;
    string institution;
    string site;
    string status;
    string dateAcquired;
    Component[] components = [];
    Schedule[] schedules = [];
    WorkOrder[] workOrders = [];
|};

// Payload used to create a new asset. assetTag is optional - if omitted the
// service generates one.
public type NewAsset record {|
    string assetTag?;
    string name;
    string description;
    string institution;
    string site;
    string status = "AVAILABLE";
    string dateAcquired;
|};

// Payload for partial updates (PUT /assets/{assetTag}).
public type AssetUpdate record {|
    string name?;
    string description?;
    string institution?;
    string site?;
    string status?;
    string dateAcquired?;
|};

public type NewComponent record {|
    string compId?;
    string name;
    string description;
|};

public type NewSchedule record {|
    string scheduleId?;
    string 'type;
    string dueDate;
    string description;
|};

public type ScheduleUpdate record {|
    string dueDate?;
    string description?;
    boolean completed?;
|};

public type NewWorkOrder record {|
    string orderId?;
    string description;
|};

public type WorkOrderUpdate record {|
    string status?;
    string description?;
|};

public type NewTask record {|
    string taskId?;
    string description;
|};

public type TaskUpdate record {|
    boolean done?;
    string description?;
|};

public type NewInstitution record {|
    string name;
|};

public type BookingRequest record {|
    string dueDate;
    string description?;
|};

public type ApiMessage record {|
    string message;
|};
