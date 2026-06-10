//
//  ClientViewModelIntegrationTests.swift
//  RelayanceTests
//
//  Integration tests — each test simulates a complete user action as it flows
//  through the ViewModel, exercising validation + mutation together.
//

import XCTest
@testable import Relayance

@MainActor
final class ClientViewModelIntegrationTests: XCTestCase {

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

    // MARK: - Scenario: User adds a new client with valid information

    /// Scenario:
    ///   Given the user fills in a valid name and a valid email
    ///   When they tap "Ajouter"
    ///   Then the form is valid, the client is created, and it immediately appears in the list
    func testGivenValidNameAndEmail_WhenUserAddsClient_ThenClientAppearsInList() {
        // Given
        let nom = "Marie Curie"
        let email = "marie.curie@example.com"
        let initialCount = sut.clientsList.count

        // Precondition: both fields individually pass validation (as the view would check)
        XCTAssertTrue(sut.isValidName(nom), "Precondition: name must be valid before adding.")
        XCTAssertTrue(sut.isValidEmail(email), "Precondition: email must be valid before adding.")

        // When — view calls addClient only after validation passes
        sut.addClient(nom: nom, email: email)

        // Then — client is present and list grew by one
        XCTAssertEqual(sut.clientsList.count, initialCount + 1,
                       "List should contain one more client after a successful add.")
        let added = sut.clientsList.last
        XCTAssertEqual(added?.nom, nom)
        XCTAssertEqual(added?.email, email)
    }

    /// Scenario:
    ///   Given the user fills in a valid name and a valid email with surrounding whitespace
    ///   When they tap "Ajouter"
    ///   Then the client is stored with trimmed values and appears in the list
    func testGivenValidInputWithWhitespace_WhenUserAddsClient_ThenClientStoredTrimmedAndAppearsInList() {
        // Given
        let rawNom = "  Louis Pasteur  "
        let rawEmail = "  louis.pasteur@example.com  "
        let expectedNom = "Louis Pasteur"
        let expectedEmail = "louis.pasteur@example.com"

        // Precondition: validation still passes on trimmed values
        XCTAssertTrue(sut.isValidName(rawNom))
        XCTAssertTrue(sut.isValidEmail(rawEmail))

        // When
        sut.addClient(nom: rawNom, email: rawEmail)

        // Then
        let added = sut.clientsList.last
        XCTAssertEqual(added?.nom, expectedNom,
                       "Name should be trimmed before being stored.")
        XCTAssertEqual(added?.email, expectedEmail,
                       "Email should be trimmed before being stored.")
    }

    /// Scenario:
    ///   Given the user fills in a valid name and a valid email
    ///   When they tap "Ajouter"
    ///   Then the new client's creation date is today (created via creerNouveauClient)
    func testGivenValidInput_WhenUserAddsClient_ThenNewClientIsTaggedAsNewToday() {
        // Given
        let nom = "Alan Turing"
        let email = "alan.turing@example.com"
        let today = Date.now

        XCTAssertTrue(sut.isValidName(nom))
        XCTAssertTrue(sut.isValidEmail(email))

        // When
        sut.addClient(nom: nom, email: email)

        // Then — estNouveauClient() relies on dateCreation matching today
        let added = sut.clientsList.last!
        XCTAssertTrue(added.estNouveauClient(),
                      "A client added today should be flagged as a new client.")
        XCTAssertEqual(added.dateCreation.getDay(), today.getDay())
        XCTAssertEqual(added.dateCreation.getMonth(), today.getMonth())
        XCTAssertEqual(added.dateCreation.getYear(), today.getYear())
    }

    // MARK: - Scenario: User tries to add a client with an invalid email

    /// Scenario:
    ///   Given the user fills in a valid name but an invalid email (missing @)
    ///   When the view validates the form
    ///   Then validation fails and addClient is never called — the list stays unchanged
    func testGivenInvalidEmail_WhenUserTriesToAddClient_ThenValidationFailsAndListIsUnchanged() {
        // Given
        let nom = "Charles Darwin"
        let invalidEmail = "charles.darwinexample.com" // missing @
        let initialCount = sut.clientsList.count

        // When — view checks validity before calling addClient
        let nameValid = sut.isValidName(nom)
        let emailValid = sut.isValidEmail(invalidEmail)
        let formValid = nameValid && emailValid

        if formValid {
            sut.addClient(nom: nom, email: invalidEmail)
        }

        // Then
        XCTAssertFalse(emailValid, "Email without '@' should be invalid.")
        XCTAssertFalse(formValid, "Form should be invalid when email is malformed.")
        XCTAssertEqual(sut.clientsList.count, initialCount,
                       "List must not change when form validation fails.")
    }

