//
//  BreedListView.swift
//  all-dogs
//
//  Created by Alex Binguy on 11/09/2023.
//

import SwiftUI

struct BreedListView: View {
    @ObservedObject var viewModel: BreedListViewModel
    
    var body: some View {
        NavigationView {
            List(viewModel.breeds.sorted(), id: \.self) { breed in
                NavigationLink {
                    DogImageListView(viewModel: DogImageListViewModel(breed: breed))
                } label: {
                    Text(breed)
                }
            }.onAppear {
                viewModel.fetchBreeds()
            }
        }
    }
}

// TODO:
//struct BreedListView_Previews: PreviewProvider {
//    static var previews: some View {
//        BreedListView()
//    }
//}
