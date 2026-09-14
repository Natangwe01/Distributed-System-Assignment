// main.bal
//
// IMPORTANT - read this before building:
// Build the server project first (see server/service.bal). This client
// imports the same generated stub, so copy/generate rental_pb.bal into
// this directory too:
//
//     bal grpc --input ../proto/rental.proto --output .
//
// This produces RentalServiceClient (the blocking client stub) plus the
// message records. Exact client-streaming method names
// (sendUserProfile / receiveUserRegistrationSummary below) are generated
// by the tool from the message names in rental.proto - if your generated
// stub names them differently, rename the calls below to match; the
// call sequence (send each item, then close and read the summary) stays
// the same.

import ballerina/grpc;
import ballerina/io;

configurable string serverUrl = "http://localhost:9090";

final RentalServiceClient rentalClient = check new (serverUrl);

public function main() returns error? {
    boolean running = true;
    while running {
        io:println("\n===== Rental Accommodation gRPC Client =====");
        io:println("1. Host: add a property               (simple RPC)");
        io:println("2. Host: update a property             (simple RPC)");
        io:println("3. Host: remove a property             (simple RPC)");
        io:println("4. Guest: list available properties    (server streaming)");
        io:println("5. Guest: search for a property by id  (simple RPC)");
        io:println("6. Guest: book a property               (simple RPC -> booking cart)");
        io:println("7. Guest: confirm a booking             (simple RPC)");
        io:println("8. Register several users in one go    (client streaming)");
        io:println("0. Exit");
        string choice = io:readln("Choose an option: ");

        do {
            if choice == "1" {
                check addProperty();
            } else if choice == "2" {
                check updateProperty();
            } else if choice == "3" {
                check removeProperty();
            } else if choice == "4" {
                check listAvailableProperties();
            } else if choice == "5" {
                check searchProperty();
            } else if choice == "6" {
                check bookProperty();
            } else if choice == "7" {
                check confirmBooking();
            } else if choice == "8" {
                check registerUsers();
            } else if choice == "0" {
                running = false;
            } else {
                io:println("Invalid option, try again.");
            }
        } on fail error e {
            io:println("Operation failed: ", e.message());
        }
    }
    io:println("Goodbye.");
}

function printProperty(PropertyResponse p) {
    io:println(string `  [${p.propertyId}] ${p.name} (${p.propertyType}) - ${p.status}`);
    io:println(string `      host: ${p.hostId} | location: ${p.location} | $${p.pricePerNight}/night`);
}

function addProperty() returns error? {
    string hostId = io:readln("Host id: ");
    string name = io:readln("Property name: ");
    string location = io:readln("Location: ");
    string propertyType = io:readln("Property type (e.g. apartment/house/room): ");
    string priceStr = io:readln("Price per night: ");
    float price = check float:fromString(priceStr);

    PropertyRequest req = {
        hostId,
        name,
        location,
        propertyType,
        pricePerNight: price,
        status: "AVAILABLE"
    };
    PropertyIdResponse resp = check rentalClient->add_property(req);
    io:println(string `Registered with property_id: ${resp.propertyId} - ${resp.message}`);
}

function updateProperty() returns error? {
    string propertyId = io:readln("Property id: ");
    string hostId = io:readln("Host id (must match owner): ");
    string priceStr = io:readln("New price per night (leave blank to keep unchanged): ");
    string status = io:readln("New status (leave blank to keep unchanged): ");

    UpdatePropertyRequest req = {propertyId, hostId};
    if priceStr.trim().length() > 0 {
        req.pricePerNight = check float:fromString(priceStr);
    }
    if status.trim().length() > 0 {
        req.status = status;
    }
    PropertyResponse resp = check rentalClient->update_property(req);
    io:println("Updated property:");
    printProperty(resp);
}

function removeProperty() returns error? {
    string propertyId = io:readln("Property id to remove: ");
    string hostId = io:readln("Host id (must match owner): ");
    PropertyListResponse resp = check rentalClient->remove_property({propertyId, hostId});
    io:println(string `Property removed. ${resp.properties.length()} property/properties still available in that region:`);
    foreach PropertyResponse p in resp.properties {
        printProperty(p);
    }
}

function listAvailableProperties() returns error? {
    string location = io:readln("Filter by location (leave blank for any): ");
    string maxPriceStr = io:readln("Max price (leave blank / 0 for any): ");
    float maxPrice = maxPriceStr.trim().length() > 0 ? check float:fromString(maxPriceStr) : 0.0;

    stream<PropertyResponse, grpc:Error?> resultStream =
        check rentalClient->list_available_properties({location, maxPrice});

    io:println("Available properties:");
    int count = 0;
    check resultStream.forEach(function(PropertyResponse p) {
        printProperty(p);
        count += 1;
    });
    if count == 0 {
        io:println("  (none found matching that filter)");
    }
}

function searchProperty() returns error? {
    string propertyId = io:readln("Property id: ");
    SearchPropertyResponse resp = check rentalClient->search_property({propertyId});
    if !resp.found {
        io:println(resp.statusMessage);
        return;
    }
    io:println(resp.statusMessage);
    printProperty(resp.property);
}

function bookProperty() returns error? {
    string guestId = io:readln("Guest id: ");
    string propertyId = io:readln("Property id: ");
    string checkIn = io:readln("Check-in date (YYYY-MM-DD): ");
    string checkOut = io:readln("Check-out date (YYYY-MM-DD): ");
    BookingCartResponse resp = check rentalClient->book_property({
        guestId,
        propertyId,
        checkInDate: checkIn,
        checkOutDate: checkOut
    });
    if resp.success {
        io:println(string `Held in cart ${resp.cartId}: ${resp.message}`);
    } else {
        io:println(string `Could not book: ${resp.message}`);
    }
}

function confirmBooking() returns error? {
    string cartId = io:readln("Cart id: ");
    BookingConfirmationResponse resp = check rentalClient->confirm_booking({cartId});
    if resp.confirmed {
        io:println(string `Booking confirmed! id=${resp.bookingId}, ${resp.nights} night(s), total cost = ${resp.totalCost}`);
    } else {
        io:println(string `Booking not confirmed: ${resp.message}`);
    }
}

function registerUsers() returns error? {
    int howMany = check int:fromString(io:readln("How many users would you like to register? "));
    grpc:StreamingClient streamingClient = check rentalClient->create_users();
    foreach int i in 1 ... howMany {
        io:println(string `--- user ${i} ---`);
        string userId = io:readln("  user id: ");
        string name = io:readln("  name: ");
        string role = io:readln("  role (HOST/GUEST): ");
        string region = io:readln("  region: ");
        string contact = io:readln("  contact: ");
        check streamingClient->sendUserProfile({userId, name, role, region, contact});
    }
    check streamingClient->complete();
    UserRegistrationSummary summary = check streamingClient->receiveUserRegistrationSummary();
    io:println(summary.message);
}
