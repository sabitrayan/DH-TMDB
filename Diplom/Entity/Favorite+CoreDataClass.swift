//
//  Favorite+CoreDataClass.swift
//  Diplom
//
//  Created by ryan on 06.11.2021.
//

import Foundation
import CoreData

@objc(Favorite)
public class Favorite: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Favorite> {
        return NSFetchRequest<Favorite>(entityName: "Favorite")
    }

    @NSManaged public var movieId: String?
    @NSManaged public var timeDate: Date?

}
