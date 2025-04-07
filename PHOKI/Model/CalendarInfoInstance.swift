//
//  CalendarInfoInstance.swift
//  CalendarApp
//
//  Created by 임수정 on 2021/03/13.
//

import Foundation

class CalendarInfoInstance {
    var title: String = "MY CALENDAR"
    var image: Data?
    var id: String = "id" // uuid
    var index: Int
    
    init(title: String, image: Data, id: String, index: Int) {
        self.title = title
        self.image = image
        self.id = id
        self.index = index
    }
    init(image: Data, index: Int) {
        self.image = image
        self.index = index
    }
}
