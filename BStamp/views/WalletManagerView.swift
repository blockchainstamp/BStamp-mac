//
//  WalletManagerView.swift
//  BStamp
//
//  Created by wesley on 2023/2/13.
//

import SwiftUI
import UniformTypeIdentifiers

struct WalletManagerView: View {
        @Binding var isPresented: Bool
        @State var showDelAlert:Bool = false
        @State var showingAlert:Bool = false
        @State var showNewWalletView:Bool = false
        @State var showImportWalletView:Bool = false
        @State var alertMsg = ""
        @State var addrToRemove = ""
        @State var wallets:[Wallet] = []
        @State private var showingExporter = false
        @State var walletFile:TextFile?
        
        @Environment(\.presentationMode) var presentationMode
        
        var body: some View {
                VStack{
                        Spacer()
                        HStack{
                                Button {
                                        showNewWalletView = true
                                } label: {
                                        Label("New", systemImage: "plus")
                                }
                                Button {
                                        showImportWalletView = true
                                } label: {
                                        Label("Import", systemImage: "arrowshape.turn.up.right")
                                }
                                Spacer()
                        }.sheet(isPresented: $showNewWalletView) {
                                NewWalletView(isPresented: $showNewWalletView).fixedSize()
                        }.sheet(isPresented: $showImportWalletView) {
                                ImportWalletView(isPresented: $showImportWalletView).fixedSize()
                        }
                        List{
                                ForEach(wallets, id:\.self) { wallet in
                                        HStack{
                                                Text(wallet.Name + "\t")
                                                Text(wallet.Addr + "\t")
                                                Spacer()
                                                Button(action: {
                                                        showDelAlert = true
                                                        addrToRemove = wallet.Addr
                                                }, label: {
                                                        Label("Delete", systemImage: "trash")
                                                })
                                                Spacer()
                                                Button(action: {
                                                        exportWallet(wallet.jsonStr, name:wallet.Name)
                                                }, label: {
                                                        Label("Export", systemImage: "book")
                                                })
                                                .fileExporter(isPresented: $showingExporter,
                                                              document: walletFile,
                                                              contentType: .json,
                                                              defaultFilename: walletFile?.name ?? "wallet") { result in
                                                        showingAlert = true
                                                        switch result {
                                                        case .success(let url):
                                                                alertMsg = "Save Success"
                                                                print(url)
                                                        case .failure(let error):
                                                                alertMsg = error.localizedDescription
                                                        }
                                                } .alert(alertMsg, isPresented: $showingAlert) {
                                                        Button("OK", role: .cancel) { }
                                                }
                                                Spacer()
                                        }
                                }
                        }.border(.purple).frame(minWidth: 560, minHeight: 360).task {
                                refreshWallets()
                        }.padding()  .alert(alertMsg, isPresented: $showingAlert) {
                                Button("OK", role: .cancel) {
                                        refreshWallets()
                                }
                        }.alert(isPresented: $showDelAlert) {
                                Alert(
                                        title: Text("Are You Sure?!"),
                                        message: Text("There's no server to recover wallet except you have backup"),
                                        primaryButton: .default(
                                                Text("No"),
                                                action: {
                                                        showDelAlert = false
                                                }
                                        ),
                                        secondaryButton: .destructive(
                                                Text("Sure"),
                                                action: {
                                                        removeWallet()
                                                }
                                        )
                                )
                        }
                        
                        Spacer()
                        HStack{
                                Spacer()
                                Button {
                                        isPresented = false
                                        presentationMode.wrappedValue.dismiss()
                                } label: {
                                        Label("Cancel", systemImage: "square.and.arrow.up")
                                }
                                Spacer()
                        }
                        Spacer()
                }.padding().onAppear(){
                        NotificationCenter.default.addObserver(forName: Consts.Noti_Wallet_Created,
                                                               object: nil,
                                                               queue: nil,
                                                               using: self.walletListChanged)
                }
        }
        private func refreshWallets(){
                SdkDelegate.inst.loadSavedWallet()
                wallets = SdkDelegate.inst.Wallets
                if wallets.count == 0{
                        return
                }
                print("------->>>", wallets.count)
        }
        
        private func removeWallet(){
                print("------>>>", addrToRemove)
                guard !addrToRemove.isEmpty else{
                        return
                }
                
                if let err = SdkDelegate.inst.removeWallet(addr: addrToRemove){
                        showingAlert = true
                        alertMsg = err.localizedDescription
                }
                alertMsg = "Success"
                showingAlert = true
        }
        
        private func exportWallet(_ jsonStr:String?, name:String){
                guard let str = jsonStr else{
                        return
                }
                
                walletFile = TextFile(initialText: str)
                walletFile?.name = name
                showingExporter = true
        }
        func walletListChanged(_ notification: Notification) {
                refreshWallets()
        }
}

struct TextFile: FileDocument {
        
        // tell the system we support only plain text
        static var readableContentTypes = [UTType.json]
        
        // by default our document is empty
        var text = ""
        public var name = ""
        
        // a simple initializer that creates new, empty documents
        init(initialText: String = "") {
                text = initialText
        }
        
        // this initializer loads data that has been saved previously
        init(configuration: ReadConfiguration) throws {
                if let data = configuration.file.regularFileContents {
                        text = String(decoding: data, as: UTF8.self)
                }
        }
        
        // this will be called when the system wants to write our data to disk
        func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
                let data = Data(text.utf8)
                return FileWrapper(regularFileWithContents: data)
        }
}
struct WalletManagerView_Previews: PreviewProvider {
        static private var isPresent = Binding<Bool> (
                get: { true}, set: { _ in }
        )
        static var previews: some View {
                WalletManagerView(isPresented: isPresent)
        }
}
