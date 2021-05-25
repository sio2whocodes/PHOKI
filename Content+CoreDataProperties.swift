//
//  Content+CoreDataProperties.swift
//  CalendarApp
//
//  Created by 임수정 on 2021/03/19.
//
//

import Foundation
import CoreData


extension Content {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Content> {
        return NSFetchRequest<Content>(entityName: "Content")
    }

    @NSManaged public var date: String?
    @NSManaged public var images: [Data]?
    @NSManaged public var memos: [String]?
    @NSManaged public var thumnail: Data?
    @NSManaged public var calendarId: String?

}

extension Content : Identifiable {

}
