//
//  SignInOrUp.swift
//  BStamp
//
//  Created by wesley on 2023/2/1.
//

import SwiftUI


struct SignIn: View {
        @Environment(\.managedObjectContext) var managedObjectContext
        
        @FetchRequest private var addrConfs: FetchedResults<CoreData_SysConf>
        
        @State var walletName: String = ""
        @State var password: String = ""
        @Environment(\.openWindow) private var openWindow
        @State private var isActive = false
        @State var showAlert:Bool = false
        @State var title:String = ""
        @State var msg:String = ""
        
        @State var wallets:[Wallet] = []
        @State private var selection = Wallet()
        
        init(){
                let request: NSFetchRequest<CoreData_SysConf> = CoreData_SysConf.fetchRequest()
                
                request.sortDescriptors = [
                        NSSortDescriptor(keyPath: \CoreData_SysConf.accountLastUsed, ascending: true)
                ]
                request.fetchLimit = 1
                
                _addrConfs = FetchRequest(fetchRequest: request)
        }
        
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
                                }.alert(isPresented: $showAlert) {
                                        Alert(
                                                title: Text("Error"),
                                                message: Text(msg),
                                                dismissButton: .default(Text("Got it!"))
                                        )
                                }
                                Button(action: {
                                        signinSystem()
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
                                                .foregroundColor(.orange)
                                                .padding()
                                                .overlay(
                                                        RoundedRectangle(cornerRadius: 16)
                                                                .stroke(.orange, lineWidth: 2)
                                                )
                                }.buttonStyle(.plain)
                                
                                NavigationLink(destination: ImportAccount()) {
                                        Text("Import Wallet").fontWeight(.bold)
                                                .font(.system(size: 18))
                                                .frame(width: 220, height: 20)
                                                .foregroundColor(.purple)
                                                .padding()
                                                .overlay(
                                                        RoundedRectangle(cornerRadius: 16)
                                                                .stroke(.purple, lineWidth: 2)
                                                )
                                }.buttonStyle(.plain)
                        } .padding()
                }.task {
                        refreshWallets()
                }.onChange(of: selection) { newValue in
                        password = ""
                        _addrConfs.wrappedValue.first?.accountLastUsed = newValue.Addr
                }.onAppear(){
                        NotificationCenter.default.addObserver(forName: Consts.Noti_Wallet_Created,
                                                               object: nil,
                                                               queue: nil,
                                                               using: self.walletListChanged)
                }.onDisappear(){
                        try? managedObjectContext.save()
                }
        }
        func refreshWallets(){
                DispatchQueue.main.async {
                        SdkDelegate.inst.loadSavedWallet()
                        wallets = SdkDelegate.inst.Wallets
                        if wallets.count == 0{
                                return
                        }
                        print("======>>>", wallets.count)
                        var conf = _addrConfs.wrappedValue.first
                        
                        if conf == nil{
                                conf = CoreData_SysConf(context: managedObjectContext)
                        }
                        
                        guard let addr = conf?.accountLastUsed else{
                                selection = wallets[0]
                                conf!.accountLastUsed = selection.Addr
                                try? managedObjectContext.save()
                                return
                        }
                        for w in wallets{
                                if addr == w.Addr{
                                        selection = w
                                        return
                                }
                        }
                        
                        selection = wallets[0]
                        conf!.accountLastUsed = selection.Addr
                        try? managedObjectContext.save()
                }
        }
        
        func walletListChanged(_ notification: Notification) {
                refreshWallets()
        }
        
        func signinSystem(){
                if let err = SdkDelegate.inst.openWallet(addr: selection.Addr, password: password){
                        showAlert = true
                        msg = err.localizedDescription
                        return
                }
                NSApplication.shared.keyWindow?.contentView = NSHostingView(rootView: MainScene().environment(\.managedObjectContext, managedObjectContext).frame(minWidth: 800, minHeight: 600))
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
