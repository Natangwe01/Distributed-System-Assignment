import ballerina/grpc;
import ballerina/protobuf;

public const string RENTAL_DESC = "0A0C72656E74616C2E70726F746F120672656E74616C22BF010A0F50726F70657274795265717565737412170A07686F73745F69641801200128095206686F7374496412120A046E616D6518022001280952046E616D65121A0A086C6F636174696F6E18032001280952086C6F636174696F6E12230A0D70726F70657274795F74797065180420012809520C70726F70657274795479706512260A0F70726963655F7065725F6E69676874180520012801520D70726963655065724E6967687412160A06737461747573180620012809520673746174757322690A1250726F70657274794964526573706F6E736512180A0773756363657373180120012808520773756363657373121F0A0B70726F70657274795F6964180220012809520A70726F7065727479496412180A076D65737361676518032001280952076D6573736167652280010A0B5573657250726F66696C6512170A07757365725F6964180120012809520675736572496412120A046E616D6518022001280952046E616D6512120A04726F6C651803200128095204726F6C6512160A06726567696F6E1804200128095206726567696F6E12180A07636F6E746163741805200128095207636F6E74616374225E0A1755736572526567697374726174696F6E53756D6D61727912290A10746F74616C5F72656769737465726564180120012805520F746F74616C5265676973746572656412180A076D65737361676518022001280952076D65737361676522BA010A1555706461746550726F706572747952657175657374121F0A0B70726F70657274795F6964180120012809520A70726F7065727479496412170A07686F73745F69641802200128095206686F73744964122B0A0F70726963655F7065725F6E696768741803200128014800520D70726963655065724E69676874880101121B0A067374617475731804200128094801520673746174757388010142120A105F70726963655F7065725F6E6967687442090A075F73746174757322F7010A1050726F7065727479526573706F6E736512140A05666F756E641801200128085205666F756E64121F0A0B70726F70657274795F6964180220012809520A70726F7065727479496412170A07686F73745F69641803200128095206686F7374496412120A046E616D6518042001280952046E616D65121A0A086C6F636174696F6E18052001280952086C6F636174696F6E12230A0D70726F70657274795F74797065180620012809520C70726F70657274795479706512260A0F70726963655F7065725F6E69676874180720012801520D70726963655065724E6967687412160A06737461747573180820012809520673746174757322510A1552656D6F766550726F706572747952657175657374121F0A0B70726F70657274795F6964180120012809520A70726F7065727479496412170A07686F73745F69641802200128095206686F7374496422500A1450726F70657274794C697374526573706F6E736512380A0A70726F7065727469657318012003280B32182E72656E74616C2E50726F7065727479526573706F6E7365520A70726F7065727469657322500A154C69737450726F7065727469657352657175657374121A0A086C6F636174696F6E18012001280952086C6F636174696F6E121B0A096D61785F707269636518022001280152086D6178507269636522380A1553656172636850726F706572747952657175657374121F0A0B70726F70657274795F6964180120012809520A70726F70657274794964228B010A1653656172636850726F7065727479526573706F6E736512140A05666F756E641801200128085205666F756E6412250A0E7374617475735F6D657373616765180220012809520D7374617475734D65737361676512340A0870726F706572747918032001280B32182E72656E74616C2E50726F7065727479526573706F6E7365520870726F7065727479229B010A13426F6F6B50726F70657274795265717565737412190A0867756573745F6964180120012809520767756573744964121F0A0B70726F70657274795F6964180220012809520A70726F7065727479496412220A0D636865636B5F696E5F64617465180320012809520B636865636B496E4461746512240A0E636865636B5F6F75745F64617465180420012809520C636865636B4F75744461746522620A13426F6F6B696E6743617274526573706F6E736512180A077375636365737318012001280852077375636365737312170A07636172745F6964180220012809520663617274496412180A076D65737361676518032001280952076D65737361676522300A15436F6E6669726D426F6F6B696E675265717565737412170A07636172745F6964180120012809520663617274496422AB010A1B426F6F6B696E67436F6E6669726D6174696F6E526573706F6E7365121C0A09636F6E6669726D65641801200128085209636F6E6669726D6564121D0A0A626F6F6B696E675F69641802200128095209626F6F6B696E674964121D0A0A746F74616C5F636F73741803200128015209746F74616C436F737412160A066E696768747318042001280552066E696768747312180A076D65737361676518052001280952076D6573736167653284050A0D52656E74616C5365727669636512430A0C6164645F70726F706572747912172E72656E74616C2E50726F7065727479526571756573741A1A2E72656E74616C2E50726F70657274794964526573706F6E736512460A0C6372656174655F757365727312132E72656E74616C2E5573657250726F66696C651A1F2E72656E74616C2E55736572526567697374726174696F6E53756D6D6172792801124A0A0F7570646174655F70726F7065727479121D2E72656E74616C2E55706461746550726F7065727479526571756573741A182E72656E74616C2E50726F7065727479526573706F6E7365124E0A0F72656D6F76655F70726F7065727479121D2E72656E74616C2E52656D6F766550726F7065727479526571756573741A1C2E72656E74616C2E50726F70657274794C697374526573706F6E736512560A196C6973745F617661696C61626C655F70726F70657274696573121D2E72656E74616C2E4C69737450726F70657274696573526571756573741A182E72656E74616C2E50726F7065727479526573706F6E7365300112500A0F7365617263685F70726F7065727479121D2E72656E74616C2E53656172636850726F7065727479526571756573741A1E2E72656E74616C2E53656172636850726F7065727479526573706F6E736512490A0D626F6F6B5F70726F7065727479121B2E72656E74616C2E426F6F6B50726F7065727479526571756573741A1B2E72656E74616C2E426F6F6B696E6743617274526573706F6E736512550A0F636F6E6669726D5F626F6F6B696E67121D2E72656E74616C2E436F6E6669726D426F6F6B696E67526571756573741A232E72656E74616C2E426F6F6B696E67436F6E6669726D6174696F6E526573706F6E7365620670726F746F33";

