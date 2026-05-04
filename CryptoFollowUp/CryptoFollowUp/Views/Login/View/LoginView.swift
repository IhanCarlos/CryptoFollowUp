//
//  LoginView.swift
//  CryptoFollowUp
//
//  Created by ihan carlos on 04/05/26.
//

import SwiftUI

struct LoginView: View {
    
    @StateObject var viewModel = LoginViewModel()
    
    var body: some View {
        VStack(spacing: 24) {
            
            Spacer()
 
            VStack(spacing: 8) {
                Text("Bem-vindo")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Faça login para continuar")
                    .foregroundColor(.gray)
            }

            VStack(spacing: 16) {
                
                CustomTextField(
                    title: "Email",
                    placeholder: "Digite seu email",
                    text: $viewModel.email,
//                    keyboardType: .emailAddress,
//                    autocapitalization: .never
                )
                
                CustomTextField(
                    title: "Senha",
                    placeholder: "Digite sua senha",
                    text: $viewModel.password,
                    isSecure: true
                )
            }
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 12) {
                
                Button {
                    Task {
                        await viewModel.signIn()
                    }
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Text("Entrar")
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                
                Button {
                    Task {
                        await viewModel.signUp()
                    }
                } label: {
                    Text("Criar conta")
                        .frame(maxWidth: .infinity)
                }
            }
            
            Spacer()
        }
        .padding()
        
        .fullScreenCover(isPresented: $viewModel.isLogged) {
//            HomeView() // próxima tela
        }
    }
}

#Preview {
    LoginView()
}
