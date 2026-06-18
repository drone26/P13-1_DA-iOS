//
//  ClientViewModel.swift
//  Relayance
//
// Created by Mathieu Arrio on 09/06/2026
//

import Foundation
import Observation

@MainActor
@Observable
final class ClientViewModel {
    var clientsList: [Client] = []

    /// Initialiseur principal. `nomFichier` et `bundle` sont injectables pour
    /// permettre aux tests de forcer un échec de chargement (fichier
    /// manquant, illisible, ou JSON malformé) sans dépendre de l'état réel
    /// du bundle de l'application — `init()` ci-dessous garde le
    /// comportement de production inchangé en appelant celui-ci avec les
    /// valeurs par défaut.
    init(nomFichier: String = "Source.json", bundle: Bundle = .main) {
        do {
            clientsList = try ModelData.chargement(nomFichier, bundle: bundle)
        } catch {
            // En cas d'échec de chargement (fichier manquant, illisible, ou JSON
            // malformé), l'application démarre avec une liste vide plutôt que de
            // crasher. L'erreur est journalisée pour faciliter le diagnostic.
            print("ClientViewModel: échec du chargement de \(nomFichier) — \(error)")
            clientsList = []
        }
    }

    // MARK: - Validation

    /// Validates that the email has a basic valid format.
    func isValidEmail(_ email: String) -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespaces)
        // Simple RFC-compliant check: local@domain.tld
        let regex = /^[^@\s]+@[^@\s]+\.[^@\s]+$/
        return trimmed.wholeMatch(of: regex) != nil
    }

    func isValidName(_ name: String) -> Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Mutations

    func addClient(nom: String, email: String) {
        let newClient = Client.creerNouveauClient(nom: nom.trimmingCharacters(in: .whitespaces),
                                                  email: email.trimmingCharacters(in: .whitespaces))
        clientsList.append(newClient)
    }

    func deleteClient(_ client: Client) {
        clientsList.removeAll { $0 == client }
    }
}

