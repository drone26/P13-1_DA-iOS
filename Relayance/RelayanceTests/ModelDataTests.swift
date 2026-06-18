//
//  ModelDataTests.swift
//  RelayanceTests
//
<<<<<<< HEAD
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
=======
//  Created by Mathieu ARRIO on 09/06/2026.
//
//  ModelData.chargement(_:bundle:) now throws ModelDataError instead of
//  calling fatalError, so all three failure branches are fully testable
//  here without crashing the test process. The `bundle` parameter defaults
//  to `.main` (unchanged for all production call sites) and is overridden
//  in the error-path tests below to point at controlled fixtures created
//  on disk for the duration of each test.
>>>>>>> fd60245 (test(unittests): improve coverage level)
//

import XCTest
@testable import Relayance

final class ModelDataTests: XCTestCase {

<<<<<<< HEAD
    // MARK: - Success path: resource resolution
=======
    // MARK: - Temporary fixture directory

    private var tempDirectoryURL: URL!
    private var tempBundle: Bundle!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("ModelDataTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        tempDirectoryURL = directory
        tempBundle = Bundle(url: directory)
    }

    override func tearDownWithError() throws {
        // Restore permissions before cleanup, in case a test left a file unreadable.
        if let tempDirectoryURL,
           let contents = try? FileManager.default.contentsOfDirectory(at: tempDirectoryURL, includingPropertiesForKeys: nil) {
            for fileURL in contents {
                try? FileManager.default.setAttributes([.posixPermissions: 0o644], ofItemAtPath: fileURL.path)
            }
        }
        if let tempDirectoryURL {
            try? FileManager.default.removeItem(at: tempDirectoryURL)
        }
        tempDirectoryURL = nil
        tempBundle = nil
        try super.tearDownWithError()
    }

    // MARK: - Success path: resource resolution (Bundle.main / Source.json)
>>>>>>> fd60245 (test(unittests): improve coverage level)

    func testGivenSourceJsonInHostAppBundle_WhenResolvingViaBundleMain_ThenURLIsFound() {
        // Given
        let fileName = "Source.json"

        // When
        let url = Bundle.main.url(forResource: fileName, withExtension: nil)

        // Then
        XCTAssertNotNil(url,
                        "Source.json must be resolvable through Bundle.main (the host Relayance.app bundle) for chargement's success path to be exercised.")
    }

<<<<<<< HEAD
    // MARK: - Success path: decoding into [Client]

