//
//  ListClientsView.swift
//  Relayance
//

import SwiftUI

struct ListClientsView: View {
    @State private var viewModel = ClientViewModel()
    @State private var showModal = false

    var body: some View {
        NavigationStack {
            List(viewModel.clientsList, id: \.self) { client in
                NavigationLink {
                    DetailClientView(client: client, viewModel: viewModel)
                } label: {
                    Text(client.nom)
                        .font(.title3)
                }
            }
            .navigationTitle("Liste des clients")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Ajouter un client") {
                        showModal.toggle()
                    }
                    .foregroundStyle(.orange)
                    .bold()
                }
            }
            .sheet(isPresented: $showModal) {
                AjoutClientView(viewModel: viewModel, dismissModal: $showModal)
            }
        }
    }
}

#Preview {
    ListClientsView()
}

