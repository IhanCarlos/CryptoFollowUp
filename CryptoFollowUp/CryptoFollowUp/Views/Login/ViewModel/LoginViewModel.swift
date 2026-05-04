//
//  LoginViewModel.swift
//  CryptoFollowUp
//
//  Created by ihan carlos on 04/05/26.
//

import SwiftUI
import FirebaseAuth
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    
    @Published var email: String = ""
    @Published var password: String = ""
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isLogged: Bool = false
    
    private let authService: AuthService
    
    init(authService: AuthService = .shared) {
        self.authService = authService
    }
    
    func signUp() async {
        guard validate() else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await authService.signUp(email: email, password: password)
            isLogged = true
        } catch {
            errorMessage = mapError(error)
        }
        
        isLoading = false
    }
    
    func signIn() async {
        guard validate() else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await authService.signIn(email: email, password: password)
            isLogged = true
        } catch {
            errorMessage = mapError(error)
        }
        
        isLoading = false
    }
}

private extension LoginViewModel {
    
    func validate() -> Bool {
        if email.isEmpty || password.isEmpty {
            errorMessage = "Preencha todos os campos"
            return false
        }
        
        if !email.contains("@") {
            errorMessage = "Email inválido"
            return false
        }
        
        if password.count < 6 {
            errorMessage = "Senha deve ter pelo menos 6 caracteres"
            return false
        }
        
        return true
    }
}

private extension LoginViewModel {
    
    func mapError(_ error: Error) -> String {
        let nsError = error as NSError
        
        switch nsError.code {
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return "Email já está em uso"
        case AuthErrorCode.invalidEmail.rawValue:
            return "Email inválido"
        case AuthErrorCode.weakPassword.rawValue:
            return "Senha muito fraca"
        case AuthErrorCode.userNotFound.rawValue:
            return "Usuário não encontrado"
        case AuthErrorCode.wrongPassword.rawValue:
            return "Senha incorreta"
        default:
            return "Erro inesperado"
        }
    }
}
