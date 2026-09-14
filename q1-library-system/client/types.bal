// types.bal (client copy of the service's data model, used to parse responses)

public type Component record {|
    string compId;
    string name;
    string description;
|};

public type Schedule record {|
    string scheduleId;
    string 'type;
    string dueDate;
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
    string status;
    string description;
    WorkOrderTask[] tasks = [];
|};

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

public type ApiMessage record {|
    string message;
|};
