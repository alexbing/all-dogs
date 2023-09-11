//
//  DogImageListView.swift
//  all-dogs
//
//  Created by Alex Binguy on 11/09/2023.
//

import SwiftUI

struct DogImageListView: View {
    @ObservedObject var viewModel: DogImageListViewModel
    
    var body: some View {
        VStack {
            // To show that the view is updated as soon as an image is fetched
            Text("images of \(viewModel.breed): \(viewModel.dogImages.count)")
            
            List(viewModel.dogImages, id: \.self) { dogImage in
                if let uiImage = UIImage(data: dogImage.imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                }
            }.onAppear {
                viewModel.fetchImages()
            }
        }
        
    }
}
//
//struct DogImageListView_Previews: PreviewProvider {
//    static var previews: some View {
//        DogImageListView()
//    }
//}
