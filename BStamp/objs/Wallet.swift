//
//  Wallet.swift
//  BStamp
//
//  Created by wesley on 2023/2/3.
//

import Foundation
import SwiftyJSON

class Wallet:Hashable,ObservableObject{
        
        static func == (lhs: Wallet, rhs: Wallet) -> Bool {
                return lhs.Addr == rhs.Addr && lhs.Name == rhs.Name && lhs.jsonStr == rhs.jsonStr
        }
        
        @Published var Addr:String
        var Name:String
        var EthAddr:String?
        var jsonStr:String?
        init(){
                Addr = ""
                Name = ""
        }
       
        func hash(into hasher: inout Hasher) {
                hasher.combine(Addr)
                hasher.combine(Name)
        }
        init(Addr: String, Name: String, jsonStr: String? = nil) {
                self.Addr = Addr
                self.Name = Name
                self.jsonStr = jsonStr
                if jsonStr != nil{
                        let jObj = JSON(parseJSON: jsonStr!)
                        self.EthAddr = jObj["eth_addr"].string
                }
        }
}