    func testGivenSourceJsonFileName_WhenCallingChargement_ThenReturnsNonEmptyClientsArray() {
=======
    // MARK: - Success path: decoding into [Client] via the default Bundle.main

    func testGivenSourceJsonFileName_WhenCallingChargement_ThenReturnsNonEmptyClientsArray() throws {
>>>>>>> fd60245 (test(unittests): improve coverage level)
        // Given
        let fileName = "Source.json"

        // When
<<<<<<< HEAD
        let result: [Client] = ModelData.chargement(fileName)
=======
        let result: [Client] = try ModelData.chargement(fileName)
>>>>>>> fd60245 (test(unittests): improve coverage level)

        // Then
        XCTAssertFalse(result.isEmpty,
                       "chargement should successfully locate, read, and decode Source.json into a non-empty array.")
    }

<<<<<<< HEAD
    func testGivenSourceJsonFileName_WhenCallingChargement_ThenReturnsExpectedNumberOfClients() {
=======
    func testGivenSourceJsonFileName_WhenCallingChargement_ThenReturnsExpectedNumberOfClients() throws {
>>>>>>> fd60245 (test(unittests): improve coverage level)
        // Given
        let fileName = "Source.json"

        // When
<<<<<<< HEAD
        let result: [Client] = ModelData.chargement(fileName)

        // Then
        // Source.json ships with exactly 8 entries (see project fixture data).
=======
        let result: [Client] = try ModelData.chargement(fileName)

        // Then
>>>>>>> fd60245 (test(unittests): improve coverage level)
        XCTAssertEqual(result.count, 8,
                       "chargement should decode every element present in Source.json.")
    }

<<<<<<< HEAD
    func testGivenSourceJsonFileName_WhenCallingChargement_ThenFirstClientFieldsAreCorrectlyDecoded() {
=======
    func testGivenSourceJsonFileName_WhenCallingChargement_ThenFirstClientFieldsAreCorrectlyDecoded() throws {
>>>>>>> fd60245 (test(unittests): improve coverage level)
        // Given
        let fileName = "Source.json"

        // When
<<<<<<< HEAD
        let result: [Client] = ModelData.chargement(fileName)
=======
        let result: [Client] = try ModelData.chargement(fileName)
>>>>>>> fd60245 (test(unittests): improve coverage level)

        // Then
        let first = result.first
        XCTAssertEqual(first?.nom, "Frida Kahlo",
                       "The 'nom' field of the first entry should be decoded exactly as stored in Source.json.")
        XCTAssertEqual(first?.email, "frida.kahlo@example.com",
                       "The 'email' field of the first entry should be decoded exactly as stored in Source.json.")
    }

<<<<<<< HEAD
    func testGivenSourceJsonFileName_WhenCallingChargement_ThenDateCreationKeyIsMappedFromSnakeCase() {
=======
    func testGivenSourceJsonFileName_WhenCallingChargement_ThenDateCreationKeyIsMappedFromSnakeCase() throws {
>>>>>>> fd60245 (test(unittests): improve coverage level)
        // Given
        let fileName = "Source.json"

        // When
<<<<<<< HEAD
        let result: [Client] = ModelData.chargement(fileName)

        // Then
        // Confirms the CodingKeys mapping (date_creation -> dateCreationString) is exercised
        // through the real decoding path, not just constructed via the memberwise initializer.
=======
        let result: [Client] = try ModelData.chargement(fileName)

        // Then
>>>>>>> fd60245 (test(unittests): improve coverage level)
        let first = result.first
        XCTAssertEqual(first?.dateCreation.getYear(), 2024)
        XCTAssertEqual(first?.dateCreation.getMonth(), 1)
        XCTAssertEqual(first?.dateCreation.getDay(), 15)
    }

<<<<<<< HEAD
    func testGivenSourceJsonFileName_WhenCallingChargementTwice_ThenBothCallsReturnEquivalentData() {
=======
    func testGivenSourceJsonFileName_WhenCallingChargementTwice_ThenBothCallsReturnEquivalentData() throws {
>>>>>>> fd60245 (test(unittests): improve coverage level)
        // Given
        let fileName = "Source.json"

        // When
<<<<<<< HEAD
        let firstLoad: [Client] = ModelData.chargement(fileName)
        let secondLoad: [Client] = ModelData.chargement(fileName)

        // Then
        // chargement is a pure read from a static bundle resource, so repeated
        // calls should be deterministic and side-effect free.
=======
        let firstLoad: [Client] = try ModelData.chargement(fileName)
        let secondLoad: [Client] = try ModelData.chargement(fileName)

        // Then
>>>>>>> fd60245 (test(unittests): improve coverage level)
        XCTAssertEqual(firstLoad, secondLoad,
                       "Repeated calls to chargement with the same file name should yield equivalent results.")
    }

<<<<<<< HEAD
    // MARK: - Generic behavior over T: Decodable

    func testGivenExplicitArrayClientTypeAnnotation_WhenCallingChargement_ThenGenericParameterIsInferredCorrectly() {
=======
    // MARK: - Success path: generic decoding into a non-Client Decodable type

    private struct NameOnlyEntry: Decodable, Equatable {
        let nom: String
    }

    func testGivenSourceJsonFileName_WhenCallingChargementWithDifferentDecodableType_ThenDecodesSuccessfully() throws {
>>>>>>> fd60245 (test(unittests): improve coverage level)
        // Given
        let fileName = "Source.json"

        // When
<<<<<<< HEAD
        // The call site's type annotation drives T's inference; this test makes that
        // generic resolution explicit rather than relying on a single call-site shape.
        let result = ModelData.chargement(fileName) as [Client]

        // Then
        XCTAssertTrue(result is [Client],
                      "chargement<T> should decode into whatever Decodable type T is inferred from the call site.")
=======
        let result: [NameOnlyEntry] = try ModelData.chargement(fileName)

        // Then
        XCTAssertEqual(result.count, 8,
                       "chargement<T> should decode all 8 entries regardless of which Decodable type T is.")
        XCTAssertEqual(result.first, NameOnlyEntry(nom: "Frida Kahlo"),
                       "chargement<T> should correctly decode the 'nom' field into the alternate Decodable type.")
    }

    // MARK: - Success path: injected bundle pointing at a valid custom fixture

    func testGivenValidJsonInInjectedBundle_WhenCallingChargement_ThenDecodesSuccessfully() throws {
        // Given
        let fixtureURL = tempDirectoryURL.appendingPathComponent("Valid.json")
        let json = #"[{"nom": "Test User", "email": "test@example.com", "date_creation": "2024-03-01T00:00:00Z"}]"#
        try json.write(to: fixtureURL, atomically: true, encoding: .utf8)

        // When
        let result: [Client] = try ModelData.chargement("Valid.json", bundle: tempBundle)

        // Then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.nom, "Test User",
                       "chargement should decode a custom fixture correctly when given an injected bundle.")
    }

    // MARK: - Failure path 1: file not found

    func testGivenNonExistentFileName_WhenCallingChargement_ThenThrowsFichierIntrouvable() {
        // Given
        let missingFileName = "CeFichierNExistePas.json"

        // When / Then
        XCTAssertThrowsError(try { let _: [Client] = try ModelData.chargement(missingFileName, bundle: tempBundle) }()) { error in
            guard let modelDataError = error as? ModelDataError else {
                XCTFail("Expected a ModelDataError, got \(error).")
                return
            }
            XCTAssertEqual(modelDataError, .fichierIntrouvable(nomFichier: missingFileName),
                           "A missing resource should throw .fichierIntrouvable carrying the requested file name.")
        }
    }

    func testGivenNonExistentFileNameInMainBundle_WhenCallingChargement_ThenThrowsFichierIntrouvable() {
        // Given
        // Same scenario, but exercised against the default Bundle.main parameter
        // (no bundle override), to also cover the default-argument call shape.
        let missingFileName = "CeFichierNExistePasNonPlus.json"

        // When / Then
        XCTAssertThrowsError(try { let _: [Client] = try ModelData.chargement(missingFileName) }()) { error in
            guard let modelDataError = error as? ModelDataError else {
                XCTFail("Expected a ModelDataError, got \(error).")
                return
            }
            XCTAssertEqual(modelDataError, .fichierIntrouvable(nomFichier: missingFileName))
        }
    }

    // MARK: - Failure path 2: file found but unreadable

    func testGivenUnreadableFile_WhenCallingChargement_ThenThrowsLectureImpossible() throws {
        // Given
        let fixtureURL = tempDirectoryURL.appendingPathComponent("Unreadable.json")
        try "[]".write(to: fixtureURL, atomically: true, encoding: .utf8)
        try FileManager.default.setAttributes([.posixPermissions: 0o000], ofItemAtPath: fixtureURL.path)

        // When / Then
        XCTAssertThrowsError(try { let _: [Client] = try ModelData.chargement("Unreadable.json", bundle: tempBundle) }()) { error in
            guard let modelDataError = error as? ModelDataError else {
                XCTFail("Expected a ModelDataError, got \(error).")
                return
            }
            switch modelDataError {
            case .lectureImpossible(let nomFichier, _):
                XCTAssertEqual(nomFichier, "Unreadable.json",
                               "An unreadable file should throw .lectureImpossible carrying the requested file name.")
            default:
                XCTFail("Expected .lectureImpossible, got \(modelDataError).")
            }
        }

        // Cleanup: restore permissions so tearDown can remove the file.
        try? FileManager.default.setAttributes([.posixPermissions: 0o644], ofItemAtPath: fixtureURL.path)
    }

    // MARK: - Failure path 3: file found and readable, but JSON is malformed

    func testGivenMalformedJson_WhenCallingChargement_ThenThrowsDecodageImpossible() throws {
        // Given
        let fixtureURL = tempDirectoryURL.appendingPathComponent("Malformed.json")
        let malformedJson = #"{ "nom": "incomplete""#
        try malformedJson.write(to: fixtureURL, atomically: true, encoding: .utf8)

        // When / Then
        XCTAssertThrowsError(try { let _: [Client] = try ModelData.chargement("Malformed.json", bundle: tempBundle) }()) { error in
            guard let modelDataError = error as? ModelDataError else {
                XCTFail("Expected a ModelDataError, got \(error).")
                return
            }
            switch modelDataError {
            case .decodageImpossible(let nomFichier, let typeCible, _):
                XCTAssertEqual(nomFichier, "Malformed.json")
                XCTAssertTrue(typeCible.contains("Client"),
                             "The target type description should reference the requested Decodable type.")
            default:
                XCTFail("Expected .decodageImpossible, got \(modelDataError).")
            }
        }
    }

    func testGivenValidJsonButIncompatibleStructure_WhenCallingChargement_ThenThrowsDecodageImpossible() throws {
        // Given
        // Syntactically valid JSON, but missing required Client fields (email, date_creation).
        let fixtureURL = tempDirectoryURL.appendingPathComponent("WrongShape.json")
        let wrongShapeJson = #"[{"nom": "Missing Other Fields"}]"#
        try wrongShapeJson.write(to: fixtureURL, atomically: true, encoding: .utf8)

        // When / Then
        XCTAssertThrowsError(try { let _: [Client] = try ModelData.chargement("WrongShape.json", bundle: tempBundle) }()) { error in
            guard let modelDataError = error as? ModelDataError else {
                XCTFail("Expected a ModelDataError, got \(error).")
                return
            }
            switch modelDataError {
            case .decodageImpossible(let nomFichier, _, _):
                XCTAssertEqual(nomFichier, "WrongShape.json",
                               "Valid JSON that doesn't match the target Decodable shape should still throw .decodageImpossible.")
            default:
                XCTFail("Expected .decodageImpossible, got \(modelDataError).")
            }
        }
    }

    // MARK: - ModelDataError equatable sanity checks

    func testGivenTwoEqualFichierIntrouvableErrors_WhenComparing_ThenTheyAreEqual() {
        // Given
        let errorA = ModelDataError.fichierIntrouvable(nomFichier: "X.json")
        let errorB = ModelDataError.fichierIntrouvable(nomFichier: "X.json")

        // When / Then
        XCTAssertEqual(errorA, errorB)
    }

    func testGivenDifferentErrorCases_WhenComparing_ThenTheyAreNotEqual() {
        // Given
        let errorA = ModelDataError.fichierIntrouvable(nomFichier: "X.json")
        let errorB = ModelDataError.lectureImpossible(nomFichier: "X.json", raison: "peu importe")

        // When / Then
        XCTAssertNotEqual(errorA, errorB)
>>>>>>> fd60245 (test(unittests): improve coverage level)
    }
}
