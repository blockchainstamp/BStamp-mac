//
//  SignInOrUp.swift
//  BStamp
//
//  Created by wesley on 2023/2/1.
//

import SwiftUI


struct SignIn: View {
        @State var walletName: String = ""
        @State var password: String = ""
        @Environment(\.openWindow) private var openWindow
        @State private var isActive = false
        
        @State private var wallets:[Wallet]=[Wallet]()
        @State private var selection = Wallet()
        
        var body: some View {
                NavigationStack{
                        VStack {
                                WelcomeText()
                                LogoImgView()
                                HStack {
                                        Image(systemName: "person").foregroundColor(.secondary)
                                        Picker("", selection: $selection) {
                                                ForEach(wallets, id:\.self) { wallet in
                                                        Text(wallet.Name)
                                                                .font(.headline)
                                                                .fontWeight(.semibold)
                                                        Text(wallet.Addr)
                                                                .font(.subheadline)
                                                                .fontWeight(.thin)
                                                                .padding()
                                                                .padding(.leading,100)
                                                        
                                                }
                                        }
                                        .pickerStyle(.menu)
                                }
                                HStack {
                                        Image(systemName: "key").foregroundColor(.secondary)
                                        SecureField("Password", text: $password)
                                                .padding()
                                                .cornerRadius(1.0)
                                }
                                Button(action: {
                                        print("Button tapped")
                                        
                                }) {
                                        Text("Sign In").fontWeight(.bold)
                                                .font(.system(size: 18))
                                                .frame(width: 220, height: 20)
                                                .foregroundColor(.blue)
                                                .padding()
                                                .overlay(
                                                        RoundedRectangle(cornerRadius: 16)
                                                                .stroke(.blue, lineWidth: 2)
                                                )
                                }.buttonStyle(.plain)
                                
                                NavigationLink(destination: NewAccount()) {
                                        Text("Create Wallet").fontWeight(.bold)
                                                .font(.system(size: 18))
                                                .frame(width: 220, height: 20)
                                                .foregroundColor(.red)
                                                .padding()
                                                .overlay(
                                                        RoundedRectangle(cornerRadius: 16)
                                                                .stroke(.orange, lineWidth: 2)
                                                )
                                }.buttonStyle(.plain)
                        } .padding()
                }.task {
                        wallets = SdkDelegate.inst.loadSavedWallet()
                        selection = wallets[0]
                }.onChange(of: selection) { newValue in
                        password = ""
                }
        }
        
        func openNewAccountWindow(){
                NSApplication.shared.keyWindow?.close()
                let window = NSWindow(contentRect: NSRect(x: 20, y: 20, width: 320, height: 600), styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView], backing: .buffered, defer: false)
                window.center()
                window.setFrameAutosaveName("Account Window")
                window.contentView = NSHostingView(rootView: NewAccount())
                window.makeKeyAndOrderFront(nil)
        }
}
#if DEBUG
struct SignInOrUp_Previews: PreviewProvider {
        static var previews: some View {
                WelcomeText()
        }
}
#endif

struct WelcomeText : View {
        var body: some View {
                return Text("Stamp Wallet")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .padding(.bottom, 20)
        }
}

struct LogoImgView : View {
        var body: some View {
                return Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                        .clipped()
                        .cornerRadius(20)
                        .padding(.bottom, 25)
        }
}
