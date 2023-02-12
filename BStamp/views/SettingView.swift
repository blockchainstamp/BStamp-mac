//
//  SettingView.swift
//  BStamp
//
//  Created by wesley on 2023/2/12.
//

import SwiftUI

struct SettingView: View {
        @Environment(\.managedObjectContext) private var viewContext
        
        @FetchRequest(
                sortDescriptors: [NSSortDescriptor(keyPath: \CoreData_Setting.mailAcc, ascending: true)],
                animation: .default)
        private var settings: FetchedResults<CoreData_Setting>
        
        @FetchRequest(
                sortDescriptors: [NSSortDescriptor(keyPath: \CoreData_Stamp.address, ascending: true)],
                animation: .default)
        private var stampsRequest: FetchedResults<CoreData_Stamp>
        @State var stampsInDB:[Stamp] = []
        
        @State var msg:String = ""
        @State var showAlert:Bool = false
        @State var selectedStamp:[String:String] = [:]
        
        var body: some View {
                VStack{
                        HStack{
                                Text("Email Account\t\t\t")
                                Text("Stamp To Use")
                        }
                        
                        ForEach(settings) { item in
                                HStack{
                                        Text(item.mailAcc!)
                                        
                                        Picker("", selection: $selectedStamp[item.mailAcc!]) {
                                                Text("No Option").tag(Optional<String>(""))
                                                ForEach(stampsRequest, id:\.address) { stamp in
                                                        Text(stamp.mailbox! + ": " + stamp.address!)
                                                }
                                        }
                                        .pickerStyle(.menu)
                                }
                                .onChange(of: selectedStamp[item.mailAcc!]) { newVale in
                                        changeStamp(setting: item, addr: newVale)
                                }
                        }
                        Spacer()
                }.padding(SwiftUI.EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                        .alert(isPresented: $showAlert) {
                                Alert(
                                        title: Text("Tips"),
                                        message: Text(msg),
                                        dismissButton: .default(Text("OK"))
                                )
                        }.onAppear() {
                                for obj in settings{
                                        selectedStamp[obj.mailAcc!] = obj.stampAddr ?? ""
                                }
                                
                                Stamp.loadSavedStamp()
                                stampsInDB = Stamp.Stamps
                              
                                
                        }.onDisappear(){
                                try? viewContext.save()
                        }
        }
        
        private func changeStamp(setting:CoreData_Setting, addr:String?){
                print("------>>>", setting.mailAcc!, addr ?? "<->")
                setting.stampAddr = addr
        }
        
        private func saveChange(){
                do{
                        try viewContext.save()
                        msg = "Saved"
                        showAlert = true
                }catch let err{
                        msg = err.localizedDescription
                        showAlert = true
                }
        }
}


struct SettingView_Previews: PreviewProvider {
        static var previews: some View {
                SettingView()
        }
}
