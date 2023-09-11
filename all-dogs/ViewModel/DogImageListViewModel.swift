//
//  DogImageListViewModel.swift
//  all-dogs
//
//  Created by Alex Binguy on 11/09/2023.
//

import Foundation
import CoreData

struct DogImage: Hashable {
    let imageName: String
    let imageData: Data
}

class DogImageListViewModel: ObservableObject {
    let breed: String
    @Published var dogImages: [DogImage] = []
    
    init(breed: String) {
        self.breed = breed
    }
    
    func fetchImages() {
        print("fetching all dogs for breed \(breed)...")
        fetchImagesFromUrl() { success in
            if !success {
                print("Unable to fetch breed from URL. Let's try in local")
                self.fetchImagesFromLocal()
            }
        }
    }
    
    func fetchImagesFromUrl(completion: @escaping (_ success: Bool) -> ()) {
        guard let url = URL(string: "https://dog.ceo/api/breed/\(breed)/images") else {
            completion(false)
            return
        }
        
        print("fetching images for \(breed)...")
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("Error fetching images: \(error?.localizedDescription ?? "Unknown error")")
                completion(false)
                return
            }
            
            if let resource = try? JSONDecoder().decode(ImageListResource.self, from: data) {
                resource.message.forEach { imageUrlString in
                    guard let imageUrl = URL(string: imageUrlString) else {
                        print("Unable to parse image URL: \(imageUrlString)")
                        completion(false)
                        return
                    }
                    completion(true)
                    URLSession.shared.dataTask(with: imageUrl) { imageData, _, error in
                        guard let imageData = imageData, error == nil else {
                            print("Error fetching image \(imageUrl) : \(error?.localizedDescription ?? "Unknown error")")
                            // No completion here since we don't want to go to offline mode only beacause one image fetching has failed
                            return
                        }
                        
                        let dogImage = DogImage(imageName: imageUrlString, imageData: imageData)
                        self.save(image: dogImage)
                        
                        DispatchQueue.main.async {
                            self.dogImages.append(dogImage)
                        }
                    }.resume()
                }
            } else {
                print("No image found")
                completion(false)
            }
            
        }.resume()
        
    }
    
    func fetchImagesFromLocal() {
        let context = PersistenceController.shared.container.viewContext
        do {
            let request = NSFetchRequest<NSManagedObject>(entityName: String(describing: Dog.self))
            request.predicate = NSPredicate(format: "breed = %@", breed)
            let result = try context.fetch(request)
            if let storedDogs = result as? [Dog] {
                print("\(storedDogs.count) dogs found from local storage for breed \(breed)")
                DispatchQueue.main.async {
                    self.dogImages = storedDogs.compactMap {
                        if let imageName = $0.imageName, let imageData = $0.imageData {
                            return DogImage(imageName: imageName, imageData: imageData)
                        } else {
                            print("Incoherent data from local storage. Cannot be displayed correctly")
                            return nil
                        }
                    }
                }
            } else {
                print("No dog found for breed \(breed)")
            }
        } catch {
            print("Error while trying to fetch dogs from local storage for breed \(breed)")
        }
    }
    
    func save(image: DogImage) {
        // Delete existing image
        let context = PersistenceController.shared.container.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: String(describing: Dog.self))
        request.predicate = NSPredicate(format: "imageName = %@", image.imageName)
        do {
            let result = try context.fetch(request)
            if let dogs = result as? [Dog] {
                for dog in dogs {
                    context.delete(dog)
                }
            }
        } catch {
            print("Error while trying to remove dog from local storage")
        }
        
        // Save image
        let dogEntity = NSEntityDescription.entity(forEntityName: String(describing: Dog.self), in: context)!
        let storedDog = NSManagedObject(entity: dogEntity, insertInto: context) as? Dog
        storedDog?.breed = breed
        storedDog?.imageName = image.imageName
        storedDog?.imageData = image.imageData
        
        do {
            try context.save()
        } catch {
            print("Error while trying to save a dog \(image.imageName)")
        }
    }
}
