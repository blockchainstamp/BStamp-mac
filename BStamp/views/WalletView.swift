//
//  WalletView.swift
//  BStamp
//
//  Created by wesley on 2023/2/10.
//

import SwiftUI

struct WalletView: View {
        @EnvironmentObject var curWallet: Wallet
        @State var wallets:[Wallet] = []
        @State var showDelAlert:Bool = false
        @State var showingAlert:Bool = false
        @State var alertMsg = ""
        @State var addrToRemove = ""
        var body: some View {
                VStack{
                        List{
                                HStack{
                                        Label {
                                                Text("Stamp Address:\t\t")
                                        } icon: {
                                                Image(systemName: "globe.americas")
                                        }
                                        Text(curWallet.Addr) .textSelection(.enabled)
                                }
                                HStack{
                                        Label {
                                                Text("Stamp Name:\t\t\t")
                                        } icon: {
                                                Image(systemName: "person")
                                        }
                                        Text(curWallet.Name) .textSelection(.enabled)
                                }
                                HStack{
                                        Label {
                                                Text("Ethereum Address:\t")
                                        } icon: {
                                                Image(systemName: "bitcoinsign.square")
                                        }
                                        
                                        Text(curWallet.EthAddr ?? "") .textSelection(.enabled)
                                }
                                Spacer()
                                HStack{
                                        Spacer()
                                        Button(action: {
                                                exportWallet()
                                        }, label: {
                                                Label("Export", systemImage: "arrowshape.bounce.right")
                                        })
                                        Spacer()
                                }
                        }.padding()
                        Divider()
                        Spacer()
                        List(){
                                ForEach(wallets, id:\.self) { wallet in
                                       
                                        HStack{
                                                Text(wallet.Name)
                                                Text(wallet.Addr)
                                                if curWallet.Addr != wallet.Addr{
                                                        Button(action: {
                                                                showDelAlert = true
                                                                addrToRemove = wallet.Addr
                                                        }, label: {
                                                                Label("Delete", systemImage: "trash")
                                                        }).alert(isPresented: $showDelAlert) {
                                                                Alert(
                                                                        title: Text("Are You Sure?!"),
                                                                        message: Text("There's no server to recover wallet except you have backup"),
                                                                        primaryButton: .default(
                                                                                Text("No"),
                                                                                action: {
                                                                                        showDelAlert = false
                                                                                }
                                                                        ),
                                                                        secondaryButton: .destructive(
                                                                                Text("Sure"),
                                                                                action: {
                                                                                        removeWallet()
                                                                                }
                                                                        )
                                                                )
                                                        }
                                                }
                                        }
                                }
                        }.task {
                                refreshWallets()
                        }.padding()
                                .alert(alertMsg, isPresented: $showingAlert) {
                                Button("OK", role: .cancel) {
                                        refreshWallets()
                                }
                            }
                        Spacer()
                }.padding()
        }
        private func refreshWallets(){
                SdkDelegate.inst.loadSavedWallet()
                wallets = SdkDelegate.inst.Wallets
                if wallets.count == 0{
                        return
                }
                print("------->>>", wallets.count)
        }
        
        private func removeWallet(){
                print("------>>>", addrToRemove)
                guard !addrToRemove.isEmpty else{
                        return
                }
                
                if let err = SdkDelegate.inst.removeWallet(addr: addrToRemove){
                        showingAlert = true
                        alertMsg = err.localizedDescription
                }
                alertMsg = "Success"
                showingAlert = true
        }
        
        private func exportWallet(){
                
        }
}

struct WalletView_Previews: PreviewProvider {
        static var previews: some View {
                WalletView()
        }
}
