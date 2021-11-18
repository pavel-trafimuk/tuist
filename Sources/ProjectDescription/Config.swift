import Foundation

/// This model allows to configure Tuist.
public struct Config: Codable, Equatable {
    /// Contains options related to the project generation.
    public enum GenerationOptions: Codable, Equatable {
        /// Contains options for code coverage
        public enum CodeCoverageMode: Codable, Equatable {
            /// Gather code coverage for all targets
            case all
            /// Gather code coverage only for targets, that have code coverage enabled at least in one scheme
            case relevant
            /// Gather code coverage only for given targets
            case targets([TargetReference])
        }

        public struct TestingOptions: OptionSet, Codable, Equatable {
            public let rawValue: Int

            public init(rawValue: Int) {
                self.rawValue = rawValue
            }

            public static let parallelizable = TestingOptions(rawValue: 1 << 0)
            public static let randomExecutionOrdering = TestingOptions(rawValue: 1 << 1)

            static let `default`: TestingOptions = []
        }

        /// Tuist generates the project with the specific name on disk instead of using the project name.
        case xcodeProjectName(TemplateString)

        /// Tuist generates the project with the specific organization name.
        case organizationName(String)

        /// Tuist generates the project with the specific development region.
        case developmentRegion(String)

        /// Tuist generates the project only with custom specified schemes, autogenerated default
        case disableAutogeneratedSchemes

        /// Tuist does not synthesize resource accessors
        case disableSynthesizedResourceAccessors

        /// Tuist disables echoing the ENV in shell script build phases
        case disableShowEnvironmentVarsInScriptPhases

        /// When passed, Tuist will enable code coverage for autogenerated default schemes according to given mode
        case enableCodeCoverage(CodeCoverageMode)

        case testingOptions(TestingOptions)

        /// When passed, Tuist will enable code coverage for autogenerated default schemes
        public static let enableCodeCoverage = GenerationOptions.enableCodeCoverage(.all)

        /// When passed, Xcode will resolve its Package Manager dependencies using the system-defined
        /// accounts (e.g. git) instead of the Xcode-defined accounts
        case resolveDependenciesWithSystemScm

        /// Disables locking Swift packages. This can speed up generation but does increase risk if packages are not locked
        /// in their declarations.
        case disablePackageVersionLocking

        /// Disables generating Bundle accessors.
        case disableBundleAccessors

        /// Allows to suppress warnings in Xcode about updates to recommended settings added in or below the specified Xcode version. The warnings appear when Xcode version has been upgraded.
        /// It is recommended to set the version option to Xcode's version that is used for development of a project, for example `.lastUpgradeCheck(Version(13, 0, 0))` for Xcode 13.0.0.
        case lastXcodeUpgradeCheck(Version)
    }

    /// Generation options.
    public let generationOptions: [GenerationOptions]

    /// List of Xcode versions that the project supports.
    public let compatibleXcodeVersions: CompatibleXcodeVersions

    /// List of `Plugin`s used to extend Tuist.
    public let plugins: [PluginLocation]

    /// Cloud configuration.
    public let cloud: Cloud?

    /// Cache configuration.
    public let cache: Cache?

    /// The version of Swift that will be used by Tuist.
    /// If `nil` is passed then Tuist will use the environment’s version.
    public let swiftVersion: Version?

    /// Initializes the tuist configuration.
    ///
    /// - Parameters:
    ///   - compatibleXcodeVersions: List of Xcode versions the project is compatible with.
    ///   - cloud: Cloud configuration.
    ///   - cache: Cache configuration.
    ///   - swiftVersion: The version of Swift that will be used by Tuist.
    ///   - plugins: A list of plugins to extend Tuist.
    ///   - generationOptions: List of options to use when generating the project.
    public init(
        compatibleXcodeVersions: CompatibleXcodeVersions = .all,
        cloud: Cloud? = nil,
        cache: Cache? = nil,
        swiftVersion: Version? = nil,
        plugins: [PluginLocation] = [],
        generationOptions: [GenerationOptions]
    ) {
        self.compatibleXcodeVersions = compatibleXcodeVersions
        self.plugins = plugins
        self.generationOptions = generationOptions
        self.cloud = cloud
        self.cache = cache
        self.swiftVersion = swiftVersion
        dumpIfNeeded(self)
    }
}

