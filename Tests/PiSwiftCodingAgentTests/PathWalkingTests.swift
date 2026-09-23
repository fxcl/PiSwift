import Foundation
import Testing
@testable import PiSwiftCodingAgent

/// Regression for the bootstrap hang: upward directory walks used
/// `deletingLastPathComponent()` with a `parent == self` termination check,
/// which never fires on Darwin because `/` yields `/..`, which yields
/// `/../..`. Any walk starting outside a matching directory spun forever.
///
/// The invariant worth pinning is not the exact parent of each shape but that
/// repeated application always reaches `nil`.
@Test func parentDirectoryPathTerminatesAtVolumeRoot() {
    let startDirs = [
        "/",
        "///",
        "/..",
        "/../..",
        "/Users",
        "/Users/",
        "/Users/vec/.omp/sessions",
        "/Users/vec/.omp/sessions/",
        "/tmp/foo/../bar",
    ]

    for start in startDirs {
        var dir: String? = start
        var hops = 0
        while let current = dir {
            hops += 1
            // Lexical depth is the ceiling; anything past it means the walk is
            // growing instead of climbing.
            #expect(hops <= 64, "walk from \(start) did not terminate")
            dir = parentDirectoryPath(of: current)
        }
    }
}

@Test func parentDirectoryPathReturnsImmediateParent() {
    #expect(parentDirectoryPath(of: "/Users/vec/.omp/sessions") == "/Users/vec/.omp")
    #expect(parentDirectoryPath(of: "/Users/vec/.omp/sessions/") == "/Users/vec/.omp")
    #expect(parentDirectoryPath(of: "/Users") == "/")
    #expect(parentDirectoryPath(of: "/tmp") == "/")
}

@Test func parentDirectoryPathReturnsNilAtOrAboveRoot() {
    #expect(parentDirectoryPath(of: "/") == nil)
    #expect(parentDirectoryPath(of: "///") == nil)
    #expect(parentDirectoryPath(of: "/..") == nil)
    #expect(parentDirectoryPath(of: "/../..") == nil)
}

@Test func parentDirectoryPathIgnoresInteriorEmptySlashRuns() {
    // Redundant separators are lexical noise and must not cost extra hops.
    #expect(parentDirectoryPath(of: "/tmp//foo") == "/tmp")
}
