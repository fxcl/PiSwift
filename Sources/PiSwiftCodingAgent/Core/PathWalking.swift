import Foundation

/// Lexical parent of an absolute path, or `nil` once the volume root is reached.
///
/// An upward directory walk cannot terminate on `deletingLastPathComponent()`
/// alone. On Darwin, `/` yields `/..`, which yields `/../..`, and so on, so a
/// `parent == self` check never fires: a walk that starts outside any matching
/// directory spins forever on a path that grows without bound and burns a core
/// doing it.
///
/// `standardizedFileURL` collapses `~`, redundant separators and `.`
/// lexically, and a POSIX root is the only absolute path with a single path
/// component, which gives a termination check that holds for every path shape.
func parentDirectoryPath(of path: String) -> String? {
    let standardized = URL(fileURLWithPath: path).standardizedFileURL
    guard standardized.pathComponents.count > 1 else { return nil }
    return standardized.deletingLastPathComponent().path
}
