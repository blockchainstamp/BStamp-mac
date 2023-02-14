//
//  Setting.swift
//  BStamp
//
//  Created by wesley on 2023/2/7.
//

import Foundation
import CoreData

class Setting:Hashable{
        
        var mailAcc:String = ""
        var stampAddr:String?
        var smtpSrv:String = ""
        var smtpPort:Int32 = Consts.DefaultSmtpPort
        var imapPort:Int32 = Consts.DefaultImapPort
        var imapSrv:String = ""
        var stampName:String?
        var caName:String = ""
        var smtpSSLOn:Bool=true
        var imapSSLOn:Bool = true
        var caData:Data?
        
        static public var Settings:[Setting] = []
        
        static func == (lhs: Setting, rhs: Setting) -> Bool {
                return lhs.mailAcc == rhs.mailAcc && lhs.stampAddr == rhs.stampAddr
        }
        
        func hash(into hasher: inout Hasher) {
                hasher.combine(mailAcc)
                hasher.combine(stampAddr)
        }
        
        init(){
        }
        
        
        init(email:String, smtp:String, imap:String, stampAddr:String? = nil, stampName:String? = nil, smtpSSL:Bool = true, imapSSL:Bool = true, caName:String="",caData:Data? = nil){
                self.mailAcc = email
                self.smtpSrv = smtp
                self.imapSrv = imap
                self.stampAddr = stampAddr
                self.stampName = stampName
                self.smtpSSLOn = smtpSSL
                self.imapSSLOn = imapSSL
                self.caData = caData
                self.caName = caName
        }
        
        func updateSetting(_ newSetting  :inout CoreData_Setting) throws{
                
                newSetting.smtpSrv = self.smtpSrv
                newSetting.smtpSSLOn = self.smtpSSLOn
                
                newSetting.imapSrv = self.imapSrv
                newSetting.imapSSLOn = self.imapSSLOn
                
                
                newSetting.stampAddr = self.stampAddr
                newSetting.stampName = self.stampName
                
                newSetting.caData = self.caData
                newSetting.caName = self.caName
                
                newSetting.imapPort = self.imapPort
                newSetting.smtpPort = self.smtpPort
                
                guard let data = caData else{
                        return
                }
                
                newSetting.caFilePath = Setting.createCaFile(fileName: self.mailAcc, caData: data)
        }
        
        static func createCaFile(fileName:String, caData:Data)->String?{
                do{
                        guard  let dir = SdkDelegate.inst.libBaseDir else{
                                return nil
                        }
                        var fileUrl = dir
                        fileUrl.appendPathComponent(fileName, isDirectory: false)
                        fileUrl = fileUrl.appendingPathExtension(Consts.CAFileExtension)
                        print("------>>> ca file path:",fileUrl.absoluteString)
                        try caData.write(to: fileUrl)
                       return fileUrl.absoluteString
                }catch let err{
                        print("------>>> ca file write err:", err.localizedDescription)
                        return nil
                }
        }
        
        
        func syncToDatabase() -> Error?{
                let ctx = PersistenceController.shared.container.viewContext
                guard !self.mailAcc.isEmpty else{
                        return NSError(domain: "setting", code: 110, userInfo: ["localizedDescription" : "email address is empty"])
                }
                
                let request: NSFetchRequest<CoreData_Setting> = CoreData_Setting.fetchRequest()
                request.fetchLimit = 1
                request.predicate =  NSPredicate(format: "mailAcc = %@",  self.mailAcc)
                
                var newSetting:CoreData_Setting?
                do {
                        let results = try ctx.fetch(request)
                        if results.isEmpty {
                                newSetting = CoreData_Setting(context: ctx)
                                newSetting!.mailAcc = self.mailAcc
                                try updateSetting(&newSetting!)
                        } else {
                                newSetting = results.first
                                try updateSetting(&newSetting!)
                        }
                        
                        try ctx.save()
                } catch let error as NSError {
                        print("Fetch error: \(error) description: \(error.userInfo)")
                        return error
                }
                
                return nil
        }
}


extension Setting{
        
        static func hasObj(addr:String) -> Bool{
                return findDBObj(addr: addr) != nil
        }
        
        static func findDBObj(addr:String)->CoreData_Setting?{
                let ctx = PersistenceController.shared.container.viewContext
                if addr == ""{
                        return nil
                }
                
                let request: NSFetchRequest<CoreData_Setting> = CoreData_Setting.fetchRequest()
                request.fetchLimit = 1
                request.predicate =  NSPredicate(format: "mailAcc = %@",  addr)
                do{
                        let results = try ctx.fetch(request)
                        return results.first
                }catch let err as NSError{
                        print("Fetch error: \(err) description: \(err.userInfo)")
                        return nil
                }
        }
}
