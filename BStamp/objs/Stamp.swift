//
//  Stamp.swift
//  BStamp
//
//  Created by wesley on 2023/2/5.
//

import Foundation
class Stamp:Hashable{
        
        static func == (lhs: Stamp, rhs: Stamp) -> Bool {
                return lhs.Addr == rhs.Addr && lhs.Name == rhs.Name && lhs.jsonStr == rhs.jsonStr
        }
        
        var Addr:String
        var Name:String
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
        }
}
