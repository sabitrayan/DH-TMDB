//
//  Cast+CoreDataClass.swift
//  Diplom
//
//  Created by ryan on 06.11.2021.
//

import Foundation
import CoreData

@objc(Cast)
public class Cast: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Cast> {
        return NSFetchRequest<Cast>(entityName: "Cast")
    }

    @NSManaged public var castID: Int32
    @NSManaged public var character: String?
    @NSManaged public var name: String?
    @NSManaged public var order: Int32
    @NSManaged public var profilePath: String?
    @NSManaged public var movie: Movie?

    func update(with cast: CastFeed.CastItem) throws {
        castID = Int32(cast.castID)
        order = Int32(cast.order)
        character = cast.character
        name = cast.name
        profilePath = cast.profilePath
    }
}


struct CastFeed: Decodable {
    let id: Int
    let cast: [CastItem]

    struct CastItem: Decodable {
        let id: Int
        let castID: Int
        let character: String
        let creditId: String
        let name: String
        let order: Int
        let profilePath: String?
    }
}
