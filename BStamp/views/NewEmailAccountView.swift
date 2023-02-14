//
//  NewSettingView.swift
//  BStamp
//
//  Created by wesley on 2023/2/7.
//

import SwiftUI


struct NewEmailAccountView:View{
        
        @EnvironmentObject private var currentWallet: Wallet
        @Binding var isPresented: Bool
        @State var showAlert:Bool = false
        @State var title:String = ""
        @State var msg:String = ""
        @State var eMailAddr:String = ""
        @State var smtpSrv:String = ""
        @State var smtpPort:Int32 = 443
        @State var imapPort:Int32 = 996
        @State var imapSrv:String = ""
        @State var caFileName:String = ""
        @State var stampAddr:String = ""
        
        @State var emailAddrState:TripState = .start
        @State var smtpSrvState:TripState = .start
        @State var imapSrvState:TripState = .start
        @State var caFileState:TripState = .start
        @State var stampState:TripState = .start
        
        @State var showTipsView:Bool = false
        @State var smtpSSLOn:Bool = true
        @State var imapSSLOn:Bool = true
        
        @State var alertAction: Alert.Button = .default(Text("Got it!"))
        @State var caFileUrl:URL? = nil
        
        @State var stampObj:Stamp?
        
        @FocusState var focusedField: String?
        
