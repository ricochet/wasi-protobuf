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
├── CMakeLists.txt              # Native build configuration
├── person.proto                # Protobuf message definition
├── src/
│   └── main.cpp               # Main executable demonstrating encode/decode
├── test/
│   └── person_test.cpp        # Unit tests for protobuf operations
└── wasi-build/
    ├── CMakeLists.txt         # WASI build configuration
    ├── Makefile               # Build automation for wasip1 and wasip2
    ├── wasi-sdk-unified.cmake # Shared WASI toolchain file
    ├── wasm32-wasip1.cmake    # vcpkg triplet for WASI Preview 1
    ├── wasm32-wasip2.cmake    # vcpkg triplet for WASI 0.2
    └── wasi_stubs.cpp         # Threading stubs for WASI
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

The project supports both WASIP1 and WASIP2 builds. A root-level Makefile provides convenient build targets.

```bash
# Set WASI SDK path (adjust path for your system)
export WASI_SDK_PATH=/opt/wasi-sdk-28.0-arm64-macos

# Install dependencies (first time only)
make install-deps-wasip1  # For WASI Preview 1
make install-deps-wasip2  # For WASI 0.2

# Build WASI Preview 1 (core module)
make wasip1

# Build WASI 0.2 (component)
make wasip2

# Or build all (native + wasip1)
make all
```

**Build outputs:**
- `build-wasip1/main.wasm` - WASIP1 core module
- `build-wasip2/main.wasm` - WASIP2 component

**Note**:
- All toolchain and triplet files are in the repository (wasi-build/ directory), making the project fully reproducible
- The `-fno-exceptions` flag is automatically applied as WebAssembly doesn't support C++ exceptions
- wasip2 uses `wasm-component-ld` to build proper WASIP2 components
- Run `make help` to see all available targets

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

### WASI Builds

**WASI Preview 1:**
```bash
make run-wasip1
```

**WASI 0.2:**
```bash
make run-wasip2
```

**All targets:**
```bash
make run              # Run native binary
make run-native       # Run native binary
make run-wasip1       # Run WASI Preview 1
make run-wasip2       # Run WASI 0.2
make test             # Run native unit tests
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

Both WASI builds share common configurations:
- Disabled C++ exceptions (`-fno-exceptions`)
- Defined `__wasi__` to enable WASI-specific code paths in Abseil
- Provided threading stubs for single-threaded WASI environment
- Used `ABSL_FORCE_WAITER_MODE=4` to minimize threading requirements

### WASI Preview 1 vs WASI 0.2

**wasip1** (WASI Preview 1):
- Builds as a traditional WebAssembly core module
- Uses standard `wasm-ld` linker
- Compatible with most WASI runtimes
- Output: `build-wasip1/main.wasm`

**wasip2** (WASI 0.2):
- Builds as a WASI component using `wasm-component-ld`
- Uses WASI 0.2 component model interfaces
- Requires component-aware runtime (e.g., wasmtime with `-Scli`)
- Output: `build-wasip2/main.wasm`
- Larger binary size due to component model overhead

Both builds use separate vcpkg triplets to ensure proper dependency isolation.

## Cleaning

```bash
# Clean all builds (native + WASI)
make clean

# Or clean individually
rm -rf build                    # Native only
rm -rf wasi-build/build-wasip1  # WASIP1 only
rm -rf wasi-build/build-wasip2  # WASIP2 only
```
