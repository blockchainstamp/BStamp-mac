//
//  NewStampView.swift
//  BStamp
//
//  Created by wesley on 2023/2/10.
//

import SwiftUI

struct NewStampView: View {
        @EnvironmentObject private var currentWallet: Wallet
        @Binding var isPresented: Bool
        @State var stampAddr:String = ""
        @State var boxName:String = ""
        @State var isConsumable:Bool = false
        @State var balance:String = "0"
        @State var nonce:String = "0"
        @State var showTipsView:Bool = false
        @State var showAlert:Bool = false
        
        @State var title:String = ""
        @State var msg:String = ""
        @State var stampAddrState:TripState = .start
        @State var alertAction: Alert.Button = .default(Text("Got it!"))
        
        var body: some View {
                ZStack{
                        VStack {
                                HStack {
                                        Image(systemName: "shield.lefthalf.filled")
                                        TextField("Stamp Address", text: $stampAddr)
                                                .padding()
                                                .cornerRadius(1.0)
                                                .onSubmit {
                                                        validStamp()
                                                }
                                        CheckingView(state: $stampAddrState)
                                        
                                }.labelStyle(.iconOnly)
                                
                                HStack {
                                        Image(systemName: "envelope.open")
                                        TextField("Mail Box", text: $boxName)
                                                .padding()
                                                .cornerRadius(1.0).disabled(true)
                                }
                                HStack() {
                                        Image(systemName: "cart")
                                        Toggle("Is Consumable", isOn: $isConsumable)
                                                .toggleStyle(.checkbox).disabled(true)
                                        Spacer()
                                }
                                HStack {
                                        Image(systemName: "bitcoinsign.square")
                                        TextField("Balance", text: $balance)
                                                .padding()
                                                .cornerRadius(1.0).disabled(true)
                                }
                                
                                HStack {
                                        Image(systemName: "list.number")
                                        TextField("Nonce", text: $nonce)
                                                .padding()
                                                .cornerRadius(1.0).disabled(true)
                                }
                                Spacer()
                                HStack{
                                        Spacer()
                                        Button(action: {
                                                saveStamp()
                                        }, label: {
                                                Label("Save", systemImage: "doc.badge.plus")
                                        })
                                        Spacer()
                                        Button(action: {
                                                isPresented = false
                                        }, label: {
                                                Label("Cancel", systemImage: "xmark.circle")
                                        })
                                        Spacer()
                                }.padding()
                                        .disabled(showTipsView)
                                        .alert(isPresented: $showAlert) {
                                                Alert(
                                                        title: Text("Tips"),
                                                        message: Text(msg),
                                                        dismissButton: alertAction
                                                )
                                        }
                                
                        }.padding()
                        CircularWaiting(isPresent: $showTipsView, tipsTxt:$msg)
                }.frame(minWidth: 320,minHeight: 480)
        }
        
        private func loadBasicInfo() async -> Stamp?{
                
                
                if Stamp.hasObj(addr: stampAddr){
                        msg = "Duplicated!"
                        showAlert = true
                        return nil
                }
                
                showTipsView = true
                msg = "load stamp config"
                guard let s = SdkDelegate.inst.stampConfFromBlockChain(sAddr: stampAddr) else{
                        showTipsView = false
                        msg = "laod stamp from blcok chain failed"
                        showAlert = true
                        return nil
                }
                
                
                boxName = s.MailBox
                isConsumable = s.IsConsumable
                await taskSleep(seconds: 1)
                
                
                msg = "load stamp balance"
                print("------>>>current wallet:",currentWallet.Addr)
                let (val, non) = SdkDelegate.inst.stampBalanceOfWallet(wAddr: currentWallet.Addr,
                                                                       sAddr: stampAddr)
                s.balance = val
                s.nonce = non
                await taskSleep(seconds: 1)
                showTipsView = false
                return s
        }
        private func validStamp(){
                Task{
                        await loadBasicInfo()
                }
        }
        
        private func saveStamp(){
                Task{
                        guard let s = await loadBasicInfo() else{
                                return
                        }
                        if let err = s.syncToDatabase(){
                                showTipsView = false
                                msg = err.localizedDescription
                                showAlert = true
                                return
                        }
                        showTipsView = false
                        msg = "success"
                        showAlert = true
                        alertAction = .default(Text("Sure")){
                                isPresented = false
                                NotificationCenter.default.post(name: Consts.Noti_New_Stamp_Loaded, object: nil)
                        }
                }
        }
}

struct NewStampView_Previews: PreviewProvider {
        
        static private var isPresent = Binding<Bool> (
                get: { true}, set: { _ in }
        )
        static var previews: some View {
                NewStampView(isPresented: isPresent)
        }
}
