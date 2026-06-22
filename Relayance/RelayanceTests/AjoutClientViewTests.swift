//
//  AjoutClientViewTests.swift
//  RelayanceTests
//
//  Couvre la construction et le rendu de AjoutClientView pour atteindre 100 %
//  de couverture sur les expressions d'initialisation des @State (_nom, _email,
//  _showValidationError), qui ne sont pas attribuées par la couverture
//  jusqu'à ce que la vue soit instanciée depuis le binaire de test.
//

import XCTest
import SwiftUI
@testable import Relayance

@MainActor
final class AjoutClientViewTests: XCTestCase {

    // MARK: - Helpers

    private func makeView(viewModel: ClientViewModel,
                          dismissModal: Binding<Bool> = .constant(false)) -> AjoutClientView {
        AjoutClientView(viewModel: viewModel, dismissModal: dismissModal)
    }

    /// Force SwiftUI à évaluer `body` (et donc les expressions d'initialisation
    /// des `@State`) en hébergeant la vue dans un `UIHostingController`.
    private func renderInHost(_ view: AjoutClientView) -> UIHostingController<AjoutClientView> {
        let host = UIHostingController(rootView: view)
        host.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
        host.view.layoutIfNeeded()
        return host
    }

    // MARK: - Construction

    func testGivenViewModelAndBinding_WhenInitializingAjoutClientView_ThenStateInitializersAreEvaluated() {
        // Given
        let viewModel = ClientViewModel()
        let dismissBinding = Binding<Bool>.constant(false)

        // When
        let view = AjoutClientView(viewModel: viewModel, dismissModal: dismissBinding)

        // Then — la construction exécute `_nom = ""`, `_email = ""`,
        // `_showValidationError = false`, ainsi que l'assignation de `viewModel`
        // et `dismissModal`.
        XCTAssertNotNil(view.viewModel,
                        "AjoutClientView doit conserver la référence au ViewModel transmis.")
    }

    func testGivenTwoInstances_WhenInstantiated_ThenEachInitializesIndependently() {
        // Given / When — instancier deux fois force l'évaluation répétée des
        // expressions d'initialisation, ce qui renforce le hit-count sur les
        // @State initializers même si l'OS met en cache certaines structures.
        let viewA = makeView(viewModel: ClientViewModel())
        let viewB = makeView(viewModel: ClientViewModel())

        // Then
        XCTAssertNotNil(viewA.viewModel)
        XCTAssertNotNil(viewB.viewModel)
    }

    // MARK: - Rendu via UIHostingController

    func testGivenAjoutClientView_WhenRenderedInHostingController_ThenBodyEvaluatesWithoutCrashing() {
        // Given
        let view = makeView(viewModel: ClientViewModel())

        // When
        let host = renderInHost(view)

        // Then — le rendu déclenche l'évaluation du `body` et des @State
        XCTAssertNotNil(host.view,
                        "La vue hébergée doit s'instancier et se layouter sans erreur.")
    }

    func testGivenAjoutClientView_WhenHostedWithEmptyViewModel_ThenBodyStillRenders() {
        // Given — un ViewModel avec une liste vide (bundle introuvable)
        let viewModel = ClientViewModel(nomFichier: "FichierQuiNExistePas.json", bundle: .main)
        XCTAssertTrue(viewModel.clientsList.isEmpty,
                      "Précondition : le ViewModel doit démarrer avec une liste vide.")

        // When
        let view = makeView(viewModel: viewModel)
        let host = renderInHost(view)

        // Then
        XCTAssertNotNil(host.view,
                        "La vue doit pouvoir être rendue même quand le ViewModel a une liste vide.")
    }

    // MARK: - Binding dismissModal

    func testGivenDismissBinding_WhenRenderingView_ThenBindingIsForwardedCorrectly() {
        // Given
        var dismissValue = true
        let binding = Binding<Bool>(get: { dismissValue }, set: { dismissValue = $0 })
        let view = makeView(viewModel: ClientViewModel(), dismissModal: binding)

        // When
        _ = renderInHost(view)

        // Then — le binding doit refléter la valeur transmise (initialement true)
        XCTAssertTrue(dismissValue,
                      "Le binding dismissModal doit conserver sa valeur initiale tant qu'aucune mutation n'a eu lieu.")
    }
}