extension Config.GenerationOptions {
    enum CodingKeys: String, CodingKey {
        case xcodeProjectName
        case organizationName
        case developmentRegion
        case disableAutogeneratedSchemes
        case disableSynthesizedResourceAccessors
        case disableShowEnvironmentVarsInScriptPhases
        case enableCodeCoverage
        case testingOptions
        case resolveDependenciesWithSystemScm
        case disablePackageVersionLocking
        case disableBundleAccessors
        case lastXcodeUpgradeCheck
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.allKeys.contains(.xcodeProjectName), try container.decodeNil(forKey: .xcodeProjectName) == false {
            var associatedValues = try container.nestedUnkeyedContainer(forKey: .xcodeProjectName)
            let templateProjectName = try associatedValues.decode(TemplateString.self)
            self = .xcodeProjectName(templateProjectName)
        } else if container.allKeys.contains(.organizationName), try container.decodeNil(forKey: .organizationName) == false {
            var associatedValues = try container.nestedUnkeyedContainer(forKey: .organizationName)
            let organizationName = try associatedValues.decode(String.self)
            self = .organizationName(organizationName)
        } else if container.allKeys.contains(.developmentRegion), try container.decodeNil(forKey: .developmentRegion) == false {
            var associatedValues = try container.nestedUnkeyedContainer(forKey: .developmentRegion)
            let developmentRegion = try associatedValues.decode(String.self)
            self = .developmentRegion(developmentRegion)
        } else if container.allKeys.contains(.disableAutogeneratedSchemes), try container.decode(Bool.self, forKey: .disableAutogeneratedSchemes) {
            self = .disableAutogeneratedSchemes
        } else if container.allKeys.contains(.disableSynthesizedResourceAccessors),
            try container.decode(Bool.self, forKey: .disableSynthesizedResourceAccessors)
        {
            self = .disableSynthesizedResourceAccessors
        } else if container.allKeys.contains(.disableShowEnvironmentVarsInScriptPhases),
            try container.decode(Bool.self, forKey: .disableShowEnvironmentVarsInScriptPhases)
        {
            self = .disableShowEnvironmentVarsInScriptPhases
        } else if container.allKeys.contains(.enableCodeCoverage) {
            let mode = try container.decode(CodeCoverageMode.self, forKey: .enableCodeCoverage)
            self = .enableCodeCoverage(mode)
        } else if container.allKeys.contains(.testingOptions) {
            let options = try container.decode(TestingOptions.self, forKey: .testingOptions)
            self = .testingOptions(options)
        } else if container.allKeys.contains(.disablePackageVersionLocking), try container.decode(Bool.self, forKey: .disablePackageVersionLocking) {
            self = .disablePackageVersionLocking
        } else if container.allKeys.contains(.resolveDependenciesWithSystemScm),
            try container.decode(Bool.self, forKey: .resolveDependenciesWithSystemScm)
        {
            self = .resolveDependenciesWithSystemScm
        } else if container.allKeys.contains(.disableBundleAccessors),
            try container.decode(Bool.self, forKey: .disableBundleAccessors)
        {
            self = .disableBundleAccessors
        } else if container.allKeys.contains(.lastXcodeUpgradeCheck), try container.decodeNil(forKey: .lastXcodeUpgradeCheck) == false {
            var associatedValues = try container.nestedUnkeyedContainer(forKey: .lastXcodeUpgradeCheck)
            let version = try associatedValues.decode(Version.self)
            self = .lastXcodeUpgradeCheck(version)
        } else {
            throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Unknown enum case"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .xcodeProjectName(templateProjectName):
            var associatedValues = container.nestedUnkeyedContainer(forKey: .xcodeProjectName)
            try associatedValues.encode(templateProjectName)
        case let .organizationName(name):
            var associatedValues = container.nestedUnkeyedContainer(forKey: .organizationName)
            try associatedValues.encode(name)
        case let .developmentRegion(developmentRegion):
            var associatedValues = container.nestedUnkeyedContainer(forKey: .developmentRegion)
            try associatedValues.encode(developmentRegion)
        case .disableAutogeneratedSchemes:
            try container.encode(true, forKey: .disableAutogeneratedSchemes)
        case .disableSynthesizedResourceAccessors:
            try container.encode(true, forKey: .disableSynthesizedResourceAccessors)
        case .disableShowEnvironmentVarsInScriptPhases:
            try container.encode(true, forKey: .disableShowEnvironmentVarsInScriptPhases)
        case let .enableCodeCoverage(mode):
            try container.encode(mode, forKey: .enableCodeCoverage)
        case let .testingOptions(options):
            try container.encode(options, forKey: .testingOptions)
        case .resolveDependenciesWithSystemScm:
            try container.encode(true, forKey: .resolveDependenciesWithSystemScm)
        case .disablePackageVersionLocking:
            try container.encode(true, forKey: .disablePackageVersionLocking)
        case .disableBundleAccessors:
            try container.encode(true, forKey: .disableBundleAccessors)
        case let .lastXcodeUpgradeCheck(version):
            var associatedValues = container.nestedUnkeyedContainer(forKey: .lastXcodeUpgradeCheck)
            try associatedValues.encode(version)
        }
    }
}

extension Config.GenerationOptions.CodeCoverageMode {
    enum CodingKeys: String, CodingKey {
        case all
        case relevant
        case targets
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.allKeys.contains(.all), try container.decode(Bool.self, forKey: .all) {
            self = .all
        } else if container.allKeys.contains(.relevant), try container.decode(Bool.self, forKey: .relevant) {
            self = .relevant
        } else if container.allKeys.contains(.targets) {
            let targets = try container.decode([TargetReference].self, forKey: .targets)
            self = .targets(targets)
        } else {
            fatalError()
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .all:
            try container.encode(true, forKey: .all)
        case .relevant:
            try container.encode(true, forKey: .relevant)
        case let .targets(targets):
            try container.encode(targets, forKey: .targets)
        }
    }
}
