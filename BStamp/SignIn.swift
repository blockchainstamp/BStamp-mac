//
//  SignInOrUp.swift
//  BStamp
//
//  Created by wesley on 2023/2/1.
//

import SwiftUI


struct SignIn: View {
        @State var username: String = ""
        @State var password: String = ""
        @Environment(\.openWindow) private var openWindow
        
        var body: some View {
                
                VStack {
                        WelcomeText()
                        LogoImgView()
                        HStack {
                                Image(systemName: "person").foregroundColor(.secondary)
                                TextField("Username", text: $username)
                                        .padding()
                                        .cornerRadius(1.0)
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
                        
                        Button(action: {
                                openNewAccountWindow()
                        }) {
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
                }
                .padding()
        }
        
        func openNewAccountWindow(){
                NSApplication.shared.keyWindow?.close()
                let window = NSWindow(contentRect: NSRect(x: 20, y: 20, width: 480, height: 300), styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView], backing: .buffered, defer: false)
                window.center()
                window.setFrameAutosaveName("Account Window")
                window.contentView = NSHostingView(rootView: NewAccount())
                window.makeKeyAndOrderFront(nil)
        }
}
#if DEBUG
struct SignInOrUp_Previews: PreviewProvider {
        static var previews: some View {
                SignIn()
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


struct SignUpButtonContent : View {
        var body: some View {
                return Text("Create Wallet")
                        .padding()
                        .frame(width: 220, height: 40)
                        .cornerRadius(15.0)
        }
}