public isolated client class RentalServiceClient {
    *grpc:AbstractClientEndpoint;

    private final grpc:Client grpcClient;

    public isolated function init(string url, *grpc:ClientConfiguration config) returns grpc:Error? {
        self.grpcClient = check new (url, config);
        check self.grpcClient.initStub(self, RENTAL_DESC);
    }

    isolated remote function add_property(PropertyRequest|ContextPropertyRequest req) returns PropertyIdResponse|grpc:Error {
        map<string|string[]> headers = {};
        PropertyRequest message;
        if req is ContextPropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalService/add_property", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <PropertyIdResponse>result;
    }

    isolated remote function add_propertyContext(PropertyRequest|ContextPropertyRequest req) returns ContextPropertyIdResponse|grpc:Error {
        map<string|string[]> headers = {};
        PropertyRequest message;
        if req is ContextPropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalService/add_property", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <PropertyIdResponse>result, headers: respHeaders};
    }

    isolated remote function update_property(UpdatePropertyRequest|ContextUpdatePropertyRequest req) returns PropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        UpdatePropertyRequest message;
        if req is ContextUpdatePropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalService/update_property", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <PropertyResponse>result;
    }

    isolated remote function update_propertyContext(UpdatePropertyRequest|ContextUpdatePropertyRequest req) returns ContextPropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        UpdatePropertyRequest message;
        if req is ContextUpdatePropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalService/update_property", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <PropertyResponse>result, headers: respHeaders};
    }

    isolated remote function remove_property(RemovePropertyRequest|ContextRemovePropertyRequest req) returns PropertyListResponse|grpc:Error {
        map<string|string[]> headers = {};
        RemovePropertyRequest message;
        if req is ContextRemovePropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalService/remove_property", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <PropertyListResponse>result;
    }

    isolated remote function remove_propertyContext(RemovePropertyRequest|ContextRemovePropertyRequest req) returns ContextPropertyListResponse|grpc:Error {
        map<string|string[]> headers = {};
        RemovePropertyRequest message;
        if req is ContextRemovePropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalService/remove_property", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <PropertyListResponse>result, headers: respHeaders};
    }

    isolated remote function search_property(SearchPropertyRequest|ContextSearchPropertyRequest req) returns SearchPropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        SearchPropertyRequest message;
        if req is ContextSearchPropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalService/search_property", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <SearchPropertyResponse>result;
    }

    isolated remote function search_propertyContext(SearchPropertyRequest|ContextSearchPropertyRequest req) returns ContextSearchPropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        SearchPropertyRequest message;
        if req is ContextSearchPropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalService/search_property", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <SearchPropertyResponse>result, headers: respHeaders};
    }

    isolated remote function book_property(BookPropertyRequest|ContextBookPropertyRequest req) returns BookingCartResponse|grpc:Error {
        map<string|string[]> headers = {};
        BookPropertyRequest message;
        if req is ContextBookPropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalService/book_property", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <BookingCartResponse>result;
    }

    isolated remote function book_propertyContext(BookPropertyRequest|ContextBookPropertyRequest req) returns ContextBookingCartResponse|grpc:Error {
        map<string|string[]> headers = {};
        BookPropertyRequest message;
        if req is ContextBookPropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalService/book_property", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <BookingCartResponse>result, headers: respHeaders};
    }

    isolated remote function confirm_booking(ConfirmBookingRequest|ContextConfirmBookingRequest req) returns BookingConfirmationResponse|grpc:Error {
        map<string|string[]> headers = {};
        ConfirmBookingRequest message;
        if req is ContextConfirmBookingRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalService/confirm_booking", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <BookingConfirmationResponse>result;
    }

    isolated remote function confirm_bookingContext(ConfirmBookingRequest|ContextConfirmBookingRequest req) returns ContextBookingConfirmationResponse|grpc:Error {
        map<string|string[]> headers = {};
        ConfirmBookingRequest message;
        if req is ContextConfirmBookingRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalService/confirm_booking", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <BookingConfirmationResponse>result, headers: respHeaders};
    }

    isolated remote function create_users() returns Create_usersStreamingClient|grpc:Error {
        grpc:StreamingClient sClient = check self.grpcClient->executeClientStreaming("rental.RentalService/create_users");
        return new Create_usersStreamingClient(sClient);
    }

    isolated remote function list_available_properties(ListPropertiesRequest|ContextListPropertiesRequest req) returns stream<PropertyResponse, grpc:Error?>|grpc:Error {
        map<string|string[]> headers = {};
        ListPropertiesRequest message;
        if req is ContextListPropertiesRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeServerStreaming("rental.RentalService/list_available_properties", message, headers);
        [stream<anydata, grpc:Error?>, map<string|string[]>] [result, _] = payload;
        PropertyResponseStream outputStream = new PropertyResponseStream(result);
        return new stream<PropertyResponse, grpc:Error?>(outputStream);
    }

    isolated remote function list_available_propertiesContext(ListPropertiesRequest|ContextListPropertiesRequest req) returns ContextPropertyResponseStream|grpc:Error {
        map<string|string[]> headers = {};
        ListPropertiesRequest message;
        if req is ContextListPropertiesRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeServerStreaming("rental.RentalService/list_available_properties", message, headers);
        [stream<anydata, grpc:Error?>, map<string|string[]>] [result, respHeaders] = payload;
        PropertyResponseStream outputStream = new PropertyResponseStream(result);
        return {content: new stream<PropertyResponse, grpc:Error?>(outputStream), headers: respHeaders};
    }
}

