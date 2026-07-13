import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @Environment(AuthManager.self) private var auth

    var body: some View {
        VStack(spacing: 20) {
            Text("EPFLearn")
                .font(.largeTitle.bold())

            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.fullName]
            } onCompletion: { result in
                auth.handleSignIn(result)
            }
            .signInWithAppleButtonStyle(.black)
            .frame(height: 50)
            .padding(.horizontal, 40)
        }
    }
}
