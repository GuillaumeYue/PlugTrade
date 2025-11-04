//
//  Validators.swift
//  PlugTrade
//
//  Created by Shaquille O Neil on 2025-10-31.
//

import Foundation

enum Validators {
    
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return email.range(of: emailRegex, options: .regularExpression, range: nil, locale: nil) != nil
    }
    
    static func isValidPassword(_ password: String) -> Bool {
        return password.count >= 8
    }
}


//custom error object
struct SimpleError: Error{
    let message: String
    
    init(_ message: String) {
        self.message = message
    }
    
    var localizedDescription: String {
        return message
    }
}
