//
//  DogResource.swift
//  all-dogs
//
//  Created by Alex Binguy on 11/09/2023.
//

import Foundation

struct BreedListResource: Codable {
    let message: [String : [String]]
}

struct BreedResource: Codable {
    let name: String
}
