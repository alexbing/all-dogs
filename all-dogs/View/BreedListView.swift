//
//  BreedListView.swift
//  all-dogs
//
//  Created by Alex Binguy on 11/09/2023.
//

import SwiftUI

struct BreedListView: View {
    @ObservedObject var viewModel: BreedListViewModel
    
    @State var searchText: String = ""
    
    var filteredSearch: [String] {
        let result = viewModel.breeds.sorted()
        if searchText.isEmpty {
            return result
        }
        return result.filter{
            $0.lowercased().contains(searchText.lowercased())
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Search...", text: $searchText)
                    .padding(.horizontal, 5)
                List(filteredSearch, id: \.self) { breed in
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
}


struct BreadListView_Previews: PreviewProvider {
    static var previews: some View {
        BreedListView(viewModel: BreedListViewModel())
    }
}
