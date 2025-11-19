cmake_minimum_required(VERSION 3.15)
project(wasi-proto)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find protobuf (from vcpkg)
find_package(protobuf CONFIG REQUIRED)

# Use pre-generated protobuf files
set(PROTO_SRCS ${CMAKE_CURRENT_SOURCE_DIR}/person.pb.cc)
set(PROTO_HDRS ${CMAKE_CURRENT_SOURCE_DIR}/person.pb.h)

# Include directories for generated protobuf headers
include_directories(${CMAKE_CURRENT_SOURCE_DIR})

# Main executable
add_executable(main
    src/main.cpp
    ${PROTO_SRCS}
    ${PROTO_HDRS}
)

target_link_libraries(main
    protobuf::libprotobuf
)

# Enable testing
enable_testing()

# Find Google Test
find_package(GTest REQUIRED)

# Test executable
add_executable(person_test
    test/person_test.cpp
    ${PROTO_SRCS}
    ${PROTO_HDRS}
)

target_link_libraries(person_test
    protobuf::libprotobuf
    GTest::GTest
    GTest::Main
)

# Add test
add_test(NAME PersonTest COMMAND person_test)
