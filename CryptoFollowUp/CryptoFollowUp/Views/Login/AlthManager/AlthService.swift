//
//  AlthService.swift
//  CryptoFollowUp
//
//  Created by ihan carlos on 04/05/26.
//

import FirebaseAuth

final class AuthService {
    
    static let shared = AuthService()
    private init() {}
    
    func signUp(email: String, password: String) async throws {
        try await Auth.auth().createUser(withEmail: email, password: password)
    }
    
    func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }
}
