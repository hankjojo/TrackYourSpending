//
//  Mood+CoreDataProperties.swift
//  
//
//  Created by 江宗翰 on 2018/1/8.
//
//

import Foundation
import CoreData


extension Mood {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Mood> {
        return NSFetchRequest<Mood>(entityName: "Mood")
    }

    @NSManaged public var createDate: NSDate?
    @NSManaged public var emoji: String?
    @NSManaged public var id: UUID?
    @NSManaged public var text: String?

}
