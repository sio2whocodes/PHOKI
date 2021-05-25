//
//  CalendarHelper.swift
//  CalendarApp
//
//  Created by 임수정 on 2021/02/08.
//

import Foundation
import UIKit

class CalendarHelper {
    let calendar = Calendar.current
    
    func nextMonth(date: Date) -> Date{
        return calendar.date(byAdding: .month, value: 1, to: date)!
    }
    
    func previousMonth(date: Date) -> Date{
        return calendar.date(byAdding: .month, value: -1, to: date)!
    }
    
    func todayDateString(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "D"
        return dateFormatter.string(from: date)
    }
    
    func monthString(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        return dateFormatter.string(from: date)
    }
    
    func monthStringSingle(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M"
        return dateFormatter.string(from: date)
    }
    
    func yearString(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: date)
    }
    
    func numOfDatesInMonth(date: Date) -> Int{
        let range = calendar.range(of: .day, in: .month, for: date)! 
        return range.count
    }
    
    func dayOfMonth(date: Date) -> Int{
        let components = calendar.dateComponents([.day], from: date)
        return components.day! //ex. 22
    }
    
    func firstDayOfMonth(date: Date) -> Date{
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components)!
    }
    
    func weekDay(date: Date) -> Int{
        let components = calendar.dateComponents([.weekday], from: date)
        return components.weekday! - 1
    }
    
}
