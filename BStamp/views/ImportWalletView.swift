//
//  ImportAccount.swift
//  BStamp
//
//  Created by wesley on 2023/2/5.
//

import SwiftUI

struct ImportWalletView: View {
        @State var fileName:String = "File Path Of Wallet File (json format)"
        @State var fileUrl:URL? = nil
        @State var showAlert:Bool = false
        @State var showTipsView:Bool = false
        @State var msg:String=""
        @State var password:String = ""
        @State var alertAction: Alert.Button = .default(Text("Got it!"))
        @Environment(\.presentationMode) var presentationMode
        
        var body: some View {
                ZStack{
                        VStack(spacing: 20){
                                
                                Text(fileName) .frame(maxWidth: 320).multilineTextAlignment(.leading)
                                Button("chose file"){
                                        let panel = NSOpenPanel()
                                        panel.allowsMultipleSelection = false
                                        panel.canChooseDirectories = false
                                        if panel.runModal() == .OK {
                                                fileName = panel.url?.lastPathComponent ?? ""
                                                fileUrl = panel.url
                                        }
                                }
                                
                                SecureField("Password Of Wallet", text: $password)
                                        .padding(.leading, 40)
                                        .padding(.trailing,40)
                                        .cornerRadius(1.0)
                                
                                Button(action: {
                                        loadWallet()
                                }) {
                                        Text("Import Now").fontWeight(.medium)
                                                .font(.system(size: 18))
                                                .frame(width: 120, height: 16)
                                                .foregroundColor(.purple)
                                                .padding()
                                                .overlay(
                                                        RoundedRectangle(cornerRadius: 16)
                                                                .stroke(.purple, lineWidth: 2)
                                                )
                                }.buttonStyle(.plain)
                                        .alert(isPresented: $showAlert) {
                                                Alert(
                                                        title: Text("Tips"),
                                                        message: Text(msg),
                                                        dismissButton: alertAction
                                                )
                                        }
                                
                        }.disabled(showTipsView)
                        CircularWaiting(isPresent: $showTipsView, tipsTxt:$msg)
                        
                }.frame(minWidth: 360,minHeight: 600)
        }
        
        
        
        func loadWallet(){
                guard let url  = fileUrl else{
                        showAlert = true
                        msg = "Chose wallet file first!"
                        return
                }
                
                guard password.lengthOfBytes(using: .utf8) > 2 else{
                        
                        showAlert = true
                        msg = "Input the Password!"
                        return
                }
                print(fileName)
                do{
                        let data = try Data(contentsOf: url)
                        guard let wStr = String(data: data, encoding: .utf8) else{
                                showAlert = true
                                msg = "wallet file format error"
                                return
                        }
                        
                        showTipsView = true
                        msg = "Importing"
                        Task{
                                let err =  SdkDelegate.inst.importWallet(wallet: wStr, password: password)
                                if let e = err{
                                        showAlert = true
                                        showTipsView = false
                                        msg = e.localizedDescription
                                        return
                                }
                                sleep(2)
                                showTipsView = false
                                showAlert = true
                                msg = "Wallet Import!"
                                alertAction = .default(Text("Sure")){
                                        presentationMode.wrappedValue.dismiss()
                                        NotificationCenter.default.post(name: Consts.Noti_Wallet_Created, object: nil)
                                }
                        }
                }catch let e{
                        print(e)
                        showAlert = true
                        msg = e.localizedDescription
                        return
                }
        }
        
}

struct ImportAccount_Previews: PreviewProvider {
        static var previews: some View {
                ImportWalletView()
        }
}
