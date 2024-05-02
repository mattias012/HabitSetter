//
//  SignInView.swift
//  HabitSetter
//
//  Created by Mattias Axelsson on 2024-04-22.
//

import SwiftUI
import Firebase

struct SignInView : View {
    
    @Binding var signedIn : Bool //Bind the state from content view since we need to update it soon
    @Binding var isLoading: Bool
    var auth = Auth.auth()
    
    @State private var email: String = ""
    @State private var password: String = ""
    @FocusState private var isEmailFocused: Bool
    @FocusState private var isPasswordFocused: Bool
    
    @State private var showingSignUp = false  //State to show SignUp Sheet
    
    var body: some View {
        
        VStack {
            HStack {
                    Spacer() // Skjuter allt till höger
                    Button("Sign up") {
                        showingSignUp = true
                    }
                    .padding()
                    .foregroundColor(Color.blue)
                }
            Spacer()
            
            Text("Welcome, please sign in")
                .font(.title)
                .padding(.bottom, 20)
            
            VStack(spacing: 16) {
                TextField("Email", text: $email)
                    .focused($isEmailFocused)
                    .padding(.horizontal)
                    .frame(height: 50)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                
                SecureField("Password", text: $password)
                    .focused($isPasswordFocused)
                    .padding(.horizontal)
                    .frame(height: 50)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Button(action: signIn) {
                
                //set a hstack to sort image and text
                HStack {
                    Text("Sign in")
                    Image(systemName: "arrow.right")
                }
            }
            //Styles for the button
            .padding()
            .frame(height: 50)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.top, 20)
            
            Spacer()
        }
        .padding()
        
        .sheet(isPresented: $showingSignUp) {
            SignUpView(signedIn: $signedIn, isLoading: $isLoading, showingSignUp: $showingSignUp)
                         //lets sign up then..
        }
               
//        .onAppear {
//            if Auth.auth().currentUser != nil {
//                signedIn = true
//            }
//        }
        
    }
    
    
    private func signIn() {
        isLoading = true  // load progressview
        auth.signIn(withEmail: email, password: password) { result, error in
            isLoading = false  //hide progress view
            if let error = error {
                
            } else {
                signedIn = true
                SessionManager.shared.currentUserId = auth.currentUser?.uid
            }
        }
    }
    
}
#Preview {
    SignInView(signedIn: .constant(false), isLoading: .constant(false))
}
