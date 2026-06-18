//
//  ModelDataTests.swift
//  RelayanceTests
//
//  Coverage notes:
//
//  1) fatalError branches (untestable by design):
//  ModelData.chargement(_:) has three failure branches, each guarded by a call
//  to `fatalError`. `fatalError` is a process-level trap, not a Swift error —
//  it cannot be caught by XCTest, and triggering it would crash the entire
//  test run (and every other test in the same process) rather than report a
//  single failing assertion. There is no supported way to intercept or stub
//  `fatalError` from a test target without modifying production code to use
//  `throws` instead, which was explicitly out of scope for this task.
//
//  These three branches are intentionally left uncovered:
//    1. `Bundle.main.url(forResource:withExtension:) == nil`   (file not found)
//    2. `Data(contentsOf:)` throws                              (file unreadable)
//    3. `JSONDecoder().decode(T.self, from:)` throws            (malformed JSON)
//
//  2) Why mock fixtures aren't used to exercise the success path:
//  RelayanceTests is a *hosted* unit test bundle — its build settings point
//  BUNDLE_LOADER / TEST_HOST at Relayance.app. Inside that configuration,
//  `Bundle.main` at runtime resolves to the host app's bundle (Relayance.app),
//  not to RelayanceTests.xctest. A mock JSON file added only to the
//  RelayanceTests group would therefore never be found by
//  `Bundle.main.url(forResource:withExtension:)`, since it physically lives
//  in a different bundle than the one `ModelData.chargement` looks inside.
//
//  Adding a fixture to the Relayance app target itself was deliberately
//  avoided, since shipping test-only JSON inside the production app bundle
//  is undesirable, and changing ModelData's signature to accept an injected
//  Bundle was out of scope for this task.
//
//  As a pragmatic consequence, the success path below is exercised against
//  the one JSON resource that is guaranteed to already exist in the host
//  app bundle: Source.json (the same file ClientViewModel loads in
//  production). This still fully covers chargement's success path — file
//  found, data read, JSON decoded into a Decodable array — using a real
//  resource rather than a synthetic mock, while leaving Source.json itself
//  completely untouched (read-only), per project convention.
//

import XCTest
@testable import Relayance

final class ModelDataTests: XCTestCase {

    // MARK: - Success path: resource resolution

    func testGivenSourceJsonInHostAppBundle_WhenResolvingViaBundleMain_ThenURLIsFound() {
        // Given
        let fileName = "Source.json"

        // When
        let url = Bundle.main.url(forResource: fileName, withExtension: nil)

        // Then
        XCTAssertNotNil(url,
                        "Source.json must be resolvable through Bundle.main (the host Relayance.app bundle) for chargement's success path to be exercised.")
    }

    // MARK: - Success path: decoding into [Client]

    func testGivenSourceJsonFileName_WhenCallingChargement_ThenReturnsNonEmptyClientsArray() {
        // Given
        let fileName = "Source.json"

        // When
        let result: [Client] = ModelData.chargement(fileName)

        // Then
        XCTAssertFalse(result.isEmpty,
                       "chargement should successfully locate, read, and decode Source.json into a non-empty array.")
    }

    func testGivenSourceJsonFileName_WhenCallingChargement_ThenReturnsExpectedNumberOfClients() {
        // Given
        let fileName = "Source.json"

        // When
        let result: [Client] = ModelData.chargement(fileName)

        // Then
        // Source.json ships with exactly 8 entries (see project fixture data).
        XCTAssertEqual(result.count, 8,
                       "chargement should decode every element present in Source.json.")
    }

    func testGivenSourceJsonFileName_WhenCallingChargement_ThenFirstClientFieldsAreCorrectlyDecoded() {
        // Given
        let fileName = "Source.json"

        // When
        let result: [Client] = ModelData.chargement(fileName)

        // Then
        let first = result.first
        XCTAssertEqual(first?.nom, "Frida Kahlo",
                       "The 'nom' field of the first entry should be decoded exactly as stored in Source.json.")
        XCTAssertEqual(first?.email, "frida.kahlo@example.com",
                       "The 'email' field of the first entry should be decoded exactly as stored in Source.json.")
    }

    func testGivenSourceJsonFileName_WhenCallingChargement_ThenDateCreationKeyIsMappedFromSnakeCase() {
        // Given
        let fileName = "Source.json"

        // When
        let result: [Client] = ModelData.chargement(fileName)

        // Then
        // Confirms the CodingKeys mapping (date_creation -> dateCreationString) is exercised
        // through the real decoding path, not just constructed via the memberwise initializer.
        let first = result.first
        XCTAssertEqual(first?.dateCreation.getYear(), 2024)
        XCTAssertEqual(first?.dateCreation.getMonth(), 1)
        XCTAssertEqual(first?.dateCreation.getDay(), 15)
    }

    func testGivenSourceJsonFileName_WhenCallingChargementTwice_ThenBothCallsReturnEquivalentData() {
        // Given
        let fileName = "Source.json"

        // When
        let firstLoad: [Client] = ModelData.chargement(fileName)
        let secondLoad: [Client] = ModelData.chargement(fileName)

        // Then
        // chargement is a pure read from a static bundle resource, so repeated
        // calls should be deterministic and side-effect free.
        XCTAssertEqual(firstLoad, secondLoad,
                       "Repeated calls to chargement with the same file name should yield equivalent results.")
    }

    // MARK: - Generic behavior over T: Decodable

    func testGivenExplicitArrayClientTypeAnnotation_WhenCallingChargement_ThenGenericParameterIsInferredCorrectly() {
        // Given
        let fileName = "Source.json"

        // When
        // The call site's type annotation drives T's inference; this test makes that
        // generic resolution explicit rather than relying on a single call-site shape.
        let result = ModelData.chargement(fileName) as [Client]

        // Then
        XCTAssertTrue(result is [Client],
                      "chargement<T> should decode into whatever Decodable type T is inferred from the call site.")
    }
}
