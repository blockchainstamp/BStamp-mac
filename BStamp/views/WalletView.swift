//
//  WalletView.swift
//  BStamp
//
//  Created by wesley on 2023/2/10.
//

import SwiftUI

struct WalletView: View {
        @EnvironmentObject var curWallet: Wallet
        var body: some View {
                Text(curWallet.Addr) .textSelection(.enabled)
                Text(curWallet.Name) .textSelection(.enabled)
                Text(curWallet.jsonStr!) .textSelection(.enabled)
        }
}

struct WalletView_Previews: PreviewProvider {
        static var previews: some View {
                WalletView()
        }
}
