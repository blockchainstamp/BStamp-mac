//
//  ModifySettingView.swift
//  BStamp
//
//  Created by wesley on 2023/2/8.
//

import SwiftUI

struct ModifySettingView: View {
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
        
        
        @FocusState var focusedField: String?
        @State var showAlert:Bool = false
        @State var showTipsView:Bool = false
        @State var msg:String = ""
        @State var alertAction: Alert.Button = .default(Text("Got it!"))
        var body: some View {
                ZStack{
                        List {
                                HStack {
                                        Image(systemName: "house.lodge")
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
                                                        smtpChanged = newValue == $selection.smtpSrv.wrappedValue
                                                }
                                        
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
                                                        imapChanged = newValue == $selection.imapSrv.wrappedValue
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
                                                        focusedField="smtp"
                                                }.onChange(of: stampAddr) { newValue in
                                                        stampChanged = newValue == $selection.stampAddr.wrappedValue
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
                                Spacer()
                                HStack{
                                        Spacer()
                                        Button(action: {
                                                saveChanges()
                                        }, label: {
                                                Label("Save", systemImage: "square.and.arrow.down")
                                        })
                                        Spacer()
                                        Button(action: {
                                                removeItem()
                                        }, label: {
                                                Label("Delete", systemImage: "trash")
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
                                } .frame(minWidth: 480,minHeight: 600)
                                .onAppear(){
                                        caFileName = $selection.caName.wrappedValue ?? ""
                                        smtpSrvAddr = $selection.smtpSrv.wrappedValue ?? ""
                                        imapSrvAddr = $selection.imapSrv.wrappedValue ?? ""
                                        stampAddr = $selection.stampAddr.wrappedValue ?? ""
                                }
                        
                        CircularWaiting(isPresent: $showTipsView, tipsTxt:$msg)
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
                        
                        msg = "checking smtp address"
                        if $selection.smtpSrv.wrappedValue!.isValidHostname
                                || $selection.smtpSrv.wrappedValue!.isValidIpAddress{
                                smtpSrvState = .success
                        }else{
                                smtpSrvState = .failed
                                success = false
                        }
                        await taskSleep(seconds: 1)
                        
                        msg = "checking imap address"
                        if $selection.imapSrv.wrappedValue!.isValidHostname
                                || $selection.imapSrv.wrappedValue!.isValidIpAddress{
                                imapSrvState = .success
                        }else{
                                imapSrvState = .failed
                                success = false
                        }
                        await taskSleep(seconds: 1)
                        
                        msg = "checking stamp address"
                        let stmpAddr = $selection.stampAddr.wrappedValue!
                        print("------>>>stampAddr:",stmpAddr)
                        if let s = SdkDelegate.inst.stampConfFromBlockChain(sAddr: stmpAddr){
                                msg = "stamp name is \(s.MailBox) "
                                stampState = .success
                        }else{
                                stampState = .failed
                                success = false
                        }
                        await taskSleep(seconds: 1)
                        
                        var caData:Data?
                        if $selection.smtpSSLOn.wrappedValue || $selection.imapSSLOn.wrappedValue{
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
                        
                        $selection.caData.wrappedValue = caData
                        $selection.caName.wrappedValue = caFileName
                        try? viewContext.save()
                        
                        showAlert = true
                        msg = "Success!"
                        showTipsView = false
                        alertAction = .default(Text("Sure")){
                                NotificationCenter.default.post(name: Consts.Noti_Setting_Updated, object: nil)
                        }
                }
        }
        
        func removeItem(){
                viewContext.delete(selection)
                try? viewContext.save()
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
        @State static  var msg = "testing"
        static var previews: some View {
                ModifySettingView(selection: StampWallet.ModifySettingView_Previews.obj)
        }
}
