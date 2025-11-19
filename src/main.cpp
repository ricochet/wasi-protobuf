#include <iostream>
#include <string>
#include "person.pb.h"

int main() {
    // Verify protobuf library version
    GOOGLE_PROTOBUF_VERIFY_VERSION;

    // Create a Person message
    example::Person person;
    person.set_name("John Doe");
    person.set_id(12345);
    person.set_email("john.doe@example.com");

    std::cout << "Original Person:" << std::endl;
    std::cout << "  Name: " << person.name() << std::endl;
    std::cout << "  ID: " << person.id() << std::endl;
    std::cout << "  Email: " << person.email() << std::endl;

    // Encode (serialize) the message to a string
    std::string serialized_data;
    if (!person.SerializeToString(&serialized_data)) {
        std::cerr << "Failed to serialize Person message." << std::endl;
        return 1;
    }
    std::cout << "\nSerialized to " << serialized_data.size() << " bytes" << std::endl;

    // Decode (deserialize) the message from the string
    example::Person decoded_person;
    if (!decoded_person.ParseFromString(serialized_data)) {
        std::cerr << "Failed to parse Person message." << std::endl;
        return 1;
    }

    std::cout << "\nDecoded Person:" << std::endl;
    std::cout << "  Name: " << decoded_person.name() << std::endl;
    std::cout << "  ID: " << decoded_person.id() << std::endl;
    std::cout << "  Email: " << decoded_person.email() << std::endl;

    // Optional: Delete all global objects allocated by libprotobuf
    google::protobuf::ShutdownProtobufLibrary();

    return 0;
}
