//
//  NewSettingView.swift
//  BStamp
//
//  Created by wesley on 2023/2/7.
//

import SwiftUI


struct NewSettingView:View{
        @Binding var isPresented: Bool
        @State var showAlert:Bool = false
        @State var title:String = ""
        @State var msg:String = ""
        @State var eMailAddr:String = ""
        @State var smtpSrv:String = ""
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
                                        Image(systemName: "house.lodge")
                                        TextField("Email Address", text: $eMailAddr)
                                                .padding()
                                                .cornerRadius(1.0)
                                                .focused($focusedField, equals: "email")
                                                .onSubmit {
                                                        focusedField="smtp"
                                                }
                                        
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
                                                }
                                        
                                        CheckingView(state: $smtpSrvState)
                                }.labelStyle(.iconOnly)
                                
                                HStack {
                                        Image(systemName: "tray.and.arrow.down")
                                        TextField("IMAP Server", text: $imapSrv)
                                                .padding()
                                                .cornerRadius(1.0)
                                                .focused($focusedField, equals: "imap")
                                                .onSubmit {
                                                        focusedField="stamp"
                                                }
                                        CheckingView(state: $imapSrvState)
                                        
                                }.labelStyle(.iconOnly)
                                
                                HStack {
                                        Image(systemName: "bitcoinsign.square")
                                        TextField("Stamp Address", text: $stampAddr)
                                                .padding()
                                                .cornerRadius(1.0)
                                                .focused($focusedField, equals: "stamp")
                                                .onSubmit {
                                                        focusedField="email"
                                                }
                                        
                                        CheckingView(state:$stampState)
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
                                Spacer()
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
                }.frame(minWidth: 480,minHeight: 600).onAppear(){
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                focusedField = "email"
                            }
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
                        var success = true
                        msg = "checking email address"
                        if eMailAddr.isValidEmail{
                                emailAddrState = .success
                        }else{
                                emailAddrState = .failed
                                success = false
                        }
                        sleep(1)
                        
                        
                        msg = "checking smtp address"
                        if smtpSrv.isValidHostname || smtpSrv.isValidIpAddress{
                                smtpSrvState = .success
                        }else{
                                smtpSrvState = .failed
                                success = false
                        }
                        sleep(1)
                        
                        
                        msg = "checking imap address"
                        if imapSrv.isValidHostname || imapSrv.isValidIpAddress{
                                imapSrvState = .success
                        }else{
                                imapSrvState = .failed
                                success = false
                        }
                        sleep(1)
                        
                        msg = "checking stamp address"
                        var stampName = ""
                        if stampAddr.isEmpty{
                                stampState = .failed
                                success = false
                        }else{
                                print("------>>>stampAddr:",stampAddr)
                                if let s = SdkDelegate.inst.stampConfFromBlockChain(sAddr: stampAddr){
                                        msg = "stamp name is \(s.MailBox) "
                                        stampState = .success
                                        stampName = s.MailBox
                                }else{
                                        stampState = .failed
                                        success = false
                                }
                        }
                        sleep(1)
                        
                        var caData:Data?
                        if smtpSSLOn || imapSSLOn{
                                msg = "reading CA file"
                                if let url  = caFileUrl, let data =  try? Data(contentsOf: url){
                                        caFileState = .success
                                        caData = data
                                }else{
                                        caFileState = .failed
                                        success = false
                                }
                        }
                        if success == false{
                                showTipsView = false
                                return
                        }
                        
                        let setting = Setting(email: eMailAddr, smtp: smtpSrv, imap: imapSrv,
                                              stampAddr: stampAddr, stampName: stampName,
                                              smtpSSL: smtpSSLOn, imapSSL: imapSSLOn,
                                              caName: caFileName, caData: caData)
                        
                        if let e = setting.syncToDatabase(){
                                showTipsView = false
                                showAlert = true
                                msg = e.localizedDescription
                                return
                        }
                        
                        showAlert = true
                        msg = "Success!"
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
                NewSettingView(isPresented: isPresent)
        }
}
