//
//  CalendarInfo+CoreDataProperties.swift
//  CalendarApp
//
//  Created by 임수정 on 2021/03/07.
//
//

import Foundation
import CoreData


extension CalendarInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CalendarInfo> {
        return NSFetchRequest<CalendarInfo>(entityName: "CalendarInfo")
    }

    @NSManaged public var image: Data?
    @NSManaged public var index: Int64
    @NSManaged public var title: String?
    @NSManaged public var id: String?

}

extension CalendarInfo : Identifiable {

}
