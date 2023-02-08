//
//  Stamp.swift
//  BStamp
//
//  Created by wesley on 2023/2/5.
//

import Foundation
import SwiftyJSON
import CoreData

class Stamp:Hashable{
        
        static func == (lhs: Stamp, rhs: Stamp) -> Bool {
                return lhs.Addr == rhs.Addr && lhs.MailBox == rhs.MailBox && lhs.IsConsumable == rhs.IsConsumable
        }
        
        var Addr:String
        var MailBox:String
        var IsConsumable:Bool
        
        init(){
                Addr = ""
                MailBox = ""
                IsConsumable = false
        }
        init(json:JSON){
                self.Addr = json["Addr"].string ?? ""
                self.MailBox = json["MailBox"].string ?? ""
                self.IsConsumable = json["IsConsumable"].bool ?? false
        }
        
        init(obj:CoreData_Stamp){
                self.Addr = obj.address ?? ""
                self.MailBox = obj.mailbox ?? ""
                self.IsConsumable = obj.isConsummable
        }
        
        func hash(into hasher: inout Hasher) {
                hasher.combine(Addr)
                hasher.combine(MailBox)
        }
        
        init(Addr: String, MailBox: String, consumable: Bool = false) {
                self.Addr = Addr
                self.MailBox = MailBox
                self.IsConsumable = consumable
        }
        
        func syncToDatabase(){
                let ctx = PersistenceController.shared.container.viewContext
                guard self.Addr.isEmpty else{
                        return
                }
                
                let request: NSFetchRequest<CoreData_Stamp> = CoreData_Stamp.fetchRequest()
                request.fetchLimit = 1
                request.predicate =  NSPredicate(format: "%address == %a",  self.Addr)
               
                var newStamp:CoreData_Stamp?
                do {
                        let results = try ctx.fetch(request)
                        if results.isEmpty {
                                newStamp = CoreData_Stamp(context: ctx)
                                newStamp?.address = self.Addr
                                newStamp?.mailbox = self.MailBox
                                newStamp?.isConsummable = self.IsConsumable
                        } else {
                                newStamp = results.first
//                                newStamp?.mailbox = self.MailBox
//                                newStamp?.isConsummable = self.IsConsumable
                        }
                        
                        try ctx.save()
                } catch let error as NSError {
                        print("Fetch error: \(error) description: \(error.localizedDescription)")
                }
        }
}
