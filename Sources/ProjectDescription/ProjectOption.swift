import Foundation

/// Additional options related to the `Project`
public enum ProjectOption: Codable, Equatable {
    /// Defines how to generate automatic schemes
    case automaticSchemesOptions(AutomaticSchemesOptions)

    /// Disables generating Bundle accessors.
    case disableBundleAccessors

    /// Disable the synthesized resource accessors generation
    case disableSynthesizedResourceAccessors

    /// Text settings to override user ones for current project
    ///
    /// - Parameters:
    ///   - usesTabs: Use tabs over spaces.
    ///   - indentWidth: Indent width.
    ///   - tabWidth: Tab width.
    ///   - wrapsLines: Wrap lines.
    case textSettings(
        usesTabs: Bool? = nil,
        indentWidth: UInt? = nil,
        tabWidth: UInt? = nil,
        wrapsLines: Bool? = nil
    )
}

// MARK: - AutomaticSchemesOptions

extension ProjectOption {
    /// The automatic schemes options
    public enum AutomaticSchemesOptions: Codable, Equatable {
        /// Enable autogenerated schemes
        case enabled(
            codeCoverageEnabled: Bool = false,
            testingOptions: TestingOptions = []
        )

        /// Disable autogenerated schemes
        case disabled
    }
}
