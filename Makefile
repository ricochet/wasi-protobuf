# Makefile for WASI Protobuf - Native and WASI builds
# Supports native, wasip1, and wasip2 targets

# Configuration
WASI_SDK_PATH ?= /opt/wasi-sdk-28.0-arm64-macos
VCPKG_ROOT ?= $(HOME)/vcpkg
BUILD_TYPE ?= Release

# Directories
NATIVE_BUILD_DIR = build
WASI_BUILD_DIR = wasi-build
WASIP1_BUILD_DIR = $(WASI_BUILD_DIR)/build-wasip1
WASIP2_BUILD_DIR = $(WASI_BUILD_DIR)/build-wasip2

# vcpkg configuration
TOOLCHAIN_FILE = $(VCPKG_ROOT)/scripts/buildsystems/vcpkg.cmake
WASI_CHAINLOAD_TOOLCHAIN = $(CURDIR)/$(WASI_BUILD_DIR)/wasi-sdk-unified.cmake
WASI_OVERLAY_TRIPLETS = $(CURDIR)/$(WASI_BUILD_DIR)

# Phony targets
.PHONY: all clean help native wasip1 wasip2 \
	run run-native run-wasip1 run-wasip2 \
	test install-deps-native install-deps-wasip1 install-deps-wasip2 \
	protobuf

# Default target
all: native wasip1 wasip2

# Help target
help:
	@echo "WASI Protobuf Build Targets:"
	@echo ""
	@echo "Build targets:"
	@echo "  make all              - Build native and wasip1 (default)"
	@echo "  make native           - Build native x86_64/arm64 binary"
	@echo "  make wasip1           - Build WASIP1 core module"
	@echo "  make wasip2           - Build WASIP2 component"
	@echo ""
	@echo "Run targets:"
	@echo "  make run              - Run native binary"
	@echo "  make run-native       - Run native binary"
	@echo "  make run-wasip1       - Run wasip1 with wasmtime"
	@echo "  make run-wasip2       - Run wasip2 component with wasmtime"
	@echo "  make test             - Run native unit tests"
	@echo ""
	@echo "Dependency targets:"
	@echo "  make install-deps-native  - Install native vcpkg dependencies"
	@echo "  make install-deps-wasip1  - Install WASI Preview 1 dependencies"
	@echo "  make install-deps-wasip2  - Install WASI 0.2 dependencies"
	@echo "  make protobuf         - Generate protobuf files"
	@echo ""
	@echo "Utility targets:"
	@echo "  make clean            - Remove all build directories"
	@echo "  make help             - Show this help message"
	@echo ""
	@echo "Build outputs:"
	@echo "  native:  $(NATIVE_BUILD_DIR)/main"
	@echo "  wasip1:  $(WASIP1_BUILD_DIR)/main.wasm (WASI Preview 1 core module)"
	@echo "  wasip2:  $(WASIP2_BUILD_DIR)/main.wasm (WASI 0.2 component)"
	@echo ""
	@echo "Environment Variables:"
	@echo "  WASI_SDK_PATH=$(WASI_SDK_PATH)"
	@echo "  VCPKG_ROOT=$(VCPKG_ROOT)"
	@echo "  BUILD_TYPE=$(BUILD_TYPE)"

# Generate protobuf files
protobuf:
	@echo "Generating protobuf files..."
	$(VCPKG_ROOT)/installed/arm64-osx/tools/protobuf/protoc --cpp_out=. person.proto
	@echo "✓ Protobuf files generated"

# Install native dependencies
install-deps-native:
	@echo "Installing native dependencies with vcpkg..."
	$(VCPKG_ROOT)/vcpkg install protobuf googletest
	@echo "✓ Native dependencies installed"

# Install WASI dependencies
install-deps-wasip1:
	@echo "Installing protobuf dependencies for wasip1..."
	WASI_SDK_PATH=$(WASI_SDK_PATH) \
		$(VCPKG_ROOT)/vcpkg install protobuf \
		--triplet=wasm32-wasip1 \
		--overlay-triplets=$(WASI_OVERLAY_TRIPLETS)

install-deps-wasip2:
	@echo "Installing protobuf dependencies for wasip2..."
	WASI_SDK_PATH=$(WASI_SDK_PATH) \
		$(VCPKG_ROOT)/vcpkg install protobuf \
		--triplet=wasm32-wasip2 \
		--overlay-triplets=$(WASI_OVERLAY_TRIPLETS)

