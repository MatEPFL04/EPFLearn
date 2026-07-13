import AuthenticationServices
import SwiftUI

@Observable
class AuthManager: NSObject {
    var userID: String?
    var isSignedIn: Bool { userID != nil }

    override init() {
        super.init()
        // Vérifie si déjà connecté au lancement
        if let saved = UserDefaults.standard.string(forKey: "appleUserID") {
            self.userID = saved
        }
    }

    func handleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
                let id = credential.user
                self.userID = id
                UserDefaults.standard.set(id, forKey: "appleUserID")
            }
        case .failure(let error):
            print("Sign in failed: \(error.localizedDescription)")
        }
    }

    func signOut() {
        userID = nil
        UserDefaults.standard.removeObject(forKey: "appleUserID")
    }
}
