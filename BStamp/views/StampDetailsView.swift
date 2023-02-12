//
//  StampDetails.swift
//  BStamp
//
//  Created by wesley on 2023/2/10.
//

import SwiftUI

struct StampDetailsView: View {
        @EnvironmentObject private var currentWallet: Wallet
        @Environment(\.managedObjectContext) private var viewContext
        @ObservedObject var selection:CoreData_Stamp
        @State var isConsumable:Bool = false
        @State var balance:String = "0"
        @State var nonce:String = "0"
        
        @State var showTipsView:Bool = false
        @State var msg:String = ""
        
        var body: some View {
                
                ZStack{
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
                                        }.disabled(showTipsView)
                                }
                                HStack {
                                        Image(systemName: "list.number")
                                        TextField("Nonce", text:$nonce)
                                                .padding()
                                                .cornerRadius(1.0).disabled(true)
                                }
                                Spacer()
                                Button(action: {
                                        removeItem()
                                }, label: {
                                        Label("Delete", systemImage: "trash")
                                })
                                Spacer()
                                
                        }.padding().onAppear(){
                                balance = "\(selection.balance)"
                                nonce = "\(selection.nonce)"
                        }
                        CircularWaiting(isPresent: $showTipsView, tipsTxt:$msg)
                }
        }
        
        private func removeItem(){
                viewContext.delete(selection)
                try? viewContext.save()
        }
        
        func reloadFromBlockChain(){
                
                guard let walletAddr = currentWallet.EthAddr, let sAddr = selection.address else{
                        return
                }
                
                showTipsView = true
                Task{
                        msg = "load stamp balance"
                        await taskSleep(seconds: 1)
                        print("------>>>current wallet:", walletAddr)
                        let (val, non) = SdkDelegate.inst.stampBalanceOfWallet(wAddr: walletAddr,
                                                                               sAddr: sAddr)
                        if selection.balance != val{
                                selection.balance = val
                                balance = "\(val)"
                        }
                        if selection.nonce != non{
                                selection.nonce = non
                                nonce = "\(non)"
                        }
                        showTipsView = false
                }
        }
}

struct StampDetails_Previews: PreviewProvider {
        
        static var obj = CoreData_Stamp(context: PersistenceController.shared.container.viewContext)
        
        static var previews: some View {
                StampDetailsView(selection: obj)
        }
}
