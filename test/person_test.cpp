#include <gtest/gtest.h>
#include <string>
#include "person.pb.h"

class PersonTest : public ::testing::Test {
protected:
    void SetUp() override {
        GOOGLE_PROTOBUF_VERIFY_VERSION;
    }
};

TEST_F(PersonTest, EncodeDecodeMessage) {
    // Create and populate a Person message
    example::Person original_person;
    original_person.set_name("Alice Smith");
    original_person.set_id(42);
    original_person.set_email("alice@example.com");

    // Encode (serialize) the message
    std::string serialized_data;
    ASSERT_TRUE(original_person.SerializeToString(&serialized_data))
        << "Failed to serialize Person message";
    EXPECT_GT(serialized_data.size(), 0) << "Serialized data should not be empty";

    // Decode (deserialize) the message
    example::Person decoded_person;
    ASSERT_TRUE(decoded_person.ParseFromString(serialized_data))
        << "Failed to parse Person message";

    // Validate all fields match
    EXPECT_EQ(decoded_person.name(), original_person.name())
        << "Name field does not match";
    EXPECT_EQ(decoded_person.id(), original_person.id())
        << "ID field does not match";
    EXPECT_EQ(decoded_person.email(), original_person.email())
        << "Email field does not match";
}

TEST_F(PersonTest, EncodeDecodeEmptyMessage) {
    // Test with an empty Person message
    example::Person original_person;

    // Encode
    std::string serialized_data;
    ASSERT_TRUE(original_person.SerializeToString(&serialized_data));

    // Decode
    example::Person decoded_person;
    ASSERT_TRUE(decoded_person.ParseFromString(serialized_data));

    // Validate empty fields
    EXPECT_EQ(decoded_person.name(), "");
    EXPECT_EQ(decoded_person.id(), 0);
    EXPECT_EQ(decoded_person.email(), "");
}

int main(int argc, char **argv) {
    ::testing::InitGoogleTest(&argc, argv);
    int result = RUN_ALL_TESTS();
    google::protobuf::ShutdownProtobufLibrary();
    return result;
}
