//
//  SignUpView.swift
//  HabitSetter
//
//  Created by Mattias Axelsson on 2024-04-22.
//

import SwiftUI

struct SignUpView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showingAlert: Bool = false
    @State private var alertMessage: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Skapa ett konto")
                    .font(.largeTitle)

                TextField("E-post", text: $email)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)

                SecureField("Lösenord", text: $password)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)

                SecureField("Bekräfta lösenord", text: $confirmPassword)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)

                Button("Registrera") {
                    registerUser()
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)

                Spacer()
            }
            .padding()
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Registrering"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func registerUser() {
        guard email.contains("@"), email.contains(".") else {
            alertMessage = "Ange en giltig e-postadress."
            showingAlert = true
            return
        }

        guard password.count >= 8 else {
            alertMessage = "Lösenordet måste vara minst 8 tecken långt."
            showingAlert = true
            return
        }

        guard password == confirmPassword else {
            alertMessage = "Lösenorden matchar inte."
            showingAlert = true
            return
        }

        // Implementera registreringslogik här
        // T.ex. spara uppgifter i en databas, och hantera användarautentisering
        alertMessage = "Registrering lyckad!"
        showingAlert = true
    }
}


#Preview {
    SignUpView()
}
