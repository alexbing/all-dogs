//
//  BreedListViewModel.swift
//  all-dogs
//
//  Created by Alex Binguy on 11/09/2023.
//

import SwiftUI

class BreedListViewModel: ObservableObject {
    @Published var breeds: [String] = []
    
    func fetchBreeds() {
        guard let url = URL(string: "https://dog.ceo/api/breeds/list/all") else { return }
        print("fetching all breeds...")
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("Error fetching breeeds: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                let message = json["message"] as? [String: [String]]
                
                let breedNames = message?.keys.compactMap { name in
                    name
                } ?? []
                
                DispatchQueue.main.async {
                    self.breeds = breedNames
                }
            } else {
                print("No breed found")
            }
        }.resume()
    }
}
