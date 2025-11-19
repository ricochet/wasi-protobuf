set(VCPKG_TARGET_ARCHITECTURE wasm32)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)

set(VCPKG_CMAKE_SYSTEM_NAME WASI)
set(VCPKG_ENV_PASSTHROUGH_UNTRACKED WASI_SDK_PATH WASI_VERSION)

if(NOT DEFINED ENV{WASI_SDK_PATH})
    message(FATAL_ERROR "WASI_SDK_PATH environment variable must be set")
endif()

# Set WASI_VERSION environment variable for vcpkg builds
set(ENV{WASI_VERSION} "wasip2")

# Chainload the WASI SDK toolchain with wasip2
set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${CMAKE_CURRENT_LIST_DIR}/wasi-sdk-unified.cmake")

# Ensure no-exceptions for all WASI builds
set(VCPKG_CXX_FLAGS "-fno-exceptions")
set(VCPKG_C_FLAGS "")

# Set WASI version for chainloaded toolchain
set(WASI_VERSION "wasip2")
