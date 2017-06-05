//
//  Health+CoreDataProperties.swift
//  ADDN
//
//  Created by 黄 康平 on 5/8/17.
//  Copyright © 2017 黄 康平. All rights reserved.
//

import Foundation
import CoreData

extension Health {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Health> {
        return NSFetchRequest<Health>(entityName: "Health");
    }

    @NSManaged public var hba1c: NSDecimalNumber?
    @NSManaged public var height: NSDecimalNumber?
    @NSManaged public var weight: NSDecimalNumber?
    @NSManaged public var creationDate: NSDate?
    @NSManaged public var person: Person?

}