public isolated client class Create_usersStreamingClient {
    private final grpc:StreamingClient sClient;

    isolated function init(grpc:StreamingClient sClient) {
        self.sClient = sClient;
    }

    isolated remote function sendUserProfile(UserProfile message) returns grpc:Error? {
        return self.sClient->send(message);
    }

    isolated remote function sendContextUserProfile(ContextUserProfile message) returns grpc:Error? {
        return self.sClient->send(message);
    }

    isolated remote function receiveUserRegistrationSummary() returns UserRegistrationSummary|grpc:Error? {
        var response = check self.sClient->receive();
        if response is () {
            return response;
        } else {
            [anydata, map<string|string[]>] [payload, _] = response;
            return <UserRegistrationSummary>payload;
        }
    }

    isolated remote function receiveContextUserRegistrationSummary() returns ContextUserRegistrationSummary|grpc:Error? {
        var response = check self.sClient->receive();
        if response is () {
            return response;
        } else {
            [anydata, map<string|string[]>] [payload, headers] = response;
            return {content: <UserRegistrationSummary>payload, headers: headers};
        }
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.sClient->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.sClient->complete();
    }
}

public class PropertyResponseStream {
    private stream<anydata, grpc:Error?> anydataStream;

    public isolated function init(stream<anydata, grpc:Error?> anydataStream) {
        self.anydataStream = anydataStream;
    }

    public isolated function next() returns record {|PropertyResponse value;|}|grpc:Error? {
        var streamValue = self.anydataStream.next();
        if streamValue is () {
            return streamValue;
        } else if streamValue is grpc:Error {
            return streamValue;
        } else {
            record {|PropertyResponse value;|} nextRecord = {value: <PropertyResponse>streamValue.value};
            return nextRecord;
        }
    }

    public isolated function close() returns grpc:Error? {
        return self.anydataStream.close();
    }
}

