//
//  ClientTests.swift
//  RelayanceTests
//
//  Created by Mathieu ARRIO on 09/06/2026.
//

import XCTest
@testable import Relayance

final class ClientTests: XCTestCase {
    
    func testGivenClientInit_WhenSettingInitPropertiesCorrectly_ThenClientInitValid() {
        // Given
        let expectedNom = "John Doe"
        let expectedEmail = "john.doe@example.com"
        let expectedDateString = "2024-07-10T14:30:00.000Z"
        
        // When
        let client = Client(
            nom: expectedNom,
            email: expectedEmail,
            dateCreationString: expectedDateString
        )
        
        // Then
        XCTAssertEqual(client.nom, expectedNom, "The name should match the value passed to the initializer.")
        XCTAssertEqual(client.email, expectedEmail, "The email should match the value passed to the initializer.")
        XCTAssertEqual(client.dateCreation,
                       Date.dateFromString(expectedDateString),
                       "The date string should match the value passed to the initializer.")
    }
    
    func testGivenClientParameters_WhenCallingCreerNouveauClient_ThenClientCreatedWithCurrentDate() {
        // Given
        let inputNom = "Jane Doe"
        let inputEmail = "jane.doe@example.com"
        
        // When
        let newClient = Client.creerNouveauClient(nom: inputNom, email: inputEmail)
        
        // Then
        XCTAssertEqual(newClient.nom, inputNom, "The created client's name does not match the provided input.")
        XCTAssertEqual(newClient.email, inputEmail, "The created client's email does not match the provided input.")
        
        let today = Date.now
        XCTAssertEqual(newClient.dateCreation.getYear(), today.getYear(),
                       "The client's creation year should match today.")
        XCTAssertEqual(newClient.dateCreation.getMonth(), today.getMonth(),
                       "The client's creation month should match today.")
        XCTAssertEqual(newClient.dateCreation.getDay(), today.getDay(),
                       "The client's creation day should match today.")
    }
    
    func testGivenClientCreatedToday_WhenCallingEstNouveauClient_ThenReturnsTrue() {
        // Given
        let newClient = Client.creerNouveauClient(nom: "Today", email: "today@example.com")
        
        // When
        let isNew = newClient.estNouveauClient()
        
        // Then
        XCTAssertTrue(isNew, "A client created today should be considered new.")
    }
    
    func testGivenClientCreatedInPast_WhenCallingEstNouveauClient_ThenReturnsFalse() {
        // Given
        let oldClient = Client(
            nom: "Old",
            email: "old@example.com",
            dateCreationString: "2020-01-15T00:00:00.000Z"
        )
        
        // When
        let isNew = oldClient.estNouveauClient()
        
        // Then
        XCTAssertFalse(isNew, "A client created in the past should not be considered new.")
    }
    
    // MARK: - Tests for dateCreation fallback
    
    func testGivenClientWithInvalidDateString_WhenAccessingDateCreation_ThenReturnsCurrentDateFallback() {
        // Given
        let invalidDateString = "ceci-n-est-pas-une-date"
        let client = Client(nom: "Fallback", email: "fallback@example.com", dateCreationString: invalidDateString)
        
        // When
        let date = client.dateCreation
        
        // Then
        let today = Date.now
        XCTAssertEqual(date.getYear(), today.getYear(), "Le fallback de l'année devrait être l'année actuelle.")
        XCTAssertEqual(date.getMonth(), today.getMonth(), "Le fallback du mois devrait être le mois actuel.")
        XCTAssertEqual(date.getDay(), today.getDay(), "Le fallback du jour devrait être le jour actuel.")
    }
    
    // MARK: - Tests for clientExiste(clientsList:)
    
    func testGivenExistingClient_WhenCallingClientExiste_ThenReturnsTrue() {
        // Given
        let clientToFind = Client(nom: "Alice", email: "alice@example.com", dateCreationString: "2024-07-10T14:30:00.000Z")
        let otherClient = Client(nom: "Bob", email: "bob@example.com", dateCreationString: "2024-07-11T10:00:00.000Z")
        
        let clientsList = [otherClient, clientToFind] // Le client est dans la liste
        
        // When
        let exists = clientToFind.clientExiste(clientsList: clientsList)
        
        // Then
        XCTAssertTrue(exists, "La méthode doit retourner true car le client est présent dans la liste.")
    }
    
    func testGivenUnknownClient_WhenCallingClientExiste_ThenReturnsFalse() {
        // Given
        let unknownClient = Client(nom: "Charlie", email: "charlie@example.com", dateCreationString: "2024-07-10T14:30:00.000Z")
        let clientInList = Client(nom: "Bob", email: "bob@example.com", dateCreationString: "2024-07-11T10:00:00.000Z")
        
        let clientsList = [clientInList] // Le client n'est pas dans la liste
        
        // When
        let exists = unknownClient.clientExiste(clientsList: clientsList)
        
        // Then
        XCTAssertFalse(exists, "La méthode doit retourner false car le client n'est pas présent dans la liste.")
    }
    
    // MARK: - Tests for formatDateVersString()
    
    func testGivenClient_WhenCallingFormatDateVersString_ThenReturnsFormattedString() {
        // Given
        let inputDateString = "2024-07-10T14:30:00.000Z"
        let client = Client(nom: "Dave", email: "dave@example.com", dateCreationString: inputDateString)
        
        // On s'attend à ce que Date.stringFromDate renvoie la date sous format "dd-MM-yyyy"
        let expectedFormattedString = "10-07-2024"
        
        // When
        let formattedString = client.formatDateVersString()
        
        // Then
        XCTAssertEqual(formattedString, expectedFormattedString, "La chaîne de caractères générée doit correspondre au format configuré par Date.stringFromDate.")
    }
    
    // MARK: - Tests for formatDateVersString()
    
    func testGivenClientWithValidDate_WhenCallingFormatDateVersString_ThenReturnsFormattedString() {
        // Given
        let inputDateString = "2024-07-10T14:30:00.000Z"
        let client = Client(nom: "Dave", email: "dave@example.com", dateCreationString: inputDateString)
        let expectedFormattedString = "10-07-2024"
        
        // When
        let formattedString = client.formatDateVersString()
        
        // Then
        XCTAssertEqual(formattedString, expectedFormattedString, "La chaîne doit être formatée au style dd-MM-yyyy.")
    }
    
    func testGivenClientWithInvalidDateString_WhenCallingFormatDateVersString_ThenReturnsTodayFormatted() {
        // Given
        let invalidString = "DATE_TOTALEMENT_INVALIDE"
        let client = Client(nom: "Test Fallback", email: "test@fallback.com", dateCreationString: invalidString)
        
        // Comme la date de création retombe sur Date.now, le formateur va formater la date d'aujourd'hui
        let today = Date.now
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let expectedTodayString = dateFormatter.string(from: today)
        
        // When
        let formattedString = client.formatDateVersString()
        
        // Then
        XCTAssertEqual(formattedString, expectedTodayString, "En cas de string invalide à l'init, la méthode doit formater la date du jour par défaut.")
    }
    
}
