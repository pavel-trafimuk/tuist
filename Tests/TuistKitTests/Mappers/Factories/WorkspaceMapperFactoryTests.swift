import Foundation
import TSCBasic
import TuistCoreTesting
import TuistGraph
import TuistLoader
import TuistSigning
import XCTest
@testable import TuistAutomation
@testable import TuistCore
@testable import TuistGenerator
@testable import TuistKit
@testable import TuistSupportTesting

final class WorkspaceMapperFactoryTests: TuistUnitTestCase {
    var projectMapperFactory: ProjectMapperFactory!
    var subject: WorkspaceMapperFactory!

    override func setUp() {
        super.setUp()
        projectMapperFactory = ProjectMapperFactory()
    }

    override func tearDown() {
        projectMapperFactory = nil
        subject = nil
        super.tearDown()
    }

    func test_default_contains_the_project_workspace_mapper() {
        // Given
        let config = Config.test(generationOptions: [
        ])
        subject =
            WorkspaceMapperFactory(projectMapper: SequentialProjectMapper(mappers: projectMapperFactory.default(config: config)))

        // When
        let got = subject.default(config: config)

        // Then
        XCTAssertContainsElementOfType(got, ProjectWorkspaceMapper.self)
    }

    func test_default_contains_the_tuist_workspace_identifier_mapper() {
        // Given
        let config = Config.test(generationOptions: [
        ])
        subject =
            WorkspaceMapperFactory(projectMapper: SequentialProjectMapper(mappers: projectMapperFactory.default(config: config)))

        // When
        let got = subject.default(config: config)

        // Then
        XCTAssertContainsElementOfType(got, TuistWorkspaceIdentifierMapper.self)
    }

    func test_default_contains_the_tide_template_macros_mapper() {
        // Given
        let config = Config.test(generationOptions: [
        ])
        subject =
            WorkspaceMapperFactory(projectMapper: SequentialProjectMapper(mappers: projectMapperFactory.default(config: config)))

        // When
        let got = subject.default(config: config)

        // Then
        XCTAssertContainsElementOfType(got, IDETemplateMacrosMapper.self)
    }

    func test_default_contains_the_autogenerated_project_scheme_mapper_when_autogenerated_schemes_are_enabled() {
        // Given
        let config = Config.test(generationOptions: [
        ])
        subject =
            WorkspaceMapperFactory(projectMapper: SequentialProjectMapper(mappers: projectMapperFactory.default(config: config)))

        // When
        let got = subject.default(config: config)

        // Then
        XCTAssertContainsElementOfType(got, AutogeneratedProjectSchemeWorkspaceMapper.self)
    }

    func test_default_contains_the_modulemap_mapper() {
        // Given
        let config = Config.test(generationOptions: [
        ])
        subject =
            WorkspaceMapperFactory(projectMapper: SequentialProjectMapper(mappers: projectMapperFactory.default(config: config)))

        // When
        let got = subject.default(config: config)

        // Then
        XCTAssertContainsElementOfType(got, ModuleMapMapper.self)
    }

    func test_default_contains_the_last_upgrade_version_mapper_when_the_configuration_is_set() {
        // Given
        let config = Config.test(generationOptions: [
            .lastUpgradeCheck("3.2.1"),
        ])
        subject =
            WorkspaceMapperFactory(projectMapper: SequentialProjectMapper(mappers: projectMapperFactory.default(config: config)))

        // When
        let got = subject.default(config: config)

        // Then
        let mapper = XCTAssertContainsElementOfType(got, LastUpgradeVersionWorkspaceMapper.self)
        XCTAssertEqual(mapper?.lastUpgradeVersion, "3.2.1")
    }

    func test_automation_contains_the_path_workspace_mapper() throws {
        // Given
        let workspaceDirectory = try temporaryPath()
        let config = Config.test(generationOptions: [
        ])
        subject =
            WorkspaceMapperFactory(projectMapper: SequentialProjectMapper(mappers: projectMapperFactory.default(config: config)))

        // When
        let got = subject.automation(
            config: config,
            workspaceDirectory: workspaceDirectory
        )

        // Then
        let mapper = XCTAssertContainsElementOfType(got, AutomationPathWorkspaceMapper.self)
        XCTAssertEqual(mapper?.workspaceDirectory, workspaceDirectory)
    }

    func test_automation_contains_the_autogenerated_project_scheme_workspace_mapper_even_if_autogenerated_schemes_are_disabled(
    ) throws {
        // Given
        let workspaceDirectory = try temporaryPath()
        let config = Config.test(generationOptions: [
            .disableAutogeneratedSchemes,
            .enableCodeCoverage(.all),
        ])
        subject =
            WorkspaceMapperFactory(projectMapper: SequentialProjectMapper(mappers: projectMapperFactory.default(config: config)))

        // When
        let got = subject.automation(
            config: config,
            workspaceDirectory: workspaceDirectory
        )

        // Then
        let mapper = XCTAssertContainsElementOfType(got, AutogeneratedProjectSchemeWorkspaceMapper.self)
        XCTAssertEqual(mapper?.codeCoverageMode, .all)
    }

    func test_cache_contains_the_generate_cacheable_schemes_workspace_mapper() throws {
        // Given
        let config = Config.test(generationOptions: [
            .disableAutogeneratedSchemes,
            .enableCodeCoverage(.all),
        ])
        let includedTargets = Set(arrayLiteral: "MyTarget")
        subject =
            WorkspaceMapperFactory(projectMapper: SequentialProjectMapper(mappers: projectMapperFactory.default(config: config)))

        // When
        let got = subject.cache(
            config: config,
            includedTargets: includedTargets
        )

        // Then
        let mapper = XCTAssertContainsElementOfType(got, GenerateCacheableSchemesWorkspaceMapper.self)
        XCTAssertEqual(mapper?.includedTargets, includedTargets)
    }
}
