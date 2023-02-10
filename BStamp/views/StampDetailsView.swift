//
//  StampDetails.swift
//  BStamp
//
//  Created by wesley on 2023/2/10.
//

import SwiftUI

struct StampDetailsView: View {
        @State var selection:CoreData_Stamp
        @State var stampAddr:String = ""
        @State var boxName:String = ""
        @State var isConsumable:Bool = false
        @State var balance:String = "0"
        @State var nonce:String = "0"
        
        var body: some View {
                VStack {
                        HStack {
                                Image(systemName: "shield.lefthalf.filled")
                                TextField("Stamp Address", text: $selection.address.toUnwrapped(defaultValue: ""))
                                        .padding()
                                        .cornerRadius(1.0).disabled(true)
                        }
                        HStack {
                                Image(systemName: "envelope.open")
                                TextField("Mail Box", text: $selection.mailbox.toUnwrapped(defaultValue: ""))
                                        .padding()
                                        .cornerRadius(1.0).disabled(true)
                        }
                        HStack() {
                                Image(systemName: "cart")
                                Toggle("Is Consumable", isOn: $selection.isConsummable)
                                        .toggleStyle(.checkbox).disabled(true)
                                Spacer()
                        }
                        HStack {
                                Image(systemName: "bitcoinsign.square")
                                TextField("Balance", text:$balance)
                                        .padding()
                                        .cornerRadius(1.0).disabled(true)
                                Button {
                                        reloadFromBlockChain()
                                } label: {
                                        Text("refresh")
                                                .cornerRadius(1.0)
                                                .font(.headline)
                                }
                        }
                        HStack {
                                Image(systemName: "list.number")
                                TextField("Nonce", text:$nonce)
                                        .padding()
                                        .cornerRadius(1.0).disabled(true)
                        }
                        Spacer()
                        
                }.padding().onAppear(){
                        balance = "\($selection.balance)"
                        nonce = "\($selection.nonce)"
                }
        }
        
        func reloadFromBlockChain(){
                
        }
}

struct StampDetails_Previews: PreviewProvider {
        
        static var obj = CoreData_Stamp(context: PersistenceController.shared.container.viewContext)
        
        static var previews: some View {
                StampDetailsView(selection: obj)
        }
}
