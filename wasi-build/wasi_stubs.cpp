// WASI stub implementations for Abseil threading primitives
// These provide no-op implementations since WASI doesn't support threading

#include <cstdlib>
#include <cstdint>

// Extern "C" for the C-style functions
extern "C" {

// Per-thread semaphore stubs (no-op for single-threaded WASI)
// Signature from linker warning: (i32) -> void
void AbslInternalPerThreadSemPost_lts_20250814(int32_t /*identity*/) {
    // No-op: WASI is single-threaded
}

void AbslInternalPerThreadSemWait_lts_20250814(int32_t /*identity*/) {
    // No-op: WASI is single-threaded
}

// LowLevelAlloc functions with exact mangled names
// _ZN4absl12lts_2025081413base_internal13LowLevelAlloc5AllocEm
void* _ZN4absl12lts_2025081413base_internal13LowLevelAlloc5AllocEm(unsigned long size) {
    return malloc(size);
}

// _ZN4absl12lts_2025081413base_internal13LowLevelAlloc4FreeEPv
void _ZN4absl12lts_2025081413base_internal13LowLevelAlloc4FreeEPv(void* ptr) {
    free(ptr);
}

// _ZN4absl12lts_2025081413base_internal13LowLevelAlloc14AllocWithArenaEmPNS1_5ArenaE
void* _ZN4absl12lts_2025081413base_internal13LowLevelAlloc14AllocWithArenaEmPNS1_5ArenaE(
    unsigned long size, void* /*arena*/) {
    return malloc(size);
}

} // extern "C"

// C++ namespace for remaining Abseil internal functions
namespace absl {
namespace lts_20250814 {
namespace base_internal {

// Forward declarations
class LowLevelAlloc {
public:
    class Arena {};
};

// Signal-safe arena stubs
static LowLevelAlloc::Arena g_sig_safe_arena;

void InitSigSafeArena() {
    // No-op: arena already statically initialized
}

LowLevelAlloc::Arena* SigSafeArena() {
    return &g_sig_safe_arena;
}

} // namespace base_internal

namespace synchronization_internal {

// Thread identity stub (single-threaded, return dummy value)
struct ThreadIdentity {
    int dummy;
};

static ThreadIdentity g_thread_identity = {0};

ThreadIdentity* CreateThreadIdentity() {
    return &g_thread_identity;
}

// GraphCycles stubs - minimal implementation
struct GraphId {
    int id;
};

class GraphCycles {
public:
    GraphCycles() {}
    ~GraphCycles() {}

    GraphId GetId(void* /*ptr*/) {
        return GraphId{0};
    }

    void RemoveNode(void* /*ptr*/) {}

    void* Ptr(GraphId /*id*/) {
        return nullptr;
    }

    bool InsertEdge(GraphId /*from*/, GraphId /*to*/) {
        return true;
    }

    void UpdateStackTrace(GraphId /*id*/, int /*priority*/,
                         int (*/*get_stack_trace*/)(void**, int)) {}
};

} // namespace synchronization_internal
} // namespace lts_20250814
} // namespace absl