        var body: some View {
                ZStack{
                        List {
                                Label {
                                        Text("Create New Mail Account")
                                } icon: {
                                        Image(systemName: "mail.stack")
                                }.font(.headline)
                                        .fontWeight(.bold)
                                Spacer()
                                HStack {
                                        Image(systemName: "signpost.left.circle")
                                        TextField("Email Address", text: $eMailAddr)
                                                .padding()
                                                .cornerRadius(1.0)
                                                .focused($focusedField, equals: "email")
                                                .onSubmit {
                                                        focusedField="smtp"
                                                }.border(.green)
                                        
                                        CheckingView(state: $emailAddrState)
                                }.labelStyle(.iconOnly)
                                
                                
                                HStack {
                                        Image(systemName: "tray.and.arrow.up")
                                        TextField("SMTP Server", text: $smtpSrv)
                                                .padding()
                                                .cornerRadius(1.0)
                                                .focused($focusedField, equals: "smtp")
                                                .onSubmit {
                                                        focusedField="imap"
                                                }.border(.green)
                                        
                                        
                                        TextField("SMTP Port", text: Binding(get: {
                                                return "\(smtpPort)"
                                        }, set: { newVal in
                                                smtpPort = toValidPort(portStr: newVal,
                                                                       defaultVal: Consts.DefaultSmtpPort)
                                        }))
                                        .padding()
                                        .cornerRadius(1.0)
                                        .border(.green).frame(maxWidth: 80)
                                        
                                        CheckingView(state: $smtpSrvState)
                                }.labelStyle(.iconOnly)
                                
                                HStack {
                                        Image(systemName: "tray.and.arrow.down")
                                        TextField("IMAP Server", text: $imapSrv)
                                                .padding()
                                                .cornerRadius(1.0)
                                                .focused($focusedField, equals: "imap")
                                                .onSubmit {
                                                        focusedField="email"
                                                }.border(.green)
                                        
                                        TextField("IMAP Port", text: Binding(get: {
                                                return "\(imapPort)"
                                        }, set: { newVal in
                                                imapPort = toValidPort(portStr: newVal,
                                                                       defaultVal: Consts.DefaultImapPort)
                                        }))
                                        .padding()
                                        .cornerRadius(1.0)
                                        .border(.green).frame(maxWidth: 80)
                                        
                                        CheckingView(state: $imapSrvState)
                                        
                                }.labelStyle(.iconOnly)
                                
                                HStack {
                                        Image(systemName: "shield.lefthalf.filled")
                                        TextField("CA File", text: $caFileName)
                                                .padding()
                                                .cornerRadius(1.0)
                                                .disabled(true)
                                        
                                        Button(action: {
                                                
                                                let panel = NSOpenPanel()
                                                panel.allowsMultipleSelection = false
                                                panel.canChooseDirectories = false
                                                if panel.runModal() == .OK {
                                                        caFileName = panel.url?.lastPathComponent ?? ""
                                                        caFileUrl = panel.url
                                                }
                                        }, label: {
                                                Label("File", systemImage: "folder")
                                        })
                                        CheckingView(state: $caFileState).labelStyle(.iconOnly)
                                }
                                HStack {
                                        Spacer()
                                        Toggle("SMTP Secure Connection", isOn: $smtpSSLOn)
                                                .toggleStyle(.checkbox)
                                        
                                        Spacer()
                                        Toggle("IMAP Secure Connection", isOn: $imapSSLOn)
                                                .toggleStyle(.checkbox)
                                        
                                        Spacer()
                                }
                                
                                Divider()
                                
                                VStack{
                                        HStack {
                                                Image(systemName: "bitcoinsign.square")
                                                TextField("Stamp Address", text: $stampAddr, onEditingChanged: { editingChanged in
                                                        if editingChanged{
                                                                return
                                                        }
                                                        loadStampData()
                                                }).border(.green)
                                                        .padding()
                                                        .cornerRadius(1.0).disabled(showTipsView)
                                                        .onSubmit {
                                                                loadStampData()
                                                        }
                                                
                                                CheckingView(state:$stampState)
                                        }.labelStyle(.iconOnly)
                                        
                                        HStack{
                                                Label {
                                                        Text("MailBox: \(stampObj?.MailBox ?? "")")
                                                } icon: {
                                                        Image(systemName: "envelope.open")
                                                }
                                                
                                                
                                                Spacer()
                                                Image(systemName: "cart")
                                                Toggle("Is Consumable", isOn: Binding(get: {
                                                        return stampObj?.IsConsumable ?? false
                                                }, set: { _ in }))
                                                .toggleStyle(.checkbox).disabled(true)
                                                Spacer()
                                        }
                                        
                                        HStack{
                                                Label {
                                                        Text("Balance: \(stampObj?.balance ?? 0)")
                                                } icon: {
                                                        Image(systemName: "bitcoinsign.square")
                                                }
                                                
                                                Spacer()
                                                
                                                Label {
                                                        Text("Nonce: \(stampObj?.nonce ?? 0)")
                                                } icon: {
                                                        Image(systemName: "list.number")
                                                }
                                                
                                                Spacer()
                                        }
                                        
                                }.padding().border(.purple)
                                
                                HStack{
                                        Spacer()
                                        Button(action: {
                                                createSetting()
                                        }, label: {
                                                Label("Create", systemImage: "doc.badge.plus")
                                        })
                                        Spacer()
                                        Button(action: {
                                                isPresented = false
                                        }, label: {
                                                Label("Cancel", systemImage: "xmark.circle")
                                        })
                                        Spacer()
                                }.padding()
                                
                        }.padding().focusSection()
                                .disabled(showTipsView)
                                .alert(isPresented: $showAlert) {
                                        Alert(
                                                title: Text("Tips"),
                                                message: Text(msg),
                                                dismissButton: alertAction
                                        )
                                }
                        CircularWaiting(isPresent: $showTipsView, tipsTxt:$msg)
                }.frame(minWidth: 560,minHeight: 580).onAppear(){
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                focusedField = "email"
                        }
                }
        }
        
        func loadStampData(){
                guard !stampAddr.isEmpty else{
                        stampObj = nil
                        return
                }
                
                if stampObj != nil && stampObj?.Addr == stampAddr{
                        return
                }
                
                showTipsView = true
                Task {
                        msg = "checking stamp address"
                        await taskSleep(seconds: 1)
                        
                        guard SdkDelegate.inst.isValidEtherAddr(sAddr: stampAddr) else{
                                showTipsView = false
                                return
                        }
                        
                        guard let s = SdkDelegate.inst.stampConfFromBlockChain(sAddr: stampAddr) else{
                                showTipsView = false
                                return
                        }
                        msg = "balance of stamp"
                        await taskSleep(seconds: 1)
                        
                        stampObj = s
                        let (val, non) = await SdkDelegate.inst.stampBalanceOfWallet(wAddr: currentWallet.EthAddr, sAddr: stampAddr)
                        stampObj?.balance = val
                        stampObj?.nonce = non
                        showTipsView = false
                }
        }
        
        func resetState(){
                emailAddrState = .start
                smtpSrvState = .start
                imapSrvState = .start
                caFileState = .start
                stampState = .start
        }
        
        func createSetting(){
                resetState()
                showTipsView = true
                
                Task {
                        let setting = Setting()
                        
                        var success = true
                        msg = "checking email address"
                        if !eMailAddr.isValidEmail{
                                emailAddrState = .failed
                                success = false
                        }else{
                                setting.mailAcc = eMailAddr
                                emailAddrState = .success
                        }
                        if Setting.hasObj(addr: eMailAddr){
                                showTipsView = false
                                showAlert = true
                                msg = "Dupplicated Email Account"
                                return
                        }
                        await taskSleep(seconds: 1)
                        
                        msg = "checking smtp address"
                        if (smtpSrv.isValidHostname || smtpSrv.isValidIpAddress) {
                                setting.smtpSrv = smtpSrv
                                setting.smtpPort = smtpPort
                                smtpSrvState = .success
                        }else{
                                smtpSrvState = .failed
                                success = false
                        }
                        await taskSleep(seconds: 1)
                        
                        
                        msg = "checking imap address"
                        if imapSrv.isValidHostname || imapSrv.isValidIpAddress {
                                setting.imapSrv = imapSrv
                                setting.imapPort = imapPort
                                imapSrvState = .success
                        }else{
                                imapSrvState = .failed
                                success = false
                        }
                        await taskSleep(seconds: 1)
                        
                        
                        if !stampAddr.isEmpty{
                                if stampObj == nil || stampObj?.Addr != stampAddr{
                                        msg = "checking stamp address"
                                        stampObj = SdkDelegate.inst.stampConfFromBlockChain(sAddr: stampAddr)
                                }
                                
                                if let s = stampObj{
                                        msg = "stamp name is \(s.MailBox) "
                                        stampState = .success
                                        setting.stampAddr = stampAddr
                                        setting.stampName = s.MailBox
                                }else{
                                        stampState = .failed
                                        success = false
                                }
                        }
                        
                        await taskSleep(seconds: 1)
                        
                        if smtpSSLOn || imapSSLOn{
                                msg = "reading CA file"
                                if let url  = caFileUrl, let data =  try? Data(contentsOf: url){
                                        caFileState = .success
                                        setting.caData = data
                                }else{
                                        caFileState = .failed
                                        success = false
                                }
                        }
                        if success == false{
                                showTipsView = false
                                return
                        }
                        
                        setting.smtpSSLOn = smtpSSLOn
                        setting.imapSSLOn = imapSSLOn
                        
                        //                        (email: eMailAddr, smtp: smtpSrv, imap: imapSrv,
                        //                                              stampAddr: stampAddr, stampName: stampName, smtpSSL: smtpSSLOn,
                        //                                              imapSSL: imapSSLOn,  caName: caFileName, caData: caData)
                        //
                        if let e = setting.syncToDatabase(){
                                showTipsView = false
                                showAlert = true
                                msg = e.localizedDescription
                                return
                        }
                        
                        showAlert = true
                        msg = "Success!"
                        showTipsView = false
                        alertAction = .default(Text("Sure")){
                                isPresented = false
                                NotificationCenter.default.post(name: Consts.Noti_New_Setting_Created, object: nil)
                        }
                }
        }
}


struct NewSetting_Previews: PreviewProvider {
        static private var isPresent = Binding<Bool> (
                get: { true}, set: { _ in }
        )
        static var previews: some View {
                NewEmailAccountView(isPresented: isPresent)
        }
}
