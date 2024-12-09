//
//  CalendarInfoHelper.swift
//  CalendarApp
//
//  Created by 임수정 on 2021/03/06.
//

import Foundation
import UIKit
import CoreData

class CalendarInfoHelper {
    let entity = NSEntityDescription.entity(forEntityName: "CalendarInfo", in: context)

    func insertCalender(calInst: CalendarInfoInstance){
        if let entity = self.entity {
            let calInfo = NSManagedObject(entity: entity, insertInto: context)
            calInfo.setValue(calInst.title, forKey: "title")
            calInfo.setValue(calInst.index, forKey: "index")
            calInfo.setValue(calInst.image, forKey: "image")
            calInfo.setValue(calInst.id, forKey: "id")
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func fetchCalendarInfo(calIdex: String)->CalendarInfoInstance{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CalendarInfo")
        fetchRequest.predicate = NSPredicate(format: "id == %@", calIdex)
        var calendarInst: CalendarInfoInstance = CalendarInfoInstance(image: (UIImage(named: "bluecloud")?.jpegData(compressionQuality: 1))!, index: Int(Date().timeIntervalSince1970))
        var calendarInfo = [CalendarInfo]()
        do {
            calendarInfo = try context.fetch(fetchRequest) as! [CalendarInfo]
        } catch {
            print(error.localizedDescription)
        }
        calendarInst = CalendarInfoInstance(title: calendarInfo[0].title!, image: calendarInfo[0].image!, id: calendarInfo[0].id!, index: Int(calendarInfo[0].index))
        return calendarInst
    }
    
    func fetchCalendarInfoList()->[CalendarInfoInstance]{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CalendarInfo")
        let indexSort = NSSortDescriptor(key:"index", ascending:true)
        fetchRequest.sortDescriptors = [indexSort]
        var calendarList = [CalendarInfoInstance]()
        var calendarInfos = [CalendarInfo]()
        do {
            calendarInfos = try context.fetch(fetchRequest) as! [CalendarInfo]
        } catch {
            print(error.localizedDescription)
        }
        for cal in calendarInfos {
            calendarList.append(CalendarInfoInstance(title: cal.title!, image: cal.image!, id: cal.id!, index: Int(cal.index)))
        }
        return calendarList
    }
    
    func updateCalendarInfo(calInst: CalendarInfoInstance){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CalendarInfo")
        fetchRequest.predicate = NSPredicate(format: "id == %@", calInst.id)
        do {
            let calendarInfos = try context.fetch(fetchRequest) as! [CalendarInfo]
            let calendarInfo = calendarInfos[0] as NSManagedObject
            calendarInfo.setValue(calInst.id, forKey: "id")
            calendarInfo.setValue(calInst.title, forKey: "title")
            calendarInfo.setValue(calInst.image, forKey: "image")
            calendarInfo.setValue(calInst.index, forKey: "index")
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteCalendarInfoAll(){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CalendarInfo")
        let delete = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(delete)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteCalendar(calInst: CalendarInfoInstance){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CalendarInfo")
        fetchRequest.predicate = NSPredicate(format: "id == %@", calInst.id)
        let delete = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(delete)
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getUniqueIndexOfCalendar() -> String {
        // unique idext 생성
        let uuid:String = UserDefaults.standard.value(forKey: "uuid") as? String ?? "\(UUID())"
        let timestamp:Int64 = Int64(Date().timeIntervalSince1970)
        let uindex:String = "\(uuid)-\(timestamp)"
        return uindex
    }
}
