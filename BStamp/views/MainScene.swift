//
//  MainScene.swift
//  BStamp
//
//  Created by wesley on 2023/2/13.
//

import SwiftUI
import SwiftyJSON

struct MainScene: View {
        @State var logText:String = ""
        @State var showTipsView:Bool = false
        @State var msg:String = ""
        @State var curSrvIsOn:Bool = false
        var body: some View {
                ZStack{
                        VStack{
                                HStack{
                                        ControlView(showTipsView: $showTipsView,
                                                    msg: $msg,curSrvIsOn:$curSrvIsOn)//.frame(width: 320)
                                        Spacer()
                                        AccountListView(curSrvIsOn: $curSrvIsOn)
                                        Spacer()
                                }.padding().frame(maxHeight: 320)
                                TextArea(text: $logText)
                                        .border(Color.purple)
                                        .padding().textSelection(.enabled)
//                                        .disabled(true)
                                Spacer()
                        }.padding()
                        CircularWaiting(isPresent: $showTipsView, tipsTxt:$msg)
                }.onAppear(){
                        SdkDelegate.inst.logger = self.logOutPut
                }.onDisappear(){
                        SdkDelegate.inst.logger = nil
                }
        }
        
        func logOutPut(_ msg:String){
                logText = logText + msg
                if logText.lengthOfBytes(using: .utf8) >= Consts.MaxLogSize{
                        logText.removeFirst(Consts.MaxLogSize >> 1 )
                }
        }
}

struct ControlView: View {
        @Environment(\.managedObjectContext) private var viewContext
        @FetchRequest(
                sortDescriptors: [NSSortDescriptor(keyPath: \CoreData_Setting.mailAcc, ascending: true)],
                animation: .default)
        private var settings: FetchedResults<CoreData_Setting>
        @EnvironmentObject var curWallet: Wallet
        @EnvironmentObject var systemConf: CoreData_SysConf
        
        @Binding var showTipsView:Bool
        @Binding var msg:String
        @Binding var curSrvIsOn:Bool
        @State var logLevels:[String] = ["trace","debug","info","warn","error","fatal","panic"]
        @State var logLev:String = "info"
        @State var showAlert:Bool = false
        
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
                        Group{
                                HStack{
                                        Label("Log Level:", systemImage:"note.text")
                                        Picker("", selection: $logLev) {
                                                ForEach(logLevels, id: \.self){ leve in
                                                        Text(leve)
                                                }
                                        }.frame(maxWidth: 80)
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
                        }.disabled(curSrvIsOn)
                        
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
                ).onAppear(){
                        NotificationCenter.default.addObserver(forName: Consts.Noti_Service_Status_Changed,
                                                               object: nil,
                                                               queue: nil,
                                                               using: self.statusChanged)
                }.alert(isPresented: $showAlert) {
                        Alert(
                                title: Text("Tips"),
                                message: Text(msg),
                                dismissButton: .default(Text("OK"))
                        )
                }
        }
        private func startOrStopService(){
                if curSrvIsOn{
                        stop()
                }else{
                        start()
                }
        }
        
        private func stop(){
                showTipsView = true
                Task{
                        msg = "stoping..."
                        SdkDelegate.inst.stopService()
                        await taskSleep(seconds: 1)
                        showTipsView = false
                }
        }
        
        private func start(){
                curSrvIsOn = true
                showTipsView = true
                Task{
                        
                        msg = "preparing config..."
                        guard let str = prepareConf() else{
                                showTipsView = false
                                curSrvIsOn = false
                                showAlert = true
                                msg = "config prepare failed"
                                return
                        }
                        await taskSleep(seconds: 1)
                        msg = "init service config..."
                        if  let e =  SdkDelegate.inst.initService(confJson:str,auth:curWallet.getPasswrod()){
                                showTipsView = false
                                curSrvIsOn = false
                                showAlert = true
                                msg = e.localizedDescription
                                return
                        }
                        
                        await taskSleep(seconds: 1)
                        
                        msg = "starting service config..."
                        if let e = SdkDelegate.inst.startService() {
                                showTipsView = false
                                curSrvIsOn = false
                                showAlert = true
                                msg = e.localizedDescription
                                return
                        }
                        
                        await taskSleep(seconds: 1)
                        showTipsView = false
                }
        }
        
        private func prepareConf()->String?{
                
                var smtpRemote:JSON = [:]
                var imapRemote:JSON = [:]
                for obj in settings {
                        imapRemote[obj.mailAcc!] = [
                                "ca_files":obj.caFilePath ?? "",
                                "ca_domain":obj.imapSrv ?? "",
                                "allow_not_secure":!obj.imapSSLOn,
                                "remote_srv_name":obj.imapSrv ?? "",
                                "remote_srv_port":obj.imapPort,
                        ]
                        smtpRemote[obj.mailAcc!] = [
                                "ca_files":obj.caFilePath ?? "",
                                "ca_domain":obj.smtpSrv ?? "",
                                "allow_not_secure":!obj.smtpSSLOn,
                                "remote_srv_name":obj.smtpSrv ?? "",
                                "remote_srv_port":obj.smtpPort,
                                "active_stamp_addr":obj.stampAddr ?? ""
                        ]
                }
                
                let smtp:JSON = [
                        "srv_addr":":\(systemConf.smtpPort)",
                        "SrvDomain":"localhost",
                        "stamp_wallet_addr":curWallet.Addr,
                        "remote_conf":smtpRemote,
                        "max_message_bytes":Consts.max_message_bytes,
                        "read_time_out":Consts.read_time_out,
                        "write_time_out":Consts.write_time_out,
                        "max_recipients":Consts.max_recipients
                ]
                
                let imap:JSON = [
                        "srv_addr":":\(systemConf.imapPort)",
                        "srv_domain":"localhost",
                        "remote_conf":imapRemote,
                ]
                let conf:JSON = [
                        "log_level":logLev,
                        "allow_insecure_auth":!systemConf.sslOn,
                        "cmd_srv_addr":Consts.ServiceCmdAddr,
                        "imap_conf":imap,
                        "smtp_conf":smtp,
                ]
                
                guard let str = conf.rawString(options: [.withoutEscapingSlashes, .fragmentsAllowed]) else{
                        showTipsView = false
                        curSrvIsOn = false
                        return nil
                }
                
                return str
        }
        
        func statusChanged(_ notification: Notification) {
                curSrvIsOn = SdkDelegate.inst.serviceStatus()
        }
}


struct AccountListView: View {
        @Environment(\.managedObjectContext) private var viewContext
        @FetchRequest(
                sortDescriptors: [NSSortDescriptor(keyPath: \CoreData_Setting.mailAcc, ascending: true)],
                animation: .default)
        private var settings: FetchedResults<CoreData_Setting>
        
        @Binding var curSrvIsOn:Bool
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
                                                                                let tempAddr = item.mailAcc!
                                                                                deleteItem(tempAddr)
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
                ).disabled(curSrvIsOn)
        }
        
        private func deleteItem(_ email:String){
                for obj in settings{
                        if obj.mailAcc == email{
                                viewContext.delete(obj)
                        }
                }
        }
}
struct MainScene_Previews: PreviewProvider {
        static var previews: some View {
                MainScene()
        }
}
