set(VCPKG_TARGET_ARCHITECTURE wasm32)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)

set(VCPKG_CMAKE_SYSTEM_NAME WASI)
set(VCPKG_ENV_PASSTHROUGH_UNTRACKED WASI_SDK_PATH)

if(NOT DEFINED ENV{WASI_SDK_PATH})
    message(FATAL_ERROR "WASI_SDK_PATH environment variable must be set")
endif()

# Note: VCPKG_CHAINLOAD_TOOLCHAIN_FILE should be passed via command line:
# -DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=./wasi-sdk.cmake

# Ensure no-exceptions for all WASI builds (WebAssembly doesn't support exceptions)
set(VCPKG_CXX_FLAGS "-fno-exceptions")
set(VCPKG_C_FLAGS "")
