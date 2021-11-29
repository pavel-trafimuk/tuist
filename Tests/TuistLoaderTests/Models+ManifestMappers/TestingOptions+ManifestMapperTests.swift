import Foundation
import ProjectDescription
import TSCBasic
import TuistCore
import TuistGraph
import TuistSupport
import XCTest

@testable import TuistLoader
@testable import TuistSupportTesting

final class TestingOptionsManifestMapperTests: TuistUnitTestCase {
    private typealias Manifest = ProjectDescription.Config.GenerationOptions.TestingOptions

    func test_from_returnsTheCorrectValue_whenManifestIncludesAllOptions() throws {
        // Given
        let manifest: Manifest = [.parallelizable, .randomExecutionOrdering]

        // When
        let got = try TuistGraph.TestingOptions.from(manifest: manifest)

        // Then
        XCTAssertEqual([.parallelizable, .randomExecutionOrdering], got)
    }

    func test_from_returnsTheCorrectValue_whenManifestIsEmpty() throws {
        // Given
        let manifest: Manifest = []

        // When
        let got = try TuistGraph.TestingOptions.from(manifest: manifest)

        // Then
        XCTAssertEqual([], got)
    }
}