# Configure native build
$(NATIVE_BUILD_DIR)/Makefile: CMakeLists.txt
	@echo "Configuring native build..."
	cmake -B $(NATIVE_BUILD_DIR) \
		-DCMAKE_BUILD_TYPE=$(BUILD_TYPE) \
		-DCMAKE_TOOLCHAIN_FILE=$(TOOLCHAIN_FILE)

# Configure WASI builds
$(WASIP1_BUILD_DIR)/Makefile: $(WASI_BUILD_DIR)/CMakeLists.txt $(WASI_BUILD_DIR)/wasi-sdk-unified.cmake $(WASI_BUILD_DIR)/wasm32-wasip1.cmake
	@echo "Configuring wasip1 build..."
	WASI_SDK_PATH=$(WASI_SDK_PATH) \
		cmake -S $(WASI_BUILD_DIR) -B $(WASIP1_BUILD_DIR) \
		-DCMAKE_BUILD_TYPE=$(BUILD_TYPE) \
		-DCMAKE_TOOLCHAIN_FILE=$(TOOLCHAIN_FILE) \
		-DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=$(WASI_CHAINLOAD_TOOLCHAIN) \
		-DVCPKG_OVERLAY_TRIPLETS=$(WASI_OVERLAY_TRIPLETS) \
		-DVCPKG_TARGET_TRIPLET=wasm32-wasip1 \
		-DWASI_VERSION=wasip1

$(WASIP2_BUILD_DIR)/Makefile: $(WASI_BUILD_DIR)/CMakeLists.txt $(WASI_BUILD_DIR)/wasi-sdk-unified.cmake $(WASI_BUILD_DIR)/wasm32-wasip2.cmake
	@echo "Configuring wasip2 build..."
	WASI_SDK_PATH=$(WASI_SDK_PATH) \
		cmake -S $(WASI_BUILD_DIR) -B $(WASIP2_BUILD_DIR) \
		-DCMAKE_BUILD_TYPE=$(BUILD_TYPE) \
		-DCMAKE_TOOLCHAIN_FILE=$(TOOLCHAIN_FILE) \
		-DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=$(WASI_CHAINLOAD_TOOLCHAIN) \
		-DVCPKG_OVERLAY_TRIPLETS=$(WASI_OVERLAY_TRIPLETS) \
		-DVCPKG_TARGET_TRIPLET=wasm32-wasip2 \
		-DWASI_VERSION=wasip2

# Build targets
native: $(NATIVE_BUILD_DIR)/Makefile
	@echo "Building native..."
	cmake --build $(NATIVE_BUILD_DIR)
	@echo "✓ Native build complete: $(NATIVE_BUILD_DIR)/main"

wasip1: $(WASIP1_BUILD_DIR)/Makefile
	@echo "Building wasip1..."
	cmake --build $(WASIP1_BUILD_DIR)
	@echo "✓ wasip1 build complete: $(WASIP1_BUILD_DIR)/main.wasm"

wasip2: $(WASIP2_BUILD_DIR)/Makefile
	@echo "Building wasip2..."
	cmake --build $(WASIP2_BUILD_DIR)
	@echo "✓ wasip2 build complete: $(WASIP2_BUILD_DIR)/main.wasm"

# Run targets
run: run-native

run-native: native
	@echo "Running native binary..."
	./$(NATIVE_BUILD_DIR)/main

run-wasip1: wasip1
	@echo "Running wasip1 binary with wasmtime..."
	wasmtime run $(WASIP1_BUILD_DIR)/main.wasm

run-wasip2: wasip2
	@echo "Running wasip2 component with wasmtime..."
	@echo "Note: wasip2 components require WASI 0.2 runtime support"
	wasmtime run -Scli $(WASIP2_BUILD_DIR)/main.wasm || true

# Test target
test: native
	@echo "Running tests..."
	cd $(NATIVE_BUILD_DIR) && ctest --verbose

# Clean all build artifacts
clean:
	@echo "Cleaning all build directories..."
	rm -rf $(NATIVE_BUILD_DIR) $(WASIP1_BUILD_DIR) $(WASIP2_BUILD_DIR)
	@echo "✓ Clean complete"

# Rebuild targets
rebuild-native: clean native
rebuild-wasip1:
	@echo "Cleaning wasip1 build..."
	rm -rf $(WASIP1_BUILD_DIR)
	@$(MAKE) wasip1

rebuild-wasip2:
	@echo "Cleaning wasip2 build..."
	rm -rf $(WASIP2_BUILD_DIR)
	@$(MAKE) wasip2

rebuild: clean all
