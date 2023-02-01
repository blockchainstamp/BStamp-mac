//
//  SignInOrUp.swift
//  BStamp
//
//  Created by wesley on 2023/2/1.
//

import SwiftUI

let lightGreyColor = Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0)

struct SignInOrUp: View {
        @State var username: String = ""
        @State var password: String = ""
        
        var body: some View {
                
                VStack {
                        WelcomeText()
                        UserImage()
                        HStack {
                                Image(systemName: "person").foregroundColor(.secondary)
                                TextField("Username", text: $username)
                                        .padding()
                                        .background(lightGreyColor)
                                        .cornerRadius(1.0)
                                        .padding(.top, 10)
                                        .padding(.bottom, 10)
                        }
                        HStack {
                                Image(systemName: "key").foregroundColor(.secondary)
                                SecureField("Password", text: $password)
                                        .padding()
                                        .background(lightGreyColor)
                                        .cornerRadius(1.0)
                                        .padding(.top, 10)
                                        .padding(.bottom, 10)
                        }
                        Button(action: {print("Button tapped")}) {
                                LoginButtonContent()
                        }
                }
                .padding()
        }
}
#if DEBUG
struct SignInOrUp_Previews: PreviewProvider {
        static var previews: some View {
                SignInOrUp()
        }
}
#endif

struct WelcomeText : View {
        var body: some View {
                return Text("Welcome!")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .padding(.bottom, 20)
        }
}

struct UserImage : View {
        var body: some View {
                return Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 150, height: 150)
                        .clipped()
                        .cornerRadius(150)
                        .padding(.bottom, 75)
        }
}

struct LoginButtonContent : View {
        var body: some View {
                return Text("LOGIN")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 220, height: 60)
                        .background(Color.green)
                        .cornerRadius(15.0)
        }
}
