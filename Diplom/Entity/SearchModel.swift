//
//  Search.swift
//  Diplom
//
//  Created by ryan on 12.11.2021.
//

import Foundation

struct SearchResult: Decodable {
    let page : Int
    let results: [Results]
}

struct Results: Decodable {
    let poster_path: String
    let title: String
    let vote_average: Double
    let release_date: String
}
