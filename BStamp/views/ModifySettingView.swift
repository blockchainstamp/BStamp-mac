//
//  ModifySettingView.swift
//  BStamp
//
//  Created by wesley on 2023/2/8.
//

import SwiftUI

struct ModifySettingView: View {
        
        @ObservedObject var selection:CoreData_Setting
        
        @State var caFileName:String = ""
        @State var caFileUrl:URL? = nil
        
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
                                        TextField("SMTP Server", text: $selection.smtpSrv.toUnwrapped(defaultValue: ""))
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
                                        TextField("IMAP Server", text: $selection.imapSrv.toUnwrapped(defaultValue: ""))
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
                                        TextField("Stamp Address", text: $selection.stampAddr.toUnwrapped(defaultValue: ""))
                                                .padding()
                                                .cornerRadius(1.0)
                                                .focused($focusedField, equals: "stamp")
                                                .onSubmit {
                                                        focusedField="smtp"
                                                }
                                        
                                        CheckingView(state:$stampState)
                                }.labelStyle(.iconOnly)
                                
                                HStack {
                                        Image(systemName: "shield.lefthalf.filled")
                                        TextField("CA File", text: $selection.caName.toUnwrapped(defaultValue: ""))
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
                                }
                        CircularWaiting(isPresent: $showTipsView, tipsTxt:$msg)
                }.frame(minWidth: 480,minHeight: 600).onAppear(){
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                focusedField = "email"
                        }
                }
        }
        
        func saveChanges(){
                print("------>>>:", selection.smtpSSLOn)
        }
        
        func removeItem(){
                
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
        static var previews: some View {
                ModifySettingView(selection: StampWallet.ModifySettingView_Previews.obj)
        }
}
