// WASI stub implementations for Abseil threading primitives
// These provide no-op implementations since WASI doesn't support threading

#include <cstdlib>
#include <cstdint>

// Extern "C" for the C-style functions
extern "C" {

// Per-thread semaphore stubs (no-op for single-threaded WASI)
// Using unified signature for both wasip1 and wasip2
// Both work despite linker warnings since these functions are never called
void AbslInternalPerThreadSemPost_lts_20250814(int32_t /*identity*/) {
    // No-op: WASI is single-threaded
}

void AbslInternalPerThreadSemWait_lts_20250814(int32_t /*identity*/) {
    // No-op: WASI is single-threaded
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

    // Declare stub implementations as static methods
    static void* Alloc(unsigned long size);
    static void Free(void* ptr);
    static void* AllocWithArena(unsigned long size, Arena* arena);
};

// Implement the static methods outside the class
void* LowLevelAlloc::Alloc(unsigned long size) {
    return malloc(size);
}

void LowLevelAlloc::Free(void* ptr) {
    free(ptr);
}

void* LowLevelAlloc::AllocWithArena(unsigned long size, Arena* /*arena*/) {
    return malloc(size);
}

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
