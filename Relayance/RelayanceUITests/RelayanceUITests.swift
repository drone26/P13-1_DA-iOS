//
//  RelayanceUITests.swift
//  RelayanceUITests
//
//  Created by Mathieu ARRIO on 19/06/2026.
//

import XCTest

final class RelayanceUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
        try super.tearDownWithError()
    }

    // MARK: - Helpers

    /// Ouvre la modale AjoutClientView depuis la liste principale.
    private func openAjoutClientView() {
        let addButton = app.buttons["Ajouter un client"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 3), "Le bouton 'Ajouter un client' doit être présent dans la toolbar.")
        addButton.tap()
    }

    /// Navigue vers le détail du premier client de la liste.
    private func openFirstClientDetail() {
        let firstCell = app.staticTexts["Frida Kahlo"]
        XCTAssertTrue(firstCell.waitForExistence(timeout: 3), "Le premier client 'Frida Kahlo' doit être visible dans la liste.")
        firstCell.tap()
    }

    // MARK: - AjoutClientView: affichage initial

    func testGivenListView_WhenTappingAjouterUnClient_ThenAjoutClientViewAppears() {
        // Given — la liste est affichée au lancement

        // When
        openAjoutClientView()

        // Then
        XCTAssertTrue(app.staticTexts["Ajouter un nouveau client"].waitForExistence(timeout: 3),
                      "Le titre 'Ajouter un nouveau client' doit être visible à l'ouverture de la modale.")
        XCTAssertTrue(app.textFields["Nom"].exists,
                      "Le champ 'Nom' doit être présent dans la modale d'ajout.")
        XCTAssertTrue(app.textFields["Email"].exists,
                      "Le champ 'Email' doit être présent dans la modale d'ajout.")
        XCTAssertTrue(app.buttons["Ajouter"].exists,
                      "Le bouton 'Ajouter' doit être présent dans la modale d'ajout.")
    }

    func testGivenAjoutClientView_WhenJustOpened_ThenNoValidationErrorsVisible() {
        // Given
        openAjoutClientView()

        // When — aucune interaction, champs vides d'emblée

        // Then — les messages d'erreur ne doivent pas être affichés avant toute tentative de soumission
        XCTAssertFalse(app.staticTexts["Le nom ne peut pas être vide."].exists,
                       "L'erreur de nom ne doit pas être visible à l'ouverture.")
        XCTAssertFalse(app.staticTexts["L'adresse e-mail n'est pas valide."].exists,
                       "L'erreur d'email ne doit pas être visible à l'ouverture.")
    }

    // MARK: - AjoutClientView: validation — champs vides

    func testGivenEmptyFields_WhenTappingAjouter_ThenBothValidationErrorsAppear() {
        // Given
        openAjoutClientView()

        // When — tap sur Ajouter sans rien saisir
        app.buttons["Ajouter"].tap()

        // Then
        XCTAssertTrue(app.staticTexts["Le nom ne peut pas être vide."].waitForExistence(timeout: 2),
                      "L'erreur de nom doit apparaître lorsque le champ Nom est vide.")
        XCTAssertTrue(app.staticTexts["L'adresse e-mail n'est pas valide."].waitForExistence(timeout: 2),
                      "L'erreur d'email doit apparaître lorsque le champ Email est vide.")
    }

    func testGivenEmptyFields_WhenTappingAjouter_ThenModalRemainsOpen() {
        // Given
        openAjoutClientView()

        // When
        app.buttons["Ajouter"].tap()

        // Then — la modale est toujours visible (le titre est encore là)
        XCTAssertTrue(app.staticTexts["Ajouter un nouveau client"].waitForExistence(timeout: 2),
                      "La modale doit rester ouverte lorsque la validation échoue.")
    }

    // MARK: - AjoutClientView: validation — nom vide, email valide

    func testGivenValidEmailButEmptyName_WhenTappingAjouter_ThenOnlyNameErrorAppears() {
        // Given
        openAjoutClientView()
        app.textFields["Email"].tap()
        app.textFields["Email"].typeText("valid@example.com")

        // When
        app.buttons["Ajouter"].tap()

        // Then
        XCTAssertTrue(app.staticTexts["Le nom ne peut pas être vide."].waitForExistence(timeout: 2),
                      "L'erreur de nom doit apparaître quand le nom est vide.")
        XCTAssertFalse(app.staticTexts["L'adresse e-mail n'est pas valide."].exists,
                       "L'erreur d'email ne doit pas apparaître quand l'email est valide.")
    }

    // MARK: - AjoutClientView: validation — nom valide, email invalide

    func testGivenValidNameButInvalidEmail_WhenTappingAjouter_ThenOnlyEmailErrorAppears() {
        // Given
        openAjoutClientView()
        app.textFields["Nom"].tap()
        app.textFields["Nom"].typeText("Ada Lovelace")
        app.textFields["Email"].tap()
        app.textFields["Email"].typeText("adalovelaceexample") // manque @ et domaine

        // When
        app.buttons["Ajouter"].tap()

        // Then
        XCTAssertFalse(app.staticTexts["Le nom ne peut pas être vide."].exists,
                       "L'erreur de nom ne doit pas apparaître quand le nom est valide.")
        XCTAssertTrue(app.staticTexts["L'adresse e-mail n'est pas valide."].waitForExistence(timeout: 2),
                      "L'erreur d'email doit apparaître quand le format est invalide.")
    }

    // MARK: - AjoutClientView: ajout valide → fermeture de la modale

    func testGivenValidNameAndEmail_WhenTappingAjouter_ThenModalDismisses() {
        // Given
        openAjoutClientView()
        app.textFields["Nom"].tap()
        app.textFields["Nom"].typeText("Marie Curie")
        app.textFields["Email"].tap()
        app.textFields["Email"].typeText("marie.curie@example.com")

        // When
        app.buttons["Ajouter"].tap()

        // Then — la modale se ferme : le titre du formulaire disparaît
        XCTAssertFalse(app.staticTexts["Ajouter un nouveau client"].waitForExistence(timeout: 3),
                       "La modale doit se fermer après un ajout valide.")
    }

    func testGivenValidNameAndEmail_WhenTappingAjouter_ThenNewClientAppearsInList() {
        // Given — précondition : Frida Kahlo (1er client de Source.json) est visible
        XCTAssertTrue(app.staticTexts["Frida Kahlo"].waitForExistence(timeout: 3),
                      "Précondition : la liste initiale doit afficher Frida Kahlo.")
        openAjoutClientView()
        app.textFields["Nom"].tap()
        app.textFields["Nom"].typeText("Alan Turing")
        app.textFields["Email"].tap()
        app.textFields["Email"].typeText("alan.turing@example.com")

        // When
        app.buttons["Ajouter"].tap()

        // Then — Alan apparaît (en bas de liste), Frida est toujours là : la liste a gagné
        // exactement une entrée. (La comparaison par cells.count n'est pas fiable ici, car
        // SwiftUI ne rend que les cellules visibles dans le viewport.)
        // Alan Turing est ajouté en fin de liste, donc sous le pli : on scroll pour le révéler.
        let alan = app.staticTexts["Alan Turing"]
        var swipeCount = 0
        while !alan.exists && swipeCount < 5 {
            app.swipeUp()
            swipeCount += 1
        }
        XCTAssertTrue(alan.exists,
                      "Le client ajouté doit apparaître dans la liste après fermeture de la modale.")
        // On scroll de nouveau vers le haut pour vérifier que Frida est restée en place.
        while !app.staticTexts["Frida Kahlo"].exists && swipeCount > 0 {
            app.swipeDown()
            swipeCount -= 1
        }
        XCTAssertTrue(app.staticTexts["Frida Kahlo"].exists,
                      "Frida Kahlo doit toujours être présente — preuve qu'aucun client existant n'a été remplacé.")
    }

    // MARK: - DetailClientView: affichage des informations du client

    func testGivenClientList_WhenTappingOnClient_ThenDetailViewShowsClientName() {
        // Given — la liste est chargée avec les clients de Source.json

        // When
        openFirstClientDetail()

        // Then
        XCTAssertTrue(app.staticTexts["Frida Kahlo"].waitForExistence(timeout: 3),
                      "Le nom du client doit être affiché dans la vue de détail.")
    }

    func testGivenClientList_WhenTappingOnClient_ThenDetailViewShowsClientEmail() {
        // Given
        openFirstClientDetail()

        // Then
        XCTAssertTrue(app.staticTexts["frida.kahlo@example.com"].waitForExistence(timeout: 3),
                      "L'email du client doit être affiché dans la vue de détail.")
    }

    func testGivenClientList_WhenTappingOnClient_ThenDetailViewShowsFormattedCreationDate() {
        // Given — Frida Kahlo a date_creation "2024-01-15", formatée en "15-01-2024"
        openFirstClientDetail()

        // Then
        XCTAssertTrue(app.staticTexts["15-01-2024"].waitForExistence(timeout: 3),
                      "La date de création formatée (dd-MM-yyyy) doit être affichée dans la vue de détail.")
    }

    func testGivenClientList_WhenTappingOnClient_ThenDeleteButtonIsVisible() {
        // Given
        openFirstClientDetail()

        // Then
        XCTAssertTrue(app.buttons["Supprimer"].waitForExistence(timeout: 3),
                      "Le bouton 'Supprimer' doit être visible dans la toolbar de la vue de détail.")
    }

    // MARK: - DetailClientView: suppression du client

    func testGivenDetailView_WhenTappingSupprimer_ThenNavigatesBackToList() {
        // Given
        openFirstClientDetail()
        XCTAssertTrue(app.buttons["Supprimer"].waitForExistence(timeout: 3))

        // When
        app.buttons["Supprimer"].tap()

        // Then — la vue de détail se ferme : on est revenu à la liste
        XCTAssertTrue(app.navigationBars["Liste des clients"].waitForExistence(timeout: 3),
                      "Après suppression, la navigation doit revenir à la liste des clients.")
    }

    func testGivenDetailView_WhenTappingSupprimer_ThenClientNoLongerAppearsInList() {
        // Given
        openFirstClientDetail()
        XCTAssertTrue(app.buttons["Supprimer"].waitForExistence(timeout: 3))

        // When
        app.buttons["Supprimer"].tap()

        // Then
        XCTAssertTrue(app.navigationBars["Liste des clients"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.staticTexts["Frida Kahlo"].exists,
                       "Le client supprimé ne doit plus apparaître dans la liste.")
    }

    func testGivenDetailView_WhenTappingSupprimer_ThenListCountDecreasedByOne() {
        // Given — Frida est en tête, Mahatma en deuxième position dans Source.json
        XCTAssertTrue(app.staticTexts["Frida Kahlo"].waitForExistence(timeout: 3),
                      "Précondition : Frida Kahlo doit être visible avant la suppression.")
        XCTAssertTrue(app.staticTexts["Mahatma Gandhi"].exists,
                      "Précondition : Mahatma Gandhi (2e position) doit aussi être visible avant la suppression.")
        openFirstClientDetail()
        XCTAssertTrue(app.buttons["Supprimer"].waitForExistence(timeout: 3))

        // When
        app.buttons["Supprimer"].tap()

        // Then — Frida disparaît, Mahatma reste : la liste a diminué d'exactement un élément.
        // (La comparaison par cells.count n'est pas fiable ici, car SwiftUI ne rend que les cellules
        // visibles dans le viewport, indépendamment du nombre total d'éléments.)
        XCTAssertTrue(app.navigationBars["Liste des clients"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.staticTexts["Frida Kahlo"].exists,
                       "Le client supprimé doit disparaître de la liste.")
        XCTAssertTrue(app.staticTexts["Mahatma Gandhi"].exists,
                      "Mahatma Gandhi doit toujours être présent — preuve qu'une seule entrée a été retirée.")
    }

    // MARK: - Round-trip UI: ajouter un client puis le supprimer

    func testGivenAddedClient_WhenNavigatingToDetailAndDeleting_ThenListRestoresToOriginalCount() {
        // Given
        let initialCount = app.tables.cells.count
        openAjoutClientView()
        app.textFields["Nom"].tap()
        app.textFields["Nom"].typeText("Isaac Newton")
        app.textFields["Email"].tap()
        app.textFields["Email"].typeText("isaac.newton@example.com")
        app.buttons["Ajouter"].tap()
        XCTAssertTrue(app.staticTexts["Isaac Newton"].waitForExistence(timeout: 3),
                      "Precondition : le client ajouté doit apparaître dans la liste.")

        // When — navigation vers le détail puis suppression
        app.staticTexts["Isaac Newton"].tap()
        XCTAssertTrue(app.buttons["Supprimer"].waitForExistence(timeout: 3))
        app.buttons["Supprimer"].tap()

        // Then
        XCTAssertTrue(app.navigationBars["Liste des clients"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.staticTexts["Isaac Newton"].exists,
                       "Le client ajouté puis supprimé ne doit plus figurer dans la liste.")
        XCTAssertEqual(app.tables.cells.count, initialCount,
                       "Après ajout + suppression, le nombre de clients doit être revenu à son état initial.")
    }
}
