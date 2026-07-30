import AuthenticationServices
import SwiftUI

@Observable
class AuthManager: NSObject {
    var userID: String?
    var userEmail: String?
    var userName: String?
    var errorMessage: String?
    var isSignedIn: Bool { userID != nil }

    override init() {
        super.init()
        // Vérifie si déjà connecté au lancement
        if let saved = UserDefaults.standard.string(forKey: "appleUserID") {
            self.userID = saved
            self.userEmail = UserDefaults.standard.string(forKey: "appleUserEmail")
            self.userName = UserDefaults.standard.string(forKey: "appleUserName")
            // Vérifie le statut du credential
            checkCredentialState(userID: saved)
        }
    }

    func handleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
                let id = credential.user
                self.userID = id
                UserDefaults.standard.set(id, forKey: "appleUserID")
                
                // Sauvegarde email (disponible seulement à la première connexion)
                if let email = credential.email {
                    self.userEmail = email
                    UserDefaults.standard.set(email, forKey: "appleUserEmail")
                }
                
                // Sauvegarde nom (disponible seulement à la première connexion)
                if let fullName = credential.fullName {
                    let name = [fullName.givenName, fullName.familyName]
                        .compactMap { $0 }
                        .joined(separator: " ")
                    if !name.isEmpty {
                        self.userName = name
                        UserDefaults.standard.set(name, forKey: "appleUserName")
                    }
                }
                
                self.errorMessage = nil
            }
        case .failure(let error):
            let nsError = error as NSError
            if nsError.code == 1001 { // User canceled
                self.errorMessage = "Sign in canceled"
            } else {
                self.errorMessage = "Sign in failed. Please try again."
            }
            print("⚠️ Sign in failed: \(error.localizedDescription)")
        }
    }
    
    /// Vérifie si le credential Apple est toujours valide
    private func checkCredentialState(userID: String) {
        let provider = ASAuthorizationAppleIDProvider()
        provider.getCredentialState(forUserID: userID) { state, error in
            DispatchQueue.main.async {
                switch state {
                case .authorized:
                    // Le credential est valide
                    break
                case .revoked, .notFound:
                    // L'utilisateur a révoqué l'accès ou le credential n'existe plus
                    self.signOut()
                case .transferred:
                    // Le credential a été transféré (rare)
                    break
                @unknown default:
                    break
                }
            }
        }
    }
    
    func deleteLocalAccount() {
        signOut()
    }

    func signOut() {
        userID = nil
        userEmail = nil
        userName = nil
        errorMessage = nil
        UserDefaults.standard.removeObject(forKey: "appleUserID")
        UserDefaults.standard.removeObject(forKey: "appleUserEmail")
        UserDefaults.standard.removeObject(forKey: "appleUserName")
    }
}
