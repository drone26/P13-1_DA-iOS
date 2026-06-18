//
//  ModelData.swift
//  Relayance
//
//  Created by Amandine Cousin on 10/07/2024.
//  Modified by Mathieu Arrio on 10/06/2026
//

import Foundation

enum ModelDataError: Error, Equatable {
    case fichierIntrouvable(nomFichier: String)
    case lectureImpossible(nomFichier: String, raison: String)
    case decodageImpossible(nomFichier: String, typeCible: String, raison: String)
}

struct ModelData {
    static func chargement<T: Decodable>(_ nomFichier: String, bundle: Bundle = .main) throws -> T {
        guard let file = bundle.url(forResource: nomFichier, withExtension: nil) else {
            throw ModelDataError.fichierIntrouvable(nomFichier: nomFichier)
        }

        let data: Data
        do {
            data = try Data(contentsOf: file)
        } catch {
            throw ModelDataError.lectureImpossible(nomFichier: nomFichier, raison: error.localizedDescription)
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            throw ModelDataError.decodageImpossible(
                nomFichier: nomFichier,
                typeCible: String(describing: T.self),
                raison: error.localizedDescription
            )
        }
    }
}
