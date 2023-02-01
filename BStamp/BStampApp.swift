//
//  BStampApp.swift
//  BStamp
//
//  Created by wesley on 2023/1/30.
//

import SwiftUI

@main
struct BStampApp: App {
    let persistenceController = PersistenceController.shared
        @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
        
    var body: some Scene {
        WindowGroup {
                SignInOrUp()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
            _ = SdkDelegate.inst.loadSavedWallet()
    }
}
