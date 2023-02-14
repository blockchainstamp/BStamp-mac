//
//  consts.swift
//  BStamp
//
//  Created by wesley on 2023/2/4.
//

import Foundation

class Consts{
        public static let ServiceCmdAddr = "127.0.0.1:2100"
        public static let CAFileExtension = "cer"
        public static let DefaultSmtpPort = Int32(443)
        public static let DefaultImapPort = Int32(996)
        
        public static let Noti_Wallet_Created =  Notification.Name.init("noti_wallet_created")
        public static let Noti_New_Setting_Created =  Notification.Name.init("noti_new_setting_created")
        public static let Noti_Setting_Updated =  Notification.Name.init("noti_setting_updated")
        public static let Noti_New_Stamp_Loaded =  Notification.Name.init("noti_new_stamp_loaded")
        public static let Noti_Service_Status_Changed =  Notification.Name.init("noti_service_status_changed")
}
