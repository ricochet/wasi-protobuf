cmake_minimum_required(VERSION 3.15)
project(wasi-proto-wasm)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find protobuf (from vcpkg)
find_package(protobuf CONFIG REQUIRED)

# Main executable - using shared vcpkg protobuf files from parent directory
set(OUTPUT_NAME "main.wasm")

add_executable(main
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/../person.pb.cc
    wasi_stubs.cpp
)

set_target_properties(main PROPERTIES OUTPUT_NAME ${OUTPUT_NAME})

# Include parent directory for protobuf headers
target_include_directories(main PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/..
)

# Define WASI version macro for conditional compilation
if(WASI_VERSION STREQUAL "wasip2")
    target_compile_definitions(main PRIVATE WASIP2)
endif()

# Link against full protobuf
target_link_libraries(main PRIVATE
    protobuf::libprotobuf
)

# Add WASI linker options (allow undefined for remaining thread stubs)
# For wasip2, use component linker to build WASI components
if(WASI_VERSION STREQUAL "wasip2")
    target_link_options(main PRIVATE
        -Wl,--export-all
        -Wl,--allow-undefined
        -fuse-ld=${WASI_SDK_PREFIX}/bin/wasm-component-ld
    )
else()
    target_link_options(main PRIVATE
        -Wl,--export-all
        -Wl,--allow-undefined
    )
endif()
