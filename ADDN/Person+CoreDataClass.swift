//
//  Person+CoreDataClass.swift
//  ADDN
//
//  Created by 黄 康平 on 5/8/17.
//  Copyright © 2017 黄 康平. All rights reserved.
//

import Foundation
import CoreData


public class Person: NSManagedObject {
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        self.creationDate = NSDate()
    }
}
