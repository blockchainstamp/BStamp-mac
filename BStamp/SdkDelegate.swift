//
//  SdkDelegate.swift
//  BStamp
//
//  Created by wesley on 2023/2/1.
//

import Foundation
import LibStamp
import SwiftyJSON
import SwiftUI

enum CmdType:Int8{
        case nop = 0
        case srvStatusChanged
        case logOut
}
typealias LogOutPut = (String)->Void
class SdkDelegate{
        public static let inst = SdkDelegate()
        public static var currErr:Error?
        
        let workQueue = DispatchQueue(label: "stamp sdk delegate",qos: .background)
        public  var Wallets:[Wallet]=[]
        public var lastWalletAddr:String = ""
        public var logger:LogOutPut?
        public var  libBaseDir:URL?
        private init(){}
        
        public func InitLib() -> Error?{
                let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                let basDir = paths[0].absoluteString
                print("------>>>base dir:", basDir)
                let success = LibStamp.InitLib(basDir.GoStr(), systemCallBack, errSet) == 1
                if success {
                        print("------>>> stamp lib init success.")
                        libBaseDir = paths[0]
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
        
        var errSet:SetLastErr = {v in
                guard let data = v else{
                        currErr = nil
                        return
                }
                let msg = String(cString: data)
                print("------>>>error from lib:", msg)
                currErr = NSError(domain: "", code: 110, userInfo: [ NSLocalizedDescriptionKey: msg])
        }
        
        
        static func callback(withJson:String)->String{
                
                let json = JSON(parseJSON: withJson)
                let cmd = json["cmd"].int8 ?? -1
                
                switch cmd{
                case CmdType.nop.rawValue:
                        return ""
                case CmdType.srvStatusChanged.rawValue:
                        NotificationCenter.default.post(name: Consts.Noti_Service_Status_Changed, object: nil)
                        return ""
                case CmdType.logOut.rawValue:
                        guard let msg = json["param"].string else{
                                return ""
                        }
                        print("------>>>log from lib:", msg)
                        guard let outter = inst.logger else{
                                return ""
                        }
                        outter(msg)
                        return ""
                default:
                        return ""
                }
        }
}

extension SdkDelegate{
        
        public func loadSavedWallet(){
                Wallets.removeAll()
                guard let data = LibStamp.AllWallets() else{
                        return
                }
                
                let jsonStr = String(cString: data)
                let json = JSON(parseJSON: jsonStr)
                
                for (_,subJson):(String, JSON) in json {
                        let addr = subJson["Addr"].string ?? ""
                        let name = subJson["Name"].string ?? ""
                        let str = subJson["JsonStr"].string
                        let w = Wallet(Addr:addr, Name: name, jsonStr: str)
                        Wallets.append(w)
                }
                print("------>>>wallet count:", self.Wallets.count)
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
        
        public func openWallet(addr:String, password:String)->Error?{
                let success = LibStamp.OpenWallet(addr.GoStr(), password.GoStr()) == 1
                
                if success {
                        print("------>>> stamp lib open wallet success")
                        return nil
                }
                
                if let e = SdkDelegate.currErr{
                        return e
                }
                
                return  NSError(domain: "", code: 110, userInfo: [ NSLocalizedDescriptionKey: "open wallet failed  with no error message"])
        }
        
        public func importWallet(wallet:String, password:String)->Error?{
                if let wData =  LibStamp.ImportWallet(wallet.GoStr(), password.GoStr()) {
                        print("------>>> stamp lib import wallet success:\n", String(cString: wData))
                        return nil
                }
                if let e = SdkDelegate.currErr{
                        return e
                }
                
                return  NSError(domain: "", code: 110, userInfo: [ NSLocalizedDescriptionKey: "import wallet failed  with no error message"])
        }
        
        public func removeWallet(addr:String)->Error?{
                guard LibStamp.RemoveWallet(addr.GoStr()) == 1 else{
                        guard let e = SdkDelegate.currErr else{
                                return NSError(domain: "", code: 110, userInfo: [ NSLocalizedDescriptionKey: "remove wallet failed "])
                        }
                        return e
                }
                return nil
        }
}


extension SdkDelegate{
        
        public func stampConfFromBlockChain(sAddr:String)->Stamp?{
                guard !sAddr.isEmpty else{
                        return nil
                }
                guard let data = LibStamp.StampConfig(sAddr.GoStr()) else{
                        return nil
                }
                
                let jsonStr = String(cString: data)
                
                let stamp = Stamp(json: JSON(parseJSON: jsonStr))                
                return stamp
        }
        
        public func stampBalanceOfWallet(wAddr:String?, sAddr:String)async -> (Int64, Int64){
                
                guard let wallet = wAddr , !sAddr.isEmpty else{
                        return (0, 0)
                }
                
                guard let data = LibStamp.GetBalance(wallet.GoStr(), sAddr.GoStr()) else{
                        return (0, 0)
                }
                let jsonStr = String(cString: data)
                let obj = JSON(parseJSON: jsonStr)
                let val = obj["Value"].int64 ?? 0
                let non = obj["Nonce"].int64 ?? 0
                return (val, non)
                
        }
        
        public func isValidEtherAddr(sAddr:String) ->Bool{
                return LibStamp.IsValidStampAddr(sAddr.GoStr()) == 1
        }
}
extension SdkDelegate{
        
        public func serviceStatus()->Bool{
                return LibStamp.ServiceStatus() == 1
        }
        
        public func initService(confJson:String, auth:String) -> Error?{
                guard LibStamp.InitService(confJson.GoStr(), auth.GoStr()) == 1 else{
                        guard let e = SdkDelegate.currErr else{
                                return NSError(domain: "", code: 110, userInfo: [ NSLocalizedDescriptionKey: "init service failed"])
                        }
                        return e
                }
                
                return nil
        }
        public func libWriteCaFile(name:String, data:String)throws->String{
                guard let data = LibStamp.WriteCaFile(name.GoStr(), data.GoStr()) else{
                        guard let e = SdkDelegate.currErr else{
                                throw NSError(domain: "", code: 110, userInfo: [ NSLocalizedDescriptionKey: "start service failed"])
                        }
                        throw e
                }
                return String(cString: data)
        }
        
        public func stopService(){
                LibStamp.StopService()
        }
        
        public func startService() ->Error? {
                
                guard LibStamp.StartService() == 1 else{
                        guard let e = SdkDelegate.currErr else{
                                return NSError(domain: "", code: 110, userInfo: [NSLocalizedDescriptionKey: "start service failed"])
                        }
                        return e
                }
                
                return nil
        }
}
