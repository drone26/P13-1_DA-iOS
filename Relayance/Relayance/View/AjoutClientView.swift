//
//  AjoutClientView.swift
//  Relayance
//

import SwiftUI

struct AjoutClientView: View {
    var viewModel: ClientViewModel
    @Binding var dismissModal: Bool

    @State private var nom: String = ""
    @State private var email: String = ""
    @State private var showValidationError = false

    private var isFormValid: Bool {
        viewModel.isValidName(nom) && viewModel.isValidEmail(email)
    }

    var body: some View {
        VStack {
            Text("Ajouter un nouveau client")
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.center)
            Spacer()

            VStack(alignment: .leading, spacing: 4) {
                TextField("Nom", text: $nom)
                    .font(.title2)
                if showValidationError && !viewModel.isValidName(nom) {
                    Text("Le nom ne peut pas être vide.")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                TextField("Email", text: $email)
                    .font(.title2)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                if showValidationError && !viewModel.isValidEmail(email) {
                    Text("L'adresse e-mail n'est pas valide.")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }

            Button("Ajouter") {
                guard isFormValid else {
                    showValidationError = true
                    return
                }
                viewModel.addClient(nom: nom, email: email)
                dismissModal = false
            }
            .padding(.horizontal, 50)
            .padding(.vertical)
            .font(.title2)
            .bold()
            .background(RoundedRectangle(cornerRadius: 10).fill(.orange))
            .foregroundStyle(.white)
            .padding(.top, 50)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    AjoutClientView(viewModel: ClientViewModel(), dismissModal: .constant(false))
}
