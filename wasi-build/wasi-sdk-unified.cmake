set(CMAKE_SYSTEM_NAME WASI)
set(CMAKE_SYSTEM_VERSION 1)
set(CMAKE_SYSTEM_PROCESSOR wasm32)

set(WASI_SDK_PREFIX $ENV{WASI_SDK_PATH})

set(CMAKE_C_COMPILER ${WASI_SDK_PREFIX}/bin/clang)
set(CMAKE_CXX_COMPILER ${WASI_SDK_PREFIX}/bin/clang++)
set(CMAKE_AR ${WASI_SDK_PREFIX}/bin/llvm-ar)
set(CMAKE_RANLIB ${WASI_SDK_PREFIX}/bin/llvm-ranlib)

# Allow selection of WASI version via WASI_VERSION variable
# Default to wasip1 for backward compatibility
if(NOT DEFINED WASI_VERSION)
    set(WASI_VERSION "wasip1")
endif()

if(WASI_VERSION STREQUAL "wasip2")
    # WASI Preview 2 (wasip2) configuration
    set(CMAKE_C_COMPILER_TARGET wasm32-wasip2)
    set(CMAKE_CXX_COMPILER_TARGET wasm32-wasip2)

    message(STATUS "Configuring for wasip2")
else()
    # WASI Preview 1 (wasip1) configuration
    set(CMAKE_C_COMPILER_TARGET wasm32-wasi)
    set(CMAKE_CXX_COMPILER_TARGET wasm32-wasi)

    message(STATUS "Configuring for wasip1")
endif()

set(CMAKE_SYSROOT ${WASI_SDK_PREFIX}/share/wasi-sysroot)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# WASI specific flags (including emulated signal and process clocks support)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -D__wasi__ -D_WASI_EMULATED_PROCESS_CLOCKS -D_WASI_EMULATED_SIGNAL -DABSL_FORCE_WAITER_MODE=4")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D__wasi__ -D_WASI_EMULATED_PROCESS_CLOCKS -D_WASI_EMULATED_SIGNAL -DABSL_FORCE_WAITER_MODE=4 -fno-exceptions")

# For linking
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -lwasi-emulated-process-clocks -lwasi-emulated-signal")
