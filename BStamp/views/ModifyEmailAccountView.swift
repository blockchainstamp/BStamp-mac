//
//  ModifySettingView.swift
//  BStamp
//
//  Created by wesley on 2023/2/8.
//

import SwiftUI

struct ModifyEmailAccountView: View {
        @Binding var isPresented: Bool
        @Environment(\.managedObjectContext) private var viewContext
        @ObservedObject var selection:CoreData_Setting
        
        @State var caFileName:String = ""
        @State var caFileUrl:URL? = nil
        @State var caChanged:Bool = false
        
        @State var smtpSrvAddr:String = ""
        @State var smtpChanged:Bool = false
        @State var imapSrvAddr:String = ""
        @State var imapChanged:Bool = false
        @State var stampAddr:String = ""
        @State var stampChanged:Bool = false
        
        @State var smtpSrvState:TripState = .start
        @State var imapSrvState:TripState = .start
        @State var caFileState:TripState = .start
        @State var stampState:TripState = .start
        
        @State var stampObj:Stamp?
        @EnvironmentObject private var currentWallet: Wallet
        
        @FocusState var focusedField: String?
        @State var showAlert:Bool = false
        @State var showTipsView:Bool = false
        @State var msg:String = ""
        @State var alertAction: Alert.Button = .default(Text("Got it!"))
        var body: some View {
                ZStack{
                        List {
                                HStack {
                                        Image(systemName: "signpost.left.circle")
                                        TextField("Email Address", text: $selection.mailAcc.toUnwrapped(defaultValue: ""))
                                                .padding()
                                                .cornerRadius(1.0)
                                }.disabled(true)
                                
                                
                                HStack {
                                        Image(systemName: "tray.and.arrow.up")
                                        TextField("SMTP Server", text: $smtpSrvAddr)
                                                .padding()
                                                .cornerRadius(1.0)
                                                .focused($focusedField, equals: "smtp")
                                                .onSubmit {
                                                        focusedField="imap"
                                                }.onChange(of: smtpSrvAddr) { newValue in
                                                        smtpChanged = newValue != $selection.smtpSrv.wrappedValue
                                                        print("------>>>",smtpChanged)
                                                }.border(.green)
                                        
                                        TextField("SMTP Port", text: Binding(get: {
                                                return "\(selection.smtpPort)"
                                        }, set: { newVal in
                                                smtpChanged = true
                                                selection.smtpPort = toValidPort(portStr: newVal,
                                                                       defaultVal: Consts.DefaultSmtpPort)
                                        }))
                                        .padding()
                                        .cornerRadius(1.0)
                                        .border(.green).frame(maxWidth: 80)
                                        
                                        CheckingView(state: $smtpSrvState)
                                }.labelStyle(.iconOnly)
                                
                                HStack {
                                        Image(systemName: "tray.and.arrow.down")
                                        TextField("IMAP Server", text: $imapSrvAddr)
                                                .padding()
                                                .cornerRadius(1.0)
                                                .focused($focusedField, equals: "imap")
                                                .onSubmit {
                                                        focusedField="stamp"
                                                }.onChange(of: imapSrvAddr) { newValue in
                                                        imapChanged = newValue != $selection.imapSrv.wrappedValue
                                                }.border(.green)
                                        
                                        TextField("IMAP Port", text: Binding(get: {
                                                return "\(selection.imapPort)"
                                        }, set: { newVal in
                                                selection.imapPort = toValidPort(portStr: newVal,
                                                                      defaultVal: Consts.DefaultImapPort)
                                                imapChanged = true
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
                                                        caChanged = true
                                                }
                                                
                                                
                                        }, label: {
                                                Label("File", systemImage: "folder")
                                        })
                                        CheckingView(state: $caFileState).labelStyle(.iconOnly)
                                }
                                HStack {
                                        Spacer()
                                        Toggle("SMTP Secure Connection", isOn: $selection.smtpSSLOn)
                                                .toggleStyle(.checkbox)
                                        
                                        Spacer()
                                        Toggle("IMAP Secure Connection", isOn: $selection.imapSSLOn)
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
                                                Button(action: {
                                                        removeStamp()
                                                }, label: {
                                                        Label("Clear", systemImage: "x.circle")
                                                })
                                        }//.labelStyle(.iconOnly)
                                        
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
                                                saveChanges()
                                        }, label: {
                                                Label("Save", systemImage: "square.and.arrow.down")
                                        })
                                        Spacer()

                                        Button(action: {
                                                isPresented = false
                                        }, label: {
                                                Label("Cancel", systemImage: "leaf")
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
                                } .frame(minWidth: 600,minHeight: 540)
                                .onAppear(){
                                        caFileName = $selection.caName.wrappedValue ?? ""
                                        smtpSrvAddr = $selection.smtpSrv.wrappedValue ?? ""
                                        imapSrvAddr = $selection.imapSrv.wrappedValue ?? ""
                                        stampAddr = $selection.stampAddr.wrappedValue ?? ""
                                }
                        
                        CircularWaiting(isPresent: $showTipsView, tipsTxt:$msg)
                }
        }
        
