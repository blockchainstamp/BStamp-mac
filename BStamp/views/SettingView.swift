//
//  SettingView.swift
//  BStamp
//
//  Created by wesley on 2023/2/8.
//

import SwiftUI


struct SettingView:View{
        @State var selection:Setting = Setting()
        @State var settings:[Setting] = []
        @State var showInfoModalView: Bool = false
        var body: some View {
                
                VStack {
                        Spacer()
                        Button(action: {
                                showInfoModalView = true
                        }) {
                                Text("New").fontWeight(.medium)
                                        .font(.system(size: 18))
                                        .frame(width: 120, height: 20)
                                        .foregroundColor(.green)
                                        .padding()
                                        .overlay(
                                                RoundedRectangle(cornerRadius: 24)
                                                        .stroke(.green, lineWidth: 2)
                                        )
                        }.buttonStyle(.plain)
                        
                        Divider()
                        
                        List(selection: $selection) {
                        }
                }.sheet(isPresented: $showInfoModalView) {
                        SettingDetailView(isPresented: $showInfoModalView).fixedSize()
                }.task {
                        
                }
        }
        
        func showNewSetingDialog(){
                
        }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
