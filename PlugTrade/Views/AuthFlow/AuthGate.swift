//
//  AuthGate.swift
//  PlugTrade
//
//  Created by Shaquille O Neil on 2025-10-31.
//

import SwiftUI

struct AuthGate: View {
    @State private var showLogin = true
    
    
    var body: some View {
        ZStack{
            Image("background3")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Picker("", selection: $showLogin) {
                    Text("Login").tag(true)
                    Text("Signup").tag(false)
                }.pickerStyle(.segmented)
                    .padding(.top, 60)
                
                if showLogin {
                    LoginForm()
                }else{
                    RegisterForm()
                }
                
            }
            

        }
       
    }
}

#Preview {
    AuthGate()
}
