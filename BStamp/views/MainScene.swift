//
//  MainScene.swift
//  BStamp
//
//  Created by wesley on 2023/2/5.
//

import SwiftUI

struct MainScene: View {
        @Environment(\.managedObjectContext) var managedObjectContext
        @State private var selection: String? = nil
        
        var body: some View {
                NavigationView {
                        List {
                                NavigationLink {
                                        EmailAccountView()
                                } label: {
                                        Label("Settings", systemImage: "gear")
                                }
                                Section("System Info") {
                                        NavigationLink {
                                                EmailAccountView()
                                        } label: {
                                                Label("EMail Account", systemImage: "envelope")
                                        }
                                        NavigationLink {
                                                StampView()
                                        } label: {
                                                Label("Stamp Info", systemImage: "mail")
                                        }
                                        NavigationLink {
                                                WalletView()
                                        } label: {
                                                Label("Wallet Info", systemImage: "wallet.pass")
                                        }
                                }
                        }
                } .navigationTitle("Navigation")
        }
}

struct MainScene_Previews: PreviewProvider {
        static var previews: some View {
                MainScene()
        }
}

