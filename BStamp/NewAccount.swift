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
                    TextField("wallet name", text: $walletName)
                            .padding()
                            .cornerRadius(1.0)
                    SecureField("Password first", text: $password_1)
                            .padding()
                            .cornerRadius(1.0)
                    SecureField("Password again", text: $password_2)
                            .padding()
                            .cornerRadius(1.0)
            }
    }
}

struct NewAccount_Previews: PreviewProvider {
    static var previews: some View {
        NewAccount()
    }
}
