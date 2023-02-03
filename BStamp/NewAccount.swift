//
//  NewAccount.swift
//  BStamp
//
//  Created by wesley on 2023/2/2.
//

import SwiftUI

struct NewAccount: View {
        @State var walletName: String = ""
        @State var password_1: String = ""
        @State var password_2: String = ""
        @State var showAlert:Bool = false
        @State var title:String = ""
        @State var msg:String = ""
        @State var showTipsView: Bool = false
        
        var body: some View {
                ZStack{
                       
                        VStack {
                                
                                LogoImgView()
                                HStack {
                                        Image(systemName: "person").foregroundColor(.secondary)
                                        TextField("Wallet Name", text: $walletName)
                                                .padding()
                                                .cornerRadius(5.0)
                                }.alert(isPresented: $showAlert) {
                                        Alert(
                                                title: Text(title),
                                                message: Text(msg),
                                                dismissButton: .default(Text("Got it!"))
                                        )
                                }.padding(.leading, 20).padding(.trailing,20)
                                HStack {
                                        Image(systemName: "key").foregroundColor(.secondary)
                                        SecureField("Password Fist", text: $password_1)
                                                .padding()
                                                .cornerRadius(5.0)
                                }.padding(.leading, 20).padding(.trailing,20)
                                HStack {
                                        Image(systemName: "key").foregroundColor(.secondary)
                                        SecureField("Password Again", text: $password_2)
                                                .padding()
                                                .cornerRadius(5.0)
                                }.padding(.bottom, 40).padding(.leading, 20).padding(.trailing,20)
                                Button(action: {
                                        createWallet()
                                        
                                        
                                }) {
                                        Text("Create").fontWeight(.bold)
                                                .font(.system(size: 18))
                                                .frame(width: 220, height: 20)
                                                .foregroundColor(.blue)
                                                .padding()
                                                .overlay(
                                                        RoundedRectangle(cornerRadius: 16)
                                                                .stroke(.blue, lineWidth: 2)
                                                )
                                }.buttonStyle(.plain)
                        }
                        CircularWaiting(isPresent: $showTipsView, tipsTxt:$msg)
//                        CircularWaiting(isPresent: $showTipsView, tipsTxt:$msg, color: .blue)
                }.frame(minWidth: 360,minHeight: 600)
                
        }
        
        func createWallet(){
                if walletName.lengthOfBytes(using: .utf8) == 0{
                        showAlert = true
                        title = "Tips"
                        msg = "Wallet name needed"
                        return
                }
                if password_1.lengthOfBytes(using: .utf8) < 3{
                        showAlert = true
                        title = "Tips"
                        msg = "Password need more than 2 characters"
                        return
                }
                if !password_1.elementsEqual(password_2){
                        showAlert = true
                        title = "Tips"
                        msg = "Two passwords not same"
                        return
                }
                showTipsView = true
                msg = "Creating"
        }
}

struct NewAccount_Previews: PreviewProvider {
        static var previews: some View {
                NewAccount()
        }
}
