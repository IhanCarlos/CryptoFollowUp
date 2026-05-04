//
//  TextFieldView.swift
//  CryptoFollowUp
//
//  Created by ihan carlos on 04/05/26.
//

import SwiftUI

struct CustomTextField: View {
    
    let title: String
    let placeholder: String
    @Binding var text: String
    
    var isSecure: Bool = false
    
    @State private var isSecured: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            
            HStack {
                
                if isSecure {
                    Group {
                        if isSecured {
                            SecureField(placeholder, text: $text)
                        } else {
                            TextField(placeholder, text: $text)
                        }
                    }
                } else {
                    TextField(placeholder, text: $text)
                }
                
                if isSecure {
                    Button {
                        isSecured.toggle()
                    } label: {
                        Image(systemName: isSecured ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

#Preview {
    CustomTextField(
        title: "Email",
        placeholder: "Digite seu email",
        text: .constant("")
    )
    .padding()
    .previewLayout(.sizeThatFits)
}
