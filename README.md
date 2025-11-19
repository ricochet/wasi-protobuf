# WASI Proto - C++ Protobuf Example

A barebones C++ project demonstrating Protocol Buffers encoding and decoding with support for both native and WebAssembly (WASI) builds.

## Prerequisites

### Native Build
- CMake 3.15 or higher
- C++17 compatible compiler
- Protocol Buffers library (libprotobuf)
- Google Test framework

### WASI Build
- WASI SDK 28.0 or higher
- vcpkg package manager
- wasmtime or another WASI runtime (for testing)

## Installing Dependencies

### Native Dependencies

**macOS (Homebrew):**
```bash
brew install protobuf googletest
```

**Ubuntu/Debian:**
```bash
sudo apt-get install -y libprotobuf-dev protobuf-compiler libgtest-dev
```

**Fedora:**
```bash
sudo dnf install protobuf-devel protobuf-compiler gtest-devel
```

### WASI Dependencies

1. **WASI SDK**: Download from https://github.com/WebAssembly/wasi-sdk/releases
2. **vcpkg**:
   ```bash
   git clone https://github.com/microsoft/vcpkg "$HOME/vcpkg"
   $HOME/vcpkg/bootstrap-vcpkg.sh
   ```

## Project Structure

```
wasi-proto/
├── CMakeLists.txt           # Native build configuration
├── person.proto            # Protobuf message definition
├── src/
│   └── main.cpp           # Main executable demonstrating encode/decode
├── test/
│   └── person_test.cpp    # Unit tests for protobuf operations
└── wasi-build/
    ├── CMakeLists.txt     # WASI build configuration
    ├── wasi-sdk.cmake     # WASI toolchain file (in repo for reproducibility)
    ├── wasm32-wasip1.cmake # vcpkg triplet (in repo for reproducibility)
    └── wasi_stubs.cpp     # Threading stubs for WASI
```

## Building

Both native and WASI builds now use vcpkg protobuf (v5.29.5) for consistency.

**Generate protobuf files** (required before first build):
```bash
$HOME/vcpkg/installed/arm64-osx/tools/protobuf/protoc --cpp_out=. person.proto
```

### Native Build

```bash
# Configure with vcpkg toolchain
cmake -B build -DCMAKE_TOOLCHAIN_FILE=$HOME/vcpkg/scripts/buildsystems/vcpkg.cmake

# Build the project
cmake --build build
```

### WASI Build

```bash
cd wasi-build

# Set WASI SDK path
export WASI_SDK_PATH=/path/to/wasi-sdk

# Configure with vcpkg using in-repo toolchain and triplet (for reproducibility)
cmake -B build \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_TOOLCHAIN_FILE=$HOME/vcpkg/scripts/buildsystems/vcpkg.cmake \
  -DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=$(pwd)/wasi-sdk.cmake \
  -DVCPKG_OVERLAY_TRIPLETS=. \
  -DVCPKG_TARGET_TRIPLET=wasm32-wasip1

# Build
cmake --build build
```

**Note**: All toolchain and triplet files are in the repository (wasi-build/ directory), making the project fully reproducible without requiring custom vcpkg configuration. The `-fno-exceptions` flag is automatically applied as WebAssembly doesn't support C++ exceptions.

## Running

### Native Build

**Main Program:**
```bash
./build/main
```

**Tests:**
```bash
./build/person_test
# Or use CTest
cd build && ctest --verbose
```

### WASI Build

```bash
wasmtime run wasi-build/build/main
```

**Expected Output:**
```
Original Person:
  Name: John Doe
  ID: 12345
  Email: john.doe@example.com

Serialized to 35 bytes

Decoded Person:
  Name: John Doe
  ID: 12345
  Email: john.doe@example.com
```

## What It Does

1. **person.proto**: Defines a simple `Person` message with name, id, and email fields
2. **main.cpp**: Creates a Person, encodes it to bytes, decodes it back, and displays the results
3. **person_test.cpp** (native only): Unit tests validating encoding/decoding

## WASI Build Details

The WASI build required several special configurations:
- Disabled C++ exceptions (`-fno-exceptions`)
- Defined `__wasi__` to enable WASI-specific code paths in Abseil
- Provided threading stubs for single-threaded WASI environment
- Used `ABSL_FORCE_WAITER_MODE=4` to minimize threading requirements

## Cleaning

```bash
# Native build
rm -rf build

# WASI build
rm -rf wasi-build/build
```
