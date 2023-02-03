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
        
    var body: some View {
            VStack {
                    LogoImgView()
                    HStack {
                            Image(systemName: "person").foregroundColor(.secondary)
                            TextField("Username", text: $walletName)
                                    .padding()
                                    .cornerRadius(1.0)
                    }
                    HStack {
                            Image(systemName: "key").foregroundColor(.secondary)
                            SecureField("Password", text: $password_1)
                                    .padding()
                                    .cornerRadius(1.0)
                    }
                    HStack {
                            Image(systemName: "key").foregroundColor(.secondary)
                            SecureField("Password", text: $password_2)
                                    .padding()
                                    .cornerRadius(1.0)
                    }
            }.frame(minWidth: 360,minHeight: 600)
    }
}

struct NewAccount_Previews: PreviewProvider {
    static var previews: some View {
        NewAccount()
    }
}
