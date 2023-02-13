//
//  MainScene.swift
//  BStamp
//
//  Created by wesley on 2023/2/13.
//

import SwiftUI

struct MainScene: View {
        @State var logText:String = ""
        var body: some View {
                VStack{
                        HStack{
                                ControlView()//.frame(width: 320)
                                Spacer()
                                AccountListView()
                                Spacer()
                        }.padding().frame(maxHeight: 320)
                        TextArea(text: $logText) .border(Color.purple).padding().disabled(true)
                        Spacer()
                }.padding()
        }
}
struct ControlView: View {
        @EnvironmentObject var curWallet: Wallet
        @EnvironmentObject var systemConf: CoreData_SysConf
        @State var curSrvIsOn:Bool = false
        @Environment(\.managedObjectContext) private var viewContext
        init(){
        }
        
        var body: some View {
                VStack{
                        HStack{
                                Label("Wallet:", systemImage:"globe.americas")
                                Text(curWallet.Addr).textSelection(.enabled).font(.subheadline)
                                Spacer()
                        }
                        
                        HStack{
                                Label("Eth:", systemImage:"bitcoinsign.square")
                                Text(curWallet.EthAddr ?? "").textSelection(.enabled).font(.subheadline)
                                Spacer()
                        }
                        
                        HStack{
                                Label("SMTP Port", systemImage: "envelope.arrow.triangle.branch")
                                TextField("SMTP Port", text: Binding(
                                        get: { String(systemConf.smtpPort) },
                                        set: { systemConf.smtpPort = Int16($0) ?? 443}
                                )).frame(maxWidth: 60)
                                Spacer()
                        }
                        HStack{
                                Label("IMAP Port", systemImage: "envelope.badge")
                                TextField("IMAP Port", text: Binding(
                                        get: { String(systemConf.imapPort) },
                                        set: { systemConf.imapPort = Int16($0) ?? 996}
                                )).frame(maxWidth: 60)
                                Spacer()
                        }
                        HStack{
                                Toggle(isOn:$systemConf.sslOn) {
                                        Text("SSL ON")
                                }
                                Spacer()
                        }
                        Spacer()
                        Button(action: {
                                startOrStopService()
                        }) {
                                if curSrvIsOn{
                                        Text("Stop Service")
                                                .font(.subheadline)
                                                .foregroundColor(.red)
                                                .frame(width: 120,height: 40)
                                                .border(.red)
                                }else{
                                        Text("Start Service")
                                                .font(.subheadline)
                                                .foregroundColor(.green)
                                                .frame(width: 120,height: 40)
                                                .border(.green)
                                }
                        }.buttonStyle(.plain)
                }.onDisappear(){
                        try? viewContext.save()
                }.padding() .overlay(
                        RoundedRectangle(cornerRadius: 16)
                                .stroke(.green, lineWidth: 2)
                )
        }
        
        private func startOrStopService(){
                
        }
}


struct AccountListView: View {
        @Environment(\.managedObjectContext) private var viewContext
        
        @FetchRequest(
                sortDescriptors: [NSSortDescriptor(keyPath: \CoreData_Setting.mailAcc, ascending: true)],
                animation: .default)
        private var settings: FetchedResults<CoreData_Setting>
        
        @State var showNewItemView: Bool = false
        @State var showModifyItemView:[String:Bool] = [:]
        @State var showDelAlert = false
        var body: some View {
                VStack{
                        HStack{
                                Button {
                                        showNewItemView = true
                                } label: {
                                        Label("New Account", systemImage: "plus")
                                }
                                
                                Spacer()
                        }.sheet(isPresented: $showNewItemView) {
                                NewEmailAccountView(isPresented: $showNewItemView).fixedSize()
                        }
                        Divider()
                        List(){
                                ForEach(settings) { item in
                                        HStack{
                                                Text(item.mailAcc!)
                                                Text(item.stampName ?? "no stamp")
                                                Spacer()
                                                Button {
                                                        showModifyItemView[item.mailAcc!] = true
                                                } label: {
                                                        Image(systemName: "square.and.pencil")
                                                }.sheet(isPresented:$showModifyItemView[item.mailAcc!].toUnwrapped(defaultValue: false)) {
                                                        ModifyEmailAccountView(isPresented:$showModifyItemView[item.mailAcc!].toUnwrapped(defaultValue: false),
                                                                               selection:item)
                                                        .environment(\.managedObjectContext, viewContext)
                                                }
                                                Button {
                                                        showDelAlert = true
                                                } label: {
                                                        Image(systemName: "minus.circle.fill")
                                                }.alert(isPresented: $showDelAlert) {
                                                        Alert(
                                                                title: Text("Are You Sure?!"),
                                                                message: Text("email setting will be removed"),
                                                                primaryButton: .default(
                                                                        Text("No"),
                                                                        action: {
                                                                                showDelAlert = false
                                                                        }
                                                                ),
                                                                secondaryButton: .destructive(
                                                                        Text("Sure"),
                                                                        action: {
                                                                                deleteItem(item)
                                                                        }
                                                                )
                                                        )
                                                }
                                        }
                                }
                        }
                }.padding().overlay(
                        RoundedRectangle(cornerRadius: 16)
                                .stroke(.orange, lineWidth: 2)
                )
        }
        
        private func deleteItem(_ obj:CoreData_Setting){
                viewContext.delete(obj)
        }
}
struct MainScene_Previews: PreviewProvider {
        static var previews: some View {
                MainScene()
        }
}
