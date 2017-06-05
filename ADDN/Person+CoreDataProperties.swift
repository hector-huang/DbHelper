//
//  Person+CoreDataProperties.swift
//  ADDN
//
//  Created by 黄 康平 on 5/8/17.
//  Copyright © 2017 黄 康平. All rights reserved.
//

import Foundation
import CoreData

extension Person {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Person> {
        return NSFetchRequest<Person>(entityName: "Person");
    }

    @NSManaged public var age: Int16
    @NSManaged public var name: String?
    @NSManaged public var gender: String?
    @NSManaged public var healths: NSSet?
    @NSManaged public var creationDate: NSDate?

}

// MARK: Generated accessors for healths
extension Person {

    @objc(addHealthsObject:)
    @NSManaged public func addToHealths(_ value: Health)

    @objc(removeHealthsObject:)
    @NSManaged public func removeFromHealths(_ value: Health)

    @objc(addHealths:)
    @NSManaged public func addToHealths(_ values: NSSet)

    @objc(removeHealths:)
    @NSManaged public func removeFromHealths(_ values: NSSet)

}
