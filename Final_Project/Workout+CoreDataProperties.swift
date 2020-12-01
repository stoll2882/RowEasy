//
//  Workout+CoreDataProperties.swift
//  Final_Project
//
//  Created by Sam Toll on 11/29/20.
//
//

import Foundation
import CoreData


extension Workout {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Workout> {
        return NSFetchRequest<Workout>(entityName: "Workout")
    }

    @NSManaged public var workoutType: Int32
    @NSManaged public var avgSplit: String?
    @NSManaged public var totalTime: String?
    @NSManaged public var distance: Int32
    @NSManaged public var avgStrokeRate: Int32
    @NSManaged public var date: Date?
    @NSManaged public var time: String

}

extension Workout : Identifiable {

}
