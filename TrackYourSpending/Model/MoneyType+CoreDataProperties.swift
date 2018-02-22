//
//  MoneyType+CoreDataProperties.swift
//  
//
//  Created by 江宗翰 on 2018/1/8.
//
//

import Foundation
import CoreData


extension MoneyType {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MoneyType> {
        return NSFetchRequest<MoneyType>(entityName: "MoneyType")
    }

    @NSManaged public var createDate: NSDate?
    @NSManaged public var emoji: String?
    @NSManaged public var id: UUID?
    @NSManaged public var text: String?
    @NSManaged public var type: Int32

}
