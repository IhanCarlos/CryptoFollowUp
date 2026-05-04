//
//  SessionManager.swift
//  CryptoFollowUp
//
//  Created by ihan carlos on 04/05/26.
//

import Foundation
import FirebaseAuth
import SwiftUI
import Combine

@MainActor
final class SessionManager: ObservableObject {
    
    @Published var isLogged: Bool = false
    
    init() {
        checkUser()
    }
    
    func checkUser() {
        isLogged = Auth.auth().currentUser != nil
    }
    
    func logout() {
        try? Auth.auth().signOut()
        isLogged = false
    }
}
