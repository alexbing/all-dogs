//
//  all_dogsApp.swift
//  all-dogs
//
//  Created by Alex Binguy on 11/09/2023.
//

import SwiftUI

@main
struct all_dogsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            let breedListViewModel = BreedListViewModel()
            BreedListView(viewModel: breedListViewModel)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
