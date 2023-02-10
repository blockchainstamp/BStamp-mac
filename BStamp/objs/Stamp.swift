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
        
        public static var Stamps:[Stamp] = []
        
        static func == (lhs: Stamp, rhs: Stamp) -> Bool {
                return lhs.Addr == rhs.Addr && lhs.MailBox == rhs.MailBox && lhs.IsConsumable == rhs.IsConsumable
        }
        
        var Addr:String
        var MailBox:String
        var IsConsumable:Bool
        var balance:Int64 = 0
        var nonce:Int64 = 0
        
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
                self.balance = obj.balance
                self.nonce = obj.nonce
        }
        
        func hash(into hasher: inout Hasher) {
                hasher.combine(Addr)
                hasher.combine(MailBox)
                hasher.combine(balance)
                hasher.combine(nonce)
        }
        
        init(Addr: String, MailBox: String, consumable: Bool = false) {
                self.Addr = Addr
                self.MailBox = MailBox
                self.IsConsumable = consumable
        }
        
        func syncToDatabase() -> Error?{
                let ctx = PersistenceController.shared.container.viewContext
                guard self.Addr.isEmpty else{
                        return  NSError(domain: "stamp", code: 110, userInfo: ["localizedDescription" : "stamp address is empty"])
                }
                
                let request: NSFetchRequest<CoreData_Stamp> = CoreData_Stamp.fetchRequest()
                request.fetchLimit = 1
                request.predicate =  NSPredicate(format: "address = %@",  self.Addr)
               
                var newStamp:CoreData_Stamp?
                do {
                        let results = try ctx.fetch(request)
                        if results.isEmpty {
                                newStamp = CoreData_Stamp(context: ctx)
                                newStamp?.address = self.Addr
                                newStamp?.mailbox = self.MailBox
                                newStamp?.isConsummable = self.IsConsumable
                                newStamp?.balance = self.balance
                                newStamp?.nonce = self.nonce
                        } else {
                                newStamp = results.first
                                newStamp?.mailbox = self.MailBox
                                newStamp?.isConsummable = self.IsConsumable
                                newStamp?.balance = self.balance
                                newStamp?.nonce = self.nonce
                        }
                        
                        try ctx.save()
                } catch let error as NSError {
                        print("Fetch error: \(error) description: \(error.localizedDescription)")
                        return error
                }
                return nil
        }
        
        static public func loadSavedStamp(){
                do {
                        Stamps.removeAll()
                        let ctx = PersistenceController.shared.container.viewContext
                        
                        let request: NSFetchRequest<CoreData_Stamp> = CoreData_Stamp.fetchRequest()
                        
                        let results = try ctx.fetch(request)
                        if results.isEmpty{
                                return
                        }
                        
                        for obj in results{
                                let s = Stamp(obj:obj)
                                Stamps.append(s)
                        }
                        print("------>>>stamp count:", self.Stamps.count)
                }catch let err{
                        print("------>>> load stamp data from database:", err.localizedDescription)
                }
        }
}

extension Stamp{
        
        static func hasObj(addr:String) -> Bool{
                return findDBObj(addr: addr) != nil
        }
        
        static func findDBObj(addr:String)->CoreData_Stamp?{
                let ctx = PersistenceController.shared.container.viewContext
                if addr == ""{
                        return nil
                }
                
                let request: NSFetchRequest<CoreData_Stamp> = CoreData_Stamp.fetchRequest()
                request.fetchLimit = 1
                request.predicate =  NSPredicate(format: "address = %@",  addr)
                do{
                        let results = try ctx.fetch(request)
                        return results.first
                }catch let err as NSError{
                        print("Fetch error: \(err) description: \(err.userInfo)")
                        return nil
                }
        }
}
