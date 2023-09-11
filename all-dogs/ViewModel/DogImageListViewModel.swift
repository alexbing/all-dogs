//
//  DogImageListViewModel.swift
//  all-dogs
//
//  Created by Alex Binguy on 11/09/2023.
//

import Foundation

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
        guard let url = URL(string: "https://dog.ceo/api/breed/\(breed)/images") else { return }
        
        print("fetching images for \(breed)...")
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("Error fetching images: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            if let resource = try? JSONDecoder().decode(ImageListResource.self, from: data) {
                resource.message.forEach { imageUrlString in
                    guard let imageUrl = URL(string: imageUrlString) else {
                        print("Unable to parse image URL: \(imageUrlString)")
                        return
                    }
                    URLSession.shared.dataTask(with: imageUrl) { imageData, _, error in
                        guard let imageData = imageData, error == nil else {
                            print("Error fetching image \(imageUrl) : \(error?.localizedDescription ?? "Unknown error")")
                            return
                        }
                        
                        DispatchQueue.main.async {
                            let dogImage = DogImage(imageName: imageUrlString, imageData: imageData)
                            self.dogImages.append(dogImage)
                        }
                    }.resume()
                }
            } else {
                print("No image found")
            }
            
        }.resume()
        
    }
    
    
}
