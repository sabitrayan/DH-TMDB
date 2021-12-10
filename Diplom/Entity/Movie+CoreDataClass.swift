//
//  Movie+CoreDataClass.swift
//  Diplom
//
//  Created by ryan on 06.11.2021.
//

import Foundation
import CoreData

@objc(Movie)
public class Movie: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Movie> {
        return NSFetchRequest<Movie>(entityName: "Movie")
    }

    @NSManaged public var movieId: String

    @NSManaged public var originalTitle: String?
    @NSManaged public var overview: String?
    @NSManaged public var popularity: Float
    @NSManaged public var posterPath: String?
    @NSManaged public var releaseDate: Date?
    @NSManaged public var voteAverage: Float
    @NSManaged public var cast: NSSet?
    @NSManaged public var videos: String?

    func update(with movie: MovieFeed.MovieProperties) throws {
        movieId = String(movie.id)
        originalTitle = movie.title
        overview = movie.overview
        popularity = movie.popularity
        posterPath = movie.posterPath
        voteAverage = movie.voteAverage
        videos = movie.videos?.results.first?.key ?? ""
    }

}

extension Movie {

    @objc(addCastObject:)
    @NSManaged public func addToCast(_ value: Cast)

    @objc(removeCastObject:)
    @NSManaged public func removeFromCast(_ value: Cast)

    @objc(addCast:)
    @NSManaged public func addToCast(_ values: NSSet)

    @objc(removeCast:)
    @NSManaged public func removeFromCast(_ values: NSSet)

}


enum MovieError: Error {
    case urlError
    case networkUnavailable
    case invalidData
    case missingData
    case decodingError
}

struct MovieFeed: Decodable {
    let results: [MovieProperties]

    struct MovieProperties: Decodable {
        let id: Int
        let title: String
        let overview: String
        let popularity: Float
        let releaseDate: String
        let posterPath: String?
        let voteAverage: Float
        let videos: VideosResponse?

    }
    let page: Int
    let lastPage: Int
}


struct VideosResponse: Decodable {
  let results: [MovieVideo]
}

struct MovieVideo: Decodable {
  let key: String
}

