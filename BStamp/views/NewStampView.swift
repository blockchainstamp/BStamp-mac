//
//  NewStampView.swift
//  BStamp
//
//  Created by wesley on 2023/2/10.
//

import SwiftUI

struct NewStampView: View {
        @Binding var isPresented: Bool
        var body: some View {
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }
}

struct NewStampView_Previews: PreviewProvider {
        
        static private var isPresent = Binding<Bool> (
                get: { true}, set: { _ in }
        )
        static var previews: some View {
                NewStampView(isPresented: isPresent)
        }
}
