//
//  EmailAccountView.swift
//  BStamp
//
//  Created by wesley on 2023/2/10.
//

import SwiftUI

struct StampView: View {
        
        @Environment(\.managedObjectContext) private var viewContext
        
        @FetchRequest(
                sortDescriptors: [NSSortDescriptor(keyPath: \CoreData_Stamp.address, ascending: true)],
                animation: .default)
        private var settings: FetchedResults<CoreData_Stamp>
        
        @State var selection:CoreData_Stamp?
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
                                                StampDetailsView(selection:item)
                                                        .environment(\.managedObjectContext, viewContext)
                                        } label: {
                                                Text(item.mailbox!)
                                        }
                                }
                        }
                }.sheet(isPresented: $showNewItemView) {
                        NewStampView(isPresented: $showNewItemView).fixedSize()
                }
        }
}

struct EmailAccountView_Previews: PreviewProvider {
        static var previews: some View {
                StampView()
        }
}
