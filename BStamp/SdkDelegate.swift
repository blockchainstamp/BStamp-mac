//
//  SdkDelegate.swift
//  BStamp
//
//  Created by wesley on 2023/2/1.
//

import Foundation
import LibStamp

class SdkDelegate{
        public static let inst = SdkDelegate()
        
        public func loadSavedWallet() ->[String]{
               
                return []
        }
        private init(){
                let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                   let documentsDirectory = paths[0]
                print("----------docment:",documentsDirectory.absoluteString)
                LibStamp.InitLib()
        }
}
