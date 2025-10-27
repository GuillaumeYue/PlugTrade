//
//  ProfileScreen.swift
//  PlugTrade
//
//  Created by Shaquille O Neil on 2025-10-26.
//

import SwiftUI
import FirebaseAuth

struct ProfileScreen: View {

    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        VStack {
            Text("Profile Screen")
            
            Button(action: {
               
                authManager.signOut()
            }) {
                Text("Sign Out")
                    .fontWeight(.bold)
                    .padding()
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.blue.opacity(0.8))
                            
                    )
                   
            }
            .padding(.horizontal)
            
        }
       
    }
}

#Preview {
    ProfileScreen()
}