        func loadStampData(){
                guard !stampAddr.isEmpty else{
                        stampObj = nil
                        return
                }
                
                guard SdkDelegate.inst.isValidEtherAddr(sAddr: stampAddr) else{
                        stampObj = nil
                        showTipsView = false
                        return
                }
                
                if stampObj != nil && stampObj?.Addr == stampAddr{
                        return
                }
                
                showTipsView = true
                Task {
                        msg = "checking stamp address"
                        await taskSleep(seconds: 1)
                        
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
                smtpSrvState = .start
                imapSrvState = .start
                caFileState = .start
                stampState = .start
        }
        
        func saveChanges(){
                resetState()
                showTipsView = true
                Task(priority: .background) {
                        
                        var success = true
                        
                        if smtpChanged{
                                msg = "checking smtp address"
                                if smtpSrvAddr.isValidHostname || smtpSrvAddr.isValidIpAddress{
                                        smtpSrvState = .success
                                }else{
                                        smtpSrvState = .failed
                                        success = false
                                }
                                $selection.smtpSrv.wrappedValue = smtpSrvAddr
                                await taskSleep(seconds: 1)
                        }
                        
                        if imapChanged{
                                msg = "checking imap address"
                                if imapSrvAddr.isValidHostname || imapSrvAddr.isValidIpAddress{
                                        imapSrvState = .success
                                }else{
                                        imapSrvState = .failed
                                        success = false
                                }
                                $selection.imapSrv.wrappedValue = imapSrvAddr
                                await taskSleep(seconds: 1)
                        }
                        
                        
                        if stampAddr.isEmpty{
                                removeStamp()
                        }else{
                                msg = "checking stamp address"
                                if let s = stampObj{
                                        $selection.stampAddr.wrappedValue = s.Addr
                                        $selection.stampName.wrappedValue = s.MailBox
                                        stampState = .success
                                }else{
                                        if let s = SdkDelegate.inst.stampConfFromBlockChain(sAddr: stampAddr){
                                                msg = "stamp name is \(s.MailBox) "
                                                stampState = .success
                                                $selection.stampAddr.wrappedValue = s.Addr
                                                $selection.stampName.wrappedValue = s.MailBox
                                        }else{
                                                stampState = .failed
                                                success = false
                                        }
                                }
                        }
                        await taskSleep(seconds: 1)
                        
                        if caChanged{
                                var caData:Data?
                                if $selection.smtpSSLOn.wrappedValue || $selection.imapSSLOn.wrappedValue{
                                        msg = "reading CA file"
                                        if let url  = caFileUrl, let data =  try? Data(contentsOf: url){
                                                if let filePath = Setting.createCaFile(fileName: selection.smtpSrv!,
                                                                                       caData: data){
                                                        caFileState = .success
                                                        caData = data
                                                        $selection.caFilePath.wrappedValue = filePath
                                                }else{
                                                        caFileState = .failed
                                                        success = false
                                                }
                                        }else{
                                                caFileState = .failed
                                                success = false
                                        }
                                }
                                $selection.caData.wrappedValue = caData
                                $selection.caName.wrappedValue = caFileName
                        }
                        
                        if success == false{
                                showTipsView = false
                                return
                        }
                       
                        try? viewContext.save()
                        
                        showAlert = true
                        msg = "Success!"
                        showTipsView = false
                        alertAction = .default(Text("Sure")){
                                NotificationCenter.default.post(name: Consts.Noti_Setting_Updated, object: nil)
                        }
                        smtpChanged = false
                        imapChanged = false
                        stampChanged = false
                }
        }
        
        func removeStamp(){
                $selection.stampAddr.wrappedValue = nil
                $selection.stampName.wrappedValue = nil
                stampObj = nil
                stampAddr = ""
        }
}

struct ModifySettingView_Previews: PreviewProvider {
        //
        //        static var obj:Binding<CoreData_Setting> = {
        //                Binding(get: {
        //                        let ctx = PersistenceController.shared.container.viewContext
        //                        let obj = CoreData_Setting(context: ctx)
        //                        obj.mailAcc = "xxxx@qq.com"
        //                        obj.smtpSrv = "smtp.qq.com"
        //                        obj.imapSrv = "imap.qq.com"
        //                        obj.stampName = "qq.cert"
        //                        obj.stampAddr = "0xF9Cbfd74808f812a3B8A2337BFC426B2A10Bd74a"
        //                        return obj
        //                }, set: { _ in  })
        //        }()
        
        static let ctx = PersistenceController.shared.container.viewContext
        static  var obj = CoreData_Setting(context: ctx)
        @State static var show = true
        @State static var showModItemView = true
        @State static  var msg = "testing"
        static var previews: some View {
                ModifyEmailAccountView(isPresented: $showModItemView, selection: StampWallet.ModifySettingView_Previews.obj)
        }
}
