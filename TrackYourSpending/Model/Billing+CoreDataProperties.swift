//
//  Billing+CoreDataProperties.swift
//  
//
//  Created by 江宗翰 on 2018/1/8.
//
//

import Foundation
import CoreData


extension Billing {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Billing> {
        return NSFetchRequest<Billing>(entityName: "Billing")
    }

    @NSManaged public var billing_type: Int32
    @NSManaged public var create_date: NSDate?
    @NSManaged public var date: NSDate?
    @NSManaged public var id: UUID?
    @NSManaged public var money: Int32
    @NSManaged public var money_type: String?
    @NSManaged public var mood: String?
    @NSManaged public var note: String?
    @NSManaged public var money_type_emoji: String?
    @NSManaged public var mood_emoji: String?

}
