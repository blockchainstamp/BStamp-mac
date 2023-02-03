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
                        SignIn().fixedSize().frame(minWidth: 360,minHeight: 600)
                                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                }.windowResizability(.contentSize)
        }
}

class AppDelegate: NSObject, NSApplicationDelegate {
        func applicationDidFinishLaunching(_ notification: Notification) {
                if let err = SdkDelegate.inst.InitLib(){
                        exit(Int32((err as NSError).code))
                }
        }
        func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
                return true
        }
}
