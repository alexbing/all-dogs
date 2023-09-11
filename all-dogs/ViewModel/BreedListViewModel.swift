//
//  BreedListViewModel.swift
//  all-dogs
//
//  Created by Alex Binguy on 11/09/2023.
//

import SwiftUI
import CoreData

class BreedListViewModel: ObservableObject {
    @Published var breeds: [String] = []
    
    func fetchBreeds() {
        print("fetching all breeds...")
        
        fetchBreedsFromUrl() { success in
            if !success {
                print("Unable to fetch breed from URL. Let's try in local")
                self.fetchBreedsFromLocal()
            }
        }
    }
    
    func fetchBreedsFromUrl(completion: @escaping (_ success: Bool) -> ()) {
        guard let url = URL(string: "https://dog.ceo/api/breeds/list/all") else {
            completion(false)
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("Error fetching breeeds: \(error?.localizedDescription ?? "Unknown error")")
                completion(false)
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                let message = json["message"] as? [String: [String]]
                
                let breedNames = message?.keys.compactMap { name in
                    name
                } ?? []
                
                print("\(breedNames.count) breeds found from URL")
                self.saveBreeds(breedNames)
                
                DispatchQueue.main.async {
                    self.breeds = breedNames
                }
                completion(true)
            } else {
                completion(false)
                print("No breed found")
            }
        }.resume()
    }
    
    func fetchBreedsFromLocal() {
        let context = PersistenceController.shared.container.viewContext
        do {
            let storedBreeds = try context.fetch(Breed.fetchRequest())
            print("\(storedBreeds.count) breeds found from local storage")
            
            DispatchQueue.main.async {
                self.breeds = storedBreeds.compactMap{ $0.name }
            }
        } catch {
            print("Error while trying to fetch breed from local storage")
        }
    }
    
    func saveBreeds(_ breedNames: [String]) {
        // Delete existing breeds
        let context = PersistenceController.shared.container.viewContext
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Breed.self))
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do {
            try context.execute(deleteRequest)
        } catch {
            print("Error while trying to truncate breed table")
        }
        
        for breedName in breedNames {
            let breedEntity = NSEntityDescription.entity(forEntityName: String(describing: Breed.self), in: context)!
            let storedBreed = NSManagedObject(entity: breedEntity, insertInto: context) as? Breed
            storedBreed?.name = breedName
        }
        do {
            try context.save()
        } catch {
            print("Error while trying to save the breed")
        }
    }
}
