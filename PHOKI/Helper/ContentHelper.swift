//
//  ContentHelper.swift
//  CalendarApp
//
//  Created by 임수정 on 2021/02/21.
//

import Foundation
import UIKit
import CoreData

let appDelegate = UIApplication.shared.delegate as! AppDelegate
let context = appDelegate.persistentContainer.viewContext

class ContentHelper {
    let entity = NSEntityDescription.entity(forEntityName: "Content", in: context)
    
    func fetchContentsAll(){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Content")
        var contents = [Content]()
        do {
            contents = try context.fetch(fetchRequest) as! [Content]
        } catch {
            print(error.localizedDescription)
        }
        for content in contents {
            thumnails[content.date!] = UIImage(data: content.thumnail!)
        }
    }
    
    func fetchContents(calId: String){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Content")
        fetchRequest.predicate = NSPredicate(format: "calendarId == %@", calId)
        var contents = [Content]()
        do {
            contents = try context.fetch(fetchRequest) as! [Content]
        } catch {
            print(error.localizedDescription)
        }
        thumnails.removeAll()
        for content in contents {
            thumnails[content.date!] = UIImage(data: content.thumnail!)
        }
    }
    
    func fetchContentsOfYearMonth(calId: String, yyyyMM: String) -> [String:UIImage]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Content")
        fetchRequest.predicate = NSPredicate(format: "calendarId == %@ AND date BEGINSWITH %@", calId, yyyyMM)
        var contents = [Content]()
        do {
            contents = try context.fetch(fetchRequest) as! [Content]
        } catch {
            print(error.localizedDescription)
        }
        
        // 전역 변수 교체 (기존)
//        thumnails.removeAll()
//        for content in contents {
//            thumnails[content.date!] = UIImage(data: content.thumnail!)
//        }
        
        // 딕셔너리 전달 (신규)
        var newThumnails: [String:UIImage] = [:]
        for content in contents {
            newThumnails[content.date!] = UIImage(data: content.thumnail!)
        }
        return newThumnails
    }
    
    func fetchContent(date: String, calId: String)->Any?{
        var contentss = [Content]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Content")
        if date != "" {
            fetchRequest.predicate = NSPredicate(format: "date == %@ AND calendarId == %@", date, calId)
        }
        do {
            contentss = try context.fetch(fetchRequest) as! [Content]
        } catch {
            print(error.localizedDescription)
        }
        if !contentss.isEmpty {
            let content = contentss[0]
            return MyContent(date: content.date!, images: content.images!, memos: content.memos!, thumnail: UIImage(data: content.thumnail!)!, calId: content.calendarId!)
        } else {
            return nil
        }
    }
    
    func updateContent(mycontent: MyContent){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Content")
        fetchRequest.predicate = NSPredicate(format: "date == %@ AND calendarId == %@", mycontent.date, mycontent.calId)
        do {
            let contents = try context.fetch(fetchRequest) as! [Content]
            let updateContent = contents[0] as NSManagedObject
            updateContent.setValue(mycontent.date, forKey: "date")
            updateContent.setValue(mycontent.images, forKey: "images")
            updateContent.setValue(mycontent.memos, forKey: "memos")
            updateContent.setValue(mycontent.thumnail.jpegData(compressionQuality: 0.5), forKey: "thumnail")
            updateContent.setValue(mycontent.calId, forKey: "calendarId")
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchContentThumnail(date: String, calId: String){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Content")
        fetchRequest.predicate = NSPredicate(format: "date == %@ AND calendarId == %@", date, calId)
        do {
            let updateContents = try context.fetch(fetchRequest) as! [Content]
            let updateContent = updateContents[0]
            thumnails[updateContent.date!] = UIImage(data: updateContent.thumnail!)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func insertContent(mycontent: MyContent){
        if let entity = self.entity {
            let content = NSManagedObject(entity: entity, insertInto: context)
            content.setValue(mycontent.date, forKey: "date")
            content.setValue(mycontent.images, forKey: "images")
            content.setValue(mycontent.memos, forKey: "memos")
            content.setValue(mycontent.thumnail.jpegData(compressionQuality: 0.5), forKey: "thumnail")
            content.setValue(mycontent.calId, forKey: "calendarId")
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func deleteAllContent(){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Content")
        let delete = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(delete)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteCalendarContent(calInst: CalendarInfoInstance){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Content")
        fetchRequest.predicate = NSPredicate(format: "calendarId == %@", calInst.id)
        let delete = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(delete)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteContent(mycontent: MyContent){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Content")
        fetchRequest.predicate = NSPredicate(format: "date == %@ AND calendarId == %@", mycontent.date, mycontent.calId)
        do {
            let contents = try context.fetch(fetchRequest) as! [Content]
            let deleteContent = contents[0] as NSManagedObject
            context.delete(deleteContent)
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        } catch {
            print(error.localizedDescription)
        }
        thumnails[mycontent.date] = nil
    }
}

extension UIImage {

    func getThumbnail() -> UIImage? {
        guard let imageData = self.jpegData(compressionQuality: 0.1) else { return nil }

        let options = [
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: 200] as CFDictionary

        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil) else { return nil }
        guard let imageReference = CGImageSourceCreateThumbnailAtIndex(source, 0, options) else { return nil }

        return UIImage(cgImage: imageReference)
    }
    
    
}
