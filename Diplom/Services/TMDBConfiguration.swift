//
//  Services.swift
//  Diplom
//
//  Created by ryan on 06.11.2021.
//

import Foundation

struct TMDBConfiguration: Decodable {
    let images: ImageConfig

    struct ImageConfig: Decodable {
        let baseUrl: String
        let secureBaseUrl: String
        let posterSizes: [String]
    }
}