public isolated client class RentalServicePropertyResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendPropertyResponse(PropertyResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextPropertyResponse(ContextPropertyResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class RentalServiceSearchPropertyResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendSearchPropertyResponse(SearchPropertyResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextSearchPropertyResponse(ContextSearchPropertyResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class RentalServiceBookingConfirmationResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendBookingConfirmationResponse(BookingConfirmationResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextBookingConfirmationResponse(ContextBookingConfirmationResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class RentalServicePropertyIdResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendPropertyIdResponse(PropertyIdResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextPropertyIdResponse(ContextPropertyIdResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class RentalServicePropertyListResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendPropertyListResponse(PropertyListResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextPropertyListResponse(ContextPropertyListResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class RentalServiceBookingCartResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendBookingCartResponse(BookingCartResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextBookingCartResponse(ContextBookingCartResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class RentalServiceUserRegistrationSummaryCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendUserRegistrationSummary(UserRegistrationSummary response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextUserRegistrationSummary(ContextUserRegistrationSummary response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public type ContextUserProfileStream record {|
    stream<UserProfile, error?> content;
    map<string|string[]> headers;
|};

public type ContextPropertyResponseStream record {|
    stream<PropertyResponse, error?> content;
    map<string|string[]> headers;
|};

public type ContextBookPropertyRequest record {|
    BookPropertyRequest content;
    map<string|string[]> headers;
|};

public type ContextListPropertiesRequest record {|
    ListPropertiesRequest content;
    map<string|string[]> headers;
|};

public type ContextUserProfile record {|
    UserProfile content;
    map<string|string[]> headers;
|};

public type ContextUpdatePropertyRequest record {|
    UpdatePropertyRequest content;
    map<string|string[]> headers;
|};

public type ContextBookingCartResponse record {|
    BookingCartResponse content;
    map<string|string[]> headers;
|};

public type ContextSearchPropertyResponse record {|
    SearchPropertyResponse content;
    map<string|string[]> headers;
|};

public type ContextBookingConfirmationResponse record {|
    BookingConfirmationResponse content;
    map<string|string[]> headers;
|};

public type ContextUserRegistrationSummary record {|
    UserRegistrationSummary content;
    map<string|string[]> headers;
|};

public type ContextConfirmBookingRequest record {|
    ConfirmBookingRequest content;
    map<string|string[]> headers;
|};

public type ContextPropertyResponse record {|
    PropertyResponse content;
    map<string|string[]> headers;
|};

public type ContextRemovePropertyRequest record {|
    RemovePropertyRequest content;
    map<string|string[]> headers;
|};

public type ContextPropertyIdResponse record {|
    PropertyIdResponse content;
    map<string|string[]> headers;
|};

public type ContextPropertyListResponse record {|
    PropertyListResponse content;
    map<string|string[]> headers;
|};

public type ContextSearchPropertyRequest record {|
    SearchPropertyRequest content;
    map<string|string[]> headers;
|};

public type ContextPropertyRequest record {|
    PropertyRequest content;
    map<string|string[]> headers;
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type BookPropertyRequest record {|
    string guest_id = "";
    string property_id = "";
    string check_in_date = "";
    string check_out_date = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type ListPropertiesRequest record {|
    string location = "";
    float max_price = 0.0;
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type UserProfile record {|
    string user_id = "";
    string name = "";
    string role = "";
    string region = "";
    string contact = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type UpdatePropertyRequest record {|
    string property_id = "";
    string host_id = "";
    float price_per_night?;
    string status?;
|};

isolated function isValidUpdatepropertyrequest(UpdatePropertyRequest r) returns boolean {
    int _price_per_nightCount = 0;
    if r?.price_per_night !is () {
        _price_per_nightCount += 1;
    }
    int _statusCount = 0;
    if r?.status !is () {
        _statusCount += 1;
    }
    if _price_per_nightCount > 1 || _statusCount > 1 {
        return false;
    }
    return true;
}

isolated function setUpdatePropertyRequest_PricePerNight(UpdatePropertyRequest r, float price_per_night) {
    r.price_per_night = price_per_night;
}

isolated function setUpdatePropertyRequest_Status(UpdatePropertyRequest r, string status) {
    r.status = status;
}

@protobuf:Descriptor {value: RENTAL_DESC}
public type BookingCartResponse record {|
    boolean success = false;
    string cart_id = "";
    string message = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type SearchPropertyResponse record {|
    boolean found = false;
    string status_message = "";
    PropertyResponse property = {};
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type BookingConfirmationResponse record {|
    boolean confirmed = false;
    string booking_id = "";
    float total_cost = 0.0;
    int nights = 0;
    string message = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type UserRegistrationSummary record {|
    int total_registered = 0;
    string message = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type ConfirmBookingRequest record {|
    string cart_id = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type PropertyResponse record {|
    boolean found = false;
    string property_id = "";
    string host_id = "";
    string name = "";
    string location = "";
    string property_type = "";
    float price_per_night = 0.0;
    string status = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type RemovePropertyRequest record {|
    string property_id = "";
    string host_id = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type PropertyIdResponse record {|
    boolean success = false;
    string property_id = "";
    string message = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type PropertyListResponse record {|
    PropertyResponse[] properties = [];
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type SearchPropertyRequest record {|
    string property_id = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type PropertyRequest record {|
    string host_id = "";
    string name = "";
    string location = "";
    string property_type = "";
    float price_per_night = 0.0;
    string status = "";
|};
