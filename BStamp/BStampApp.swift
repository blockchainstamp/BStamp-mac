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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
