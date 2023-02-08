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
                                        SettingView()
                                } label: {
                                        Label("Settings", systemImage: "gear")
                                }
                                Section("System Info") {
                                        NavigationLink {
                                                Sidebar()
                                        } label: {
                                                Label("EMail Account", systemImage: "envelope")
                                        }
                                        NavigationLink {
                                                Sidebar()
                                        } label: {
                                                Label("Stamp Info", systemImage: "mail")
                                        }
                                        NavigationLink {
                                                Sidebar()
                                        } label: {
                                                Label("Wallet Info", systemImage: "wallet.pass")
                                        }
                                }
                        }
                } .navigationTitle("Navigation")
        }
}


struct MailLabel: View {
        var mail: MailAccout
        
        var body: some View {
                Label(mail.Name, systemImage: "envelope")
        }
}

struct StampLabel: View {
        var stamp: Stamp
        
        var body: some View {
                Label(stamp.MailBox, systemImage: "mail")
        }
}

struct SettingLabel: View {
        var setting: Setting
        
        var body: some View {
                Label(setting.mailAcc, systemImage: "heart")
        }
}

struct Sidebar: View {
        @Environment(\.managedObjectContext) var managedObjectContext
        
        @State var selection = ""
        @State var mails:[MailAccout] = []
        @State var stamps:[Stamp] = []
        @State var settings:[Setting] = []
        
        var body: some View {
                VStack{
                        Spacer()
                        Button(action: {
                                //                        signinSystem()
                        }) {
                                Text("New").fontWeight(.medium)
                                        .font(.system(size: 18))
                                        .frame(width: 220, height: 20)
                                        .foregroundColor(.green)
                                        .padding()
                                        .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                        .stroke(.green, lineWidth: 2)
                                        )
                        }.buttonStyle(.plain)
                        
                        List(selection: $selection) {
                                
                                Label("Wallet Info", systemImage: "wallet.pass")
                                DisclosureGroup() {
                                        ForEach(settings, id:\.self) { s in
                                                SettingLabel(setting: s)
                                        }
                                } label: {
                                        Label("Settings", systemImage: "gear")
                                }
                                
                                Section("System Info") {
                                        DisclosureGroup() {
                                                ForEach(mails, id:\.self) { mc in
                                                        MailLabel(mail: mc)
                                                }
                                        } label: {
                                                Label("Mail Account", systemImage: "mail")
                                        }
                                        DisclosureGroup() {
                                                ForEach(stamps, id:\.self) { s in
                                                        StampLabel(stamp: s)
                                                }
                                        } label: {
                                                Label("Stamps", systemImage: "signpost.right.and.left.circle")
                                        }
                                }
                        }.onChange(of: selection, perform: { newValue in
                                print("------>>>selection:", newValue)
                        })
                        .frame(minWidth: 250, maxWidth: 350)
                        .task {
                                
                        }
                        
                        Spacer()
                }
        }
        
        func loadStoredStamp(){
                
        }
}

struct MainScene_Previews: PreviewProvider {
        static var previews: some View {
                MainScene()
        }
}

struct Setting_Previews: PreviewProvider {
        static var previews: some View {
                SettingView()
        }
}
