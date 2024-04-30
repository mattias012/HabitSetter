import Foundation
import FirebaseAuth
import FirebaseFirestore

class UserViewModel: ObservableObject {
    
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var favouriteQoute: String = ""
    @Published var alertMessage: String = ""
    @Published var showingAlert: Bool = false

    var db = Firestore.firestore()

    //register user
    func registerUser(completion: @escaping (Bool) -> Void) {
        guard validateInput() else {
            completion(false) // Om validering misslyckas, returnera omedelbart
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }

            if let error = error {
                DispatchQueue.main.async {
                    self.alertMessage = "Registration failed: \(error.localizedDescription)"
                    self.showingAlert = true
                }
                completion(false)
                return
            }

            guard let uid = authResult?.user.uid else {
                DispatchQueue.main.async {
                    self.alertMessage = "Failed to retrieve user ID."
                    self.showingAlert = true
                }
                completion(false)
                return
            }

            // Skapa användardokument i Firestore och hantera fortsättningen via callback
            self.createUserDocument(uid: uid, completion: completion)
        }
    }

    // Uppdaterad createUserDocument för att inkludera callback
    private func createUserDocument(uid: String, completion: @escaping (Bool) -> Void) {
        let user = User(name: name, email: email, favouriteQoute: favouriteQoute, userId: uid)

        do {
            try db.collection("users").document(uid).setData(from: user) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.alertMessage = "Failed to create user document: \(error.localizedDescription)"
                        self.showingAlert = true
                        completion(false)
                    } else {
                        self.alertMessage = "User successfully registered."
                        self.showingAlert = true
                        completion(true)
                    }
                }
            }
        } catch let error {
            DispatchQueue.main.async {
                self.alertMessage = "Failed to serialize user document: \(error.localizedDescription)"
                self.showingAlert = true
                completion(false)
            }
        }
    }


    //validate data
    private func validateInput() -> Bool {
        guard !email.isEmpty, email.contains("@"), email.contains(".") else {
            alertMessage = "Please enter a valid email address."
            showingAlert = true
            return false
        }

        guard password.count >= 8 else {
            alertMessage = "Password must be at least 8 characters long."
            showingAlert = true
            return false
        }

        guard password == confirmPassword else {
            alertMessage = "Passwords do not match."
            showingAlert = true
            return false
        }

        return true
    }
}