    /// Scenario:
    ///   Given the user leaves the name field empty
    ///   When the view validates the form
    ///   Then validation fails and the list stays unchanged
    func testGivenEmptyName_WhenUserTriesToAddClient_ThenValidationFailsAndListIsUnchanged() {
        // Given
        let emptyNom = ""
        let email = "valid@example.com"
        let initialCount = sut.clientsList.count

        // When
        let nameValid = sut.isValidName(emptyNom)
        let emailValid = sut.isValidEmail(email)
        let formValid = nameValid && emailValid

        if formValid {
            sut.addClient(nom: emptyNom, email: email)
        }

        // Then
        XCTAssertFalse(nameValid, "An empty name should be invalid.")
        XCTAssertFalse(formValid, "Form should be invalid when name is empty.")
        XCTAssertEqual(sut.clientsList.count, initialCount,
                       "List must not change when name validation fails.")
    }

    /// Scenario:
    ///   Given the user fills in only whitespace for both fields
    ///   When the view validates the form
    ///   Then both validations fail and the list stays unchanged
    func testGivenWhitespaceOnlyInputs_WhenUserTriesToAddClient_ThenValidationFailsAndListIsUnchanged() {
        // Given
        let whitespaceNom = "   "
        let whitespaceEmail = "   "
        let initialCount = sut.clientsList.count

        // When
        let formValid = sut.isValidName(whitespaceNom) && sut.isValidEmail(whitespaceEmail)

        if formValid {
            sut.addClient(nom: whitespaceNom, email: whitespaceEmail)
        }

        // Then
        XCTAssertFalse(formValid)
        XCTAssertEqual(sut.clientsList.count, initialCount,
                       "Whitespace-only inputs must not result in a client being added.")
    }

    // MARK: - Scenario: User deletes an existing client

    /// Scenario:
    ///   Given a client exists in the list
    ///   When the user taps "Supprimer" on that client's detail screen
    ///   Then the client is removed from the list and the list shrinks by one
    func testGivenExistingClient_WhenUserDeletesClient_ThenClientRemovedAndListShrinks() {
        // Given — add a fresh client so we control the exact instance
        sut.addClient(nom: "Nikola Tesla", email: "nikola.tesla@example.com")
        let clientToDelete = sut.clientsList.last!
        let countBefore = sut.clientsList.count

        // Precondition: client is present before deletion
        XCTAssertTrue(clientToDelete.clientExiste(clientsList: sut.clientsList),
                      "Precondition: client must exist in the list before deletion.")

        // When — view calls deleteClient then dismisses
        sut.deleteClient(clientToDelete)

        // Then
        XCTAssertEqual(sut.clientsList.count, countBefore - 1,
                       "List should shrink by one after deleting an existing client.")
        XCTAssertFalse(clientToDelete.clientExiste(clientsList: sut.clientsList),
                       "Deleted client must no longer be found via clientExiste.")
    }

    /// Scenario:
    ///   Given a client from the initial JSON load
    ///   When the user deletes it
    ///   Then it is no longer in the list
    func testGivenInitialJsonClient_WhenUserDeletesIt_ThenItNoLongerExistsInList() {
        // Given — use the first client loaded from Source.json
        let clientToDelete = sut.clientsList[0]
        let countBefore = sut.clientsList.count

        XCTAssertTrue(clientToDelete.clientExiste(clientsList: sut.clientsList),
                      "Precondition: JSON-loaded client must exist before deletion.")

        // When
        sut.deleteClient(clientToDelete)

        // Then
        XCTAssertEqual(sut.clientsList.count, countBefore - 1)
        XCTAssertFalse(clientToDelete.clientExiste(clientsList: sut.clientsList),
                       "A JSON-loaded client should be fully removed after deleteClient.")
    }

    // MARK: - Scenario: Full round-trip — add then delete

    /// Scenario:
    ///   Given a user adds a new client
    ///   And then immediately deletes it
    ///   Then the list returns to its original count and the client no longer exists
    func testGivenUserAddsClient_WhenUserImmediatelyDeletesIt_ThenListRestoresToOriginalState() {
        // Given
        let initialCount = sut.clientsList.count
        let nom = "Isaac Newton"
        let email = "isaac.newton@example.com"

        XCTAssertTrue(sut.isValidName(nom))
        XCTAssertTrue(sut.isValidEmail(email))
        sut.addClient(nom: nom, email: email)

        let added = sut.clientsList.last!
        XCTAssertEqual(sut.clientsList.count, initialCount + 1,
                       "Intermediate check: client was added.")

        // When
        sut.deleteClient(added)

        // Then
        XCTAssertEqual(sut.clientsList.count, initialCount,
                       "After add + delete, list count must equal the original count.")
        XCTAssertFalse(added.clientExiste(clientsList: sut.clientsList),
                       "The added-then-deleted client must not remain in the list.")
    }
}
