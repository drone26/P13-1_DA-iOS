//
//  ModelDataTests.swift
//  RelayanceTests
//
//  Created by Mathieu ARRIO on 09/06/2026.
//

import XCTest
@testable import Relayance

final class ModelDataTests: XCTestCase {

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

    func testGivenSourceJsonInHostAppBundle_WhenResolvingViaBundleMain_ThenURLIsFound() {
        // Given
        let fileName = "Source.json"

        // When
        let url = Bundle.main.url(forResource: fileName, withExtension: nil)

        // Then
        XCTAssertNotNil(url,
                        "Source.json must be resolvable through Bundle.main (the host Relayance.app bundle) for chargement's success path to be exercised.")
    }

    // MARK: - Success path: decoding into [Client] via the default Bundle.main

    func testGivenSourceJsonFileName_WhenCallingChargement_ThenReturnsNonEmptyClientsArray() throws {
        // Given
        let fileName = "Source.json"

        // When
        let result: [Client] = try ModelData.chargement(fileName)

        // Then
        XCTAssertFalse(result.isEmpty,
                       "chargement should successfully locate, read, and decode Source.json into a non-empty array.")
    }

    func testGivenSourceJsonFileName_WhenCallingChargement_ThenReturnsExpectedNumberOfClients() throws {
        // Given
        let fileName = "Source.json"

        // When
        let result: [Client] = try ModelData.chargement(fileName)

        // Then
        XCTAssertEqual(result.count, 8,
                       "chargement should decode every element present in Source.json.")
    }

    func testGivenSourceJsonFileName_WhenCallingChargement_ThenFirstClientFieldsAreCorrectlyDecoded() throws {
        // Given
        let fileName = "Source.json"

        // When
        let result: [Client] = try ModelData.chargement(fileName)

        // Then
        let first = result.first
        XCTAssertEqual(first?.nom, "Frida Kahlo",
                       "The 'nom' field of the first entry should be decoded exactly as stored in Source.json.")
        XCTAssertEqual(first?.email, "frida.kahlo@example.com",
                       "The 'email' field of the first entry should be decoded exactly as stored in Source.json.")
    }

    func testGivenSourceJsonFileName_WhenCallingChargement_ThenDateCreationKeyIsMappedFromSnakeCase() throws {
        // Given
        let fileName = "Source.json"

        // When
        let result: [Client] = try ModelData.chargement(fileName)

        // Then
        let first = result.first
        XCTAssertEqual(first?.dateCreation.getYear(), 2024)
        XCTAssertEqual(first?.dateCreation.getMonth(), 1)
        XCTAssertEqual(first?.dateCreation.getDay(), 15)
    }

    func testGivenSourceJsonFileName_WhenCallingChargementTwice_ThenBothCallsReturnEquivalentData() throws {
        // Given
        let fileName = "Source.json"

        // When
        let firstLoad: [Client] = try ModelData.chargement(fileName)
        let secondLoad: [Client] = try ModelData.chargement(fileName)

        // Then
        XCTAssertEqual(firstLoad, secondLoad,
                       "Repeated calls to chargement with the same file name should yield equivalent results.")
    }

    // MARK: - Success path: generic decoding into a non-Client Decodable type

    private struct NameOnlyEntry: Decodable, Equatable {
        let nom: String
    }

    func testGivenSourceJsonFileName_WhenCallingChargementWithDifferentDecodableType_ThenDecodesSuccessfully() throws {
        // Given
        let fileName = "Source.json"

        // When
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
    }
}
