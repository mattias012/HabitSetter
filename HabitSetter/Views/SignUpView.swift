import SwiftUI

struct SignUpView: View {
    @ObservedObject var userViewModel = UserViewModel() //init our UserViewModel
    
    
    @Binding var signedIn: Bool //this state is from signinview..
    @Binding var isLoading: Bool //thuis as well
    @Environment(\.presentationMode) var presentationMode
    @Binding var showingSignUp: Bool  //to close the sheet displayed
    
    @State private var showingAlert: Bool = false
    @State private var alertMessage: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Create account")
                    .font(.largeTitle)

                TextField("E-mail", text: $userViewModel.email) //bind in ViewModel
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)

                SecureField("Password", text: $userViewModel.password) //bind in ViewModel
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)

                SecureField("Confirm password", text: $userViewModel.confirmPassword) //bind in iewModel
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                
                TextField("Your Favourite Quote", text: $userViewModel.favouriteQoute) //bind in ViewModel
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)

                Button("Sign up") {
                    userViewModel.registerUser { success in
                        if success {
                            // Stäng SignUpView
                            DispatchQueue.main.async {
                                presentationMode.wrappedValue.dismiss()
                                showingSignUp = false
//                                signedIn = true
                            }
                            
                            // Eftersom användaren redan är inloggad efter en framgångsrik registrering
                            // Vi uppdaterar bara `signedIn` och `isLoading`
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                // Lägg till en liten fördröjning om du vill visa progressbaren i några ögonblick
                                isLoading = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    isLoading = false
                                    signedIn = true  // Denna bör uppdatera huvudvyn att visa ContentView
                                }
                            }
                        } else {
                            showingAlert = userViewModel.showingAlert
                            alertMessage = userViewModel.alertMessage
                        }
                    }
                }

                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)

                Spacer()
            }
            .padding()
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Sign Up"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}

//struct SignUpView_Previews: PreviewProvider {
//    static var previews: some View {
//        SignUpView()
//    }
//}
