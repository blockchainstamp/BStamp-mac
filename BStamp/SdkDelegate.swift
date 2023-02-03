//
//  SdkDelegate.swift
//  BStamp
//
//  Created by wesley on 2023/2/1.
//

import Foundation
import LibStamp
import SwiftyJSON

enum CmdType:Int8{
        case nop = 0
}

typealias SDKCallback = (Void)->Void
class SdkDelegate{
        public static let inst = SdkDelegate()
        public static var currErr:Error?
       
        let workQueue = DispatchQueue(label: "stamp sdk delegate",qos: .background)
        
#if DEBUG
        public  var logLevel:String = "debug"
#else
        public  var logLevel:String = 0
#endif
        private init(){
        }
        
        public func InitLib() -> Error?{
                let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                let basDir = paths[0].absoluteString
                print("------>>>base dir:", basDir)
                let success = LibStamp.InitLib(basDir.GoStr(), logLevel.GoStr(), systemCallBack, uiLog) == 1
                if success {
                        print("------>>> stamp lib init success.")
                        return nil
                }
                
                if let e = SdkDelegate.currErr{
                        return e
                }
                
                return  NSError(domain: "", code: 110, userInfo: [ NSLocalizedDescriptionKey: "init lib failed with no error message"])
        }
        
         var systemCallBack:UserInterfaceAPI = {v in
                guard let data = v else{
                        return  "".CStr()
                }
                return callback(withJson: String(cString: data)).CStr()
        }
        
         var uiLog:SetLastErr = {v in
                guard let data = v else{
                        currErr = nil
                        return
                }
                let msg = String(cString: data)
                NSLog(msg)
                currErr = NSError(domain: "", code: 110, userInfo: [ NSLocalizedDescriptionKey: msg])
        }
        
      
        
        static func callback(withJson:String)->String{
                
                let json = JSON(parseJSON: withJson)
                let cmd = json["cmd"].int8 ?? -1
                
                switch cmd{
                case CmdType.nop.rawValue:
                        return ""
                default:
                        return ""
                }
        }
}
extension SdkDelegate{
        public func loadSavedWallet() ->[String]{
               
                return []
        }
        
        public func createWallet(name:String, password:String) async->Error?{
                let wData = await Task {
                        LibStamp.CreateWallet(password.GoStr(), name.GoStr())
                }.value
                
                if let d = wData {
                       let wStr = String(cString: d)
                        print("------>>>create wallet success:", wStr)
                        return nil
                }
                
                return SdkDelegate.currErr
        }
}
