//
//  DetailClientView.swift
//  Relayance
//

import SwiftUI

struct DetailClientView: View {
    @Environment(\.dismiss) private var dismiss
    var client: Client
    var viewModel: ClientViewModel

    var body: some View {
        VStack {
            Image(systemName: "person.circle")
                .resizable()
                .frame(width: 150, height: 150)
                .foregroundStyle(.orange)
                .padding(50)
            Spacer()
            Text(client.nom)
                .font(.title)
                .padding()
            Text(client.email)
                .font(.title3)
            Text(client.formatDateVersString())
                .font(.title3)
            Spacer()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Supprimer") {
                    viewModel.deleteClient(client)
                    dismiss()
                }
                .foregroundStyle(.red)
                .bold()
            }
        }
    }
}

#Preview {
    DetailClientView(
        client: Client(nom: "Tata", email: "tata@email.com", dateCreationString: "2024-07-10T14:30:00Z"),
        viewModel: ClientViewModel()
    )
}
