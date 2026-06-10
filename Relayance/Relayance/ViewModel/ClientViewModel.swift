//
//  ClientViewModel.swift
//  Relayance
//

import Foundation
import Observation

@MainActor
@Observable
final class ClientViewModel {
    var clientsList: [Client] = ModelData.chargement("Source.json")

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
