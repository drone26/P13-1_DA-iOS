//
//  ClientViewModelTests.swift
//  RelayanceTests
//

import XCTest
@testable import Relayance

@MainActor
final class ClientViewModelTests: XCTestCase {

    // MARK: - System Under Test

    private var sut: ClientViewModel!

    override func setUp() {
        super.setUp()
        sut = ClientViewModel()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Initial state

    func testGivenViewModelInit_WhenNoActionTaken_ThenClientsListIsNotEmpty() {
        // The JSON source contains 8 clients — just verify it loads at all.
        XCTAssertFalse(sut.clientsList.isEmpty,
                       "clientsList should be populated from Source.json on init.")
    }

    // MARK: - isValidEmail

    func testGivenValidEmail_WhenCallingIsValidEmail_ThenReturnsTrue() {
        XCTAssertTrue(sut.isValidEmail("user@example.com"))
    }

    func testGivenValidEmailWithSubdomain_WhenCallingIsValidEmail_ThenReturnsTrue() {
        XCTAssertTrue(sut.isValidEmail("user@mail.example.co.uk"))
    }

    func testGivenValidEmailWithPlusSign_WhenCallingIsValidEmail_ThenReturnsTrue() {
        XCTAssertTrue(sut.isValidEmail("user+tag@example.com"))
    }

    func testGivenEmailWithLeadingSpaces_WhenCallingIsValidEmail_ThenReturnsTrue() {
        // Spaces should be trimmed before validation.
        XCTAssertTrue(sut.isValidEmail("  user@example.com  "))
    }

    func testGivenEmptyString_WhenCallingIsValidEmail_ThenReturnsFalse() {
        XCTAssertFalse(sut.isValidEmail(""))
    }

    func testGivenEmailWithoutAtSign_WhenCallingIsValidEmail_ThenReturnsFalse() {
        XCTAssertFalse(sut.isValidEmail("userexample.com"))
    }

    func testGivenEmailWithoutDomain_WhenCallingIsValidEmail_ThenReturnsFalse() {
        XCTAssertFalse(sut.isValidEmail("user@"))
    }

    func testGivenEmailWithoutTLD_WhenCallingIsValidEmail_ThenReturnsFalse() {
        XCTAssertFalse(sut.isValidEmail("user@example"))
    }

    func testGivenEmailWithoutLocalPart_WhenCallingIsValidEmail_ThenReturnsFalse() {
        XCTAssertFalse(sut.isValidEmail("@example.com"))
    }

    func testGivenEmailWithSpaceInMiddle_WhenCallingIsValidEmail_ThenReturnsFalse() {
        XCTAssertFalse(sut.isValidEmail("user @example.com"))
    }

    func testGivenOnlySpaces_WhenCallingIsValidEmail_ThenReturnsFalse() {
        XCTAssertFalse(sut.isValidEmail("   "))
    }

    // MARK: - isValidName

    func testGivenValidName_WhenCallingIsValidName_ThenReturnsTrue() {
        XCTAssertTrue(sut.isValidName("Alice"))
    }

    func testGivenNameWithSpacesOnly_WhenCallingIsValidName_ThenReturnsFalse() {
        XCTAssertFalse(sut.isValidName("   "))
    }

    func testGivenEmptyName_WhenCallingIsValidName_ThenReturnsFalse() {
        XCTAssertFalse(sut.isValidName(""))
    }

    func testGivenNameWithLeadingAndTrailingSpaces_WhenCallingIsValidName_ThenReturnsTrue() {
        // Non-empty after trimming — still valid.
        XCTAssertTrue(sut.isValidName("  Alice  "))
    }

    // MARK: - addClient

    func testGivenValidInput_WhenCallingAddClient_ThenClientsListCountIncreasedByOne() {
        // Given
        let initialCount = sut.clientsList.count

        // When
        sut.addClient(nom: "Bob Martin", email: "bob@example.com")

        // Then
        XCTAssertEqual(sut.clientsList.count, initialCount + 1,
                       "Adding a client should increase the list count by exactly 1.")
    }

    func testGivenValidInput_WhenCallingAddClient_ThenNewClientAppearsInList() {
        // Given
        let nom = "Carol White"
        let email = "carol@example.com"

        // When
        sut.addClient(nom: nom, email: email)

        // Then
        let found = sut.clientsList.contains { $0.nom == nom && $0.email == email }
        XCTAssertTrue(found, "The newly added client should be present in clientsList.")
    }

    func testGivenInputWithExtraSpaces_WhenCallingAddClient_ThenStoredNameAndEmailAreTrimmed() {
        // Given / When
        sut.addClient(nom: "  Dan Brown  ", email: "  dan@example.com  ")

        // Then
        let added = sut.clientsList.last
        XCTAssertEqual(added?.nom, "Dan Brown",
                       "Leading/trailing spaces in nom should be trimmed before storing.")
        XCTAssertEqual(added?.email, "dan@example.com",
                       "Leading/trailing spaces in email should be trimmed before storing.")
    }

    func testGivenValidInput_WhenCallingAddClient_ThenNewClientCreationDateIsToday() {
        // Given
        let today = Date.now

        // When
        sut.addClient(nom: "Eve Adams", email: "eve@example.com")

        // Then
        let added = sut.clientsList.last!
        XCTAssertEqual(added.dateCreation.getYear(), today.getYear())
        XCTAssertEqual(added.dateCreation.getMonth(), today.getMonth())
        XCTAssertEqual(added.dateCreation.getDay(), today.getDay())
    }

    // MARK: - deleteClient

    func testGivenExistingClient_WhenCallingDeleteClient_ThenClientsListCountDecreasedByOne() {
        // Given
        sut.addClient(nom: "Frank Castle", email: "frank@example.com")
        let clientToDelete = sut.clientsList.last!
        let countBefore = sut.clientsList.count

        // When
        sut.deleteClient(clientToDelete)

        // Then
        XCTAssertEqual(sut.clientsList.count, countBefore - 1,
                       "Deleting a client should decrease the list count by exactly 1.")
    }

    func testGivenExistingClient_WhenCallingDeleteClient_ThenClientNoLongerInList() {
        // Given
        sut.addClient(nom: "Grace Hopper", email: "grace@example.com")
        let clientToDelete = sut.clientsList.last!

        // When
        sut.deleteClient(clientToDelete)

        // Then
        XCTAssertFalse(sut.clientsList.contains(clientToDelete),
                       "The deleted client should no longer appear in clientsList.")
    }

    func testGivenNonExistingClient_WhenCallingDeleteClient_ThenListRemainsUnchanged() {
        // Given
        let phantom = Client(nom: "Ghost", email: "ghost@example.com", dateCreationString: "2024-01-01T00:00:00Z")
        let countBefore = sut.clientsList.count

        // When
        sut.deleteClient(phantom)

        // Then
        XCTAssertEqual(sut.clientsList.count, countBefore,
                       "Attempting to delete a client not in the list should not modify the list.")
    }

    func testGivenMultipleClientsWithSameData_WhenCallingDeleteClient_ThenAllDuplicatesAreRemoved() {
        // Given — add the same logical client twice (same email & nom produce equal structs via Hashable)
        let duplicate = Client(nom: "Twin", email: "twin@example.com", dateCreationString: "2024-06-01T10:00:00Z")
        sut.clientsList.append(duplicate)
        sut.clientsList.append(duplicate)
        let countBefore = sut.clientsList.count

        // When
        sut.deleteClient(duplicate)

        // Then — removeAll removes every matching element
        XCTAssertFalse(sut.clientsList.contains(duplicate))
        XCTAssertEqual(sut.clientsList.count, countBefore - 2,
                       "deleteClient uses removeAll, so all duplicates should be removed.")
    }

    // MARK: - Round-trip: add then delete

    func testGivenAddedClient_WhenDeletingIt_ThenListCountReturnsToPreviousValue() {
        // Given
        let initialCount = sut.clientsList.count
        sut.addClient(nom: "Henry Ford", email: "henry@example.com")
        let added = sut.clientsList.last!

        // When
        sut.deleteClient(added)

        // Then
        XCTAssertEqual(sut.clientsList.count, initialCount,
                       "After adding and then deleting a client, the count should be back to the original.")
    }
}
