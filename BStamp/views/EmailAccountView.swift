//
//  SettingView.swift
//  BStamp
//
//  Created by wesley on 2023/2/8.
//

import SwiftUI


struct EmailAccountView:View{
        @Environment(\.managedObjectContext) private var viewContext
        
        @FetchRequest(
                sortDescriptors: [NSSortDescriptor(keyPath: \CoreData_Setting.mailAcc, ascending: true)],
                animation: .default)
        private var settings: FetchedResults<CoreData_Setting>
        
        @State var selection:CoreData_Setting?
        @State var showNewItemView: Bool = false
        
        var body: some View {
                
                NavigationView {
                        List(selection: $selection) {
                                
                                Button(action: {
                                        showNewItemView = true
                                }) {
                                        Text("New").fontWeight(.medium)
                                                .font(.system(size: 18))
                                                .frame(width: 120, height: 20)
                                                .foregroundColor(.green)
                                                .padding()
                                                .overlay(
                                                        RoundedRectangle(cornerRadius: 24)
                                                                .stroke(.green, lineWidth: 2)
                                                )
                                }.buttonStyle(.plain)
                                Divider()
                                
                                ForEach(settings) { item in
                                        NavigationLink {
                                                ModifyEmailAccountView(selection:item)
                                                        .environment(\.managedObjectContext, viewContext)
                                        } label: {
                                                Text(item.mailAcc!)
                                        }
                                }
                        }
                }.sheet(isPresented: $showNewItemView) {
                        NewEmailAccountView(isPresented: $showNewItemView).fixedSize()
                }
        }
        private func deleteItems(offsets: IndexSet) {
                withAnimation {
                        offsets.map { settings[$0] }.forEach(viewContext.delete)
                        
                        do {
                                try viewContext.save()
                        } catch {
                                // Replace this implementation with code to handle the error appropriately.
                                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                                let nsError = error as NSError
                                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                        }
                }
        }
        func showNewSetingDialog(){
                
        }
}

struct SettingView_Previews: PreviewProvider {
        static var previews: some View {
                EmailAccountView()
        }
}
