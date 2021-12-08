import Foundation

/// Headers
public struct Headers: Codable, Equatable {
    /// Determine how to resolve cases,
    /// when the same files found in different header scopes
    public enum AutomaticExclusionRule: Int, Codable {
        /// Resolving by manually entered
        /// excluded list in each scope.
        ///
        /// Default behavior
        case none

        /// Project headers = all found - private headers - public headers
        ///
        /// Order of tuist search:
        ///  1) Public headers
        ///  2) Private headers (with auto exludes all found public headers)
        ///  3) Project headers (with excluding public/private headers)
        ///
        ///  Also tuist doesn't ignore all excludes,
        ///  which had been set by `excluding` param
        case projectExcludesPrivateAndPublic

        /// Public headers = all found - private headers - project headers
        ///
        /// Order of tuist search (reverse search):
        ///  1) Project headers
        ///  2) Private headers (with auto exludes all found project headers)
        ///  3) Public headers (with excluding project/private headers)
        ///
        ///  Also tuist doesn't ignore all excludes,
        ///  which had been set by `excluding` param
        case publicExcludesPrivateAndProject
    }

    /// Relative path to public headers.
    public let `public`: FileList?

    /// Relative path to private headers.
    public let `private`: FileList?

    /// Relative path to project headers.
    public let project: FileList?

    /// Determine how to resolve cases,
    /// when the same files found in different header scopes
    public let exclusionRule: AutomaticExclusionRule

    public init(public: FileList? = nil,
                private: FileList? = nil,
                project: FileList? = nil,
                exclusionRule: AutomaticExclusionRule = .none)
    {
        self.public = `public`
        self.private = `private`
        self.project = project
        self.exclusionRule = exclusionRule
    }
}
