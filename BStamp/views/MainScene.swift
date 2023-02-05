//
//  MainScene.swift
//  BStamp
//
//  Created by wesley on 2023/2/5.
//

import SwiftUI

struct MainScene: View {
        @Environment(\.managedObjectContext) var managedObjectContext
        @State var selection = 0
        var body: some View {
                NavigationView {
                        Sidebar().environment(\.managedObjectContext, managedObjectContext)
                }
        }
}

struct MailLabel: View {
        var mail: MailAccout
        
        var body: some View {
                Label(mail.Name, systemImage: "leaf")
        }
}

struct Sidebar: View {
        @Environment(\.managedObjectContext) var managedObjectContext
        
        @FetchRequest(
                sortDescriptors: [NSSortDescriptor(keyPath: \CoreData_Stamp.address, ascending: true)],
                animation: .default) var stamps: FetchedResults<CoreData_Stamp>
        
        @State var selection = ""
        @State var mails:[MailAccout] = []
        
//        init(){
//                let request: NSFetchRequest<CoreData_Stamp> = CoreData_Stamp.fetchRequest()
////                request.predicate = NSPredicate(format: "wallet = ss")
//
//                   request.sortDescriptors = [
//                       NSSortDescriptor(keyPath: \CoreData_Stamp.address, ascending: true)
//                   ]
//
//                _stamps = FetchRequest(fetchRequest: request)
//        }
        var body: some View {
                List(selection: $selection) {
                        DisclosureGroup() {
                                ForEach(mails, id:\.self) { mc in
                                        MailLabel(mail: mc)
                                }
                        } label: {
                                Label("Mail Account", systemImage: "chart.bar.doc.horizontal")
                        }
                        
                        Section("Settings") {
                        }
                }
                .frame(minWidth: 250)
                .task {
                        
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
