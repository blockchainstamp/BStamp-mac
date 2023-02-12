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
                List{
                        HStack{
                                Label {
                                        Text("Stamp Address:\t\t")
                                } icon: {
                                        Image(systemName: "arrowshape.bounce.right")
                                }
                                Text(curWallet.Addr) .textSelection(.enabled)
                        }
                        HStack{
                                Label {
                                        Text("Stamp Name:\t\t\t")
                                } icon: {
                                        Image(systemName: "person")
                                }
                                Text(curWallet.Name) .textSelection(.enabled)
                        }
                        HStack{
                                Label {
                                        Text("Ethereum Address:\t")
                                } icon: {
                                        Image(systemName: "bitcoinsign.square")
                                }

                                Text(curWallet.EthAddr ?? "") .textSelection(.enabled)
                        }
                }.padding()
        }
}

struct WalletView_Previews: PreviewProvider {
        static var previews: some View {
                WalletView()
        }
}
