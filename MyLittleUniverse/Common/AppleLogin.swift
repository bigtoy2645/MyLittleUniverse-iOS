//
//  AppleLogin.swift
//  AlcheraBank
//
//  Created by 김유림 on 2022/09/15.
//

import UIKit
import CryptoKit
import FirebaseAuth
import AuthenticationServices

class AppleLogin: NSObject, ASAuthorizationControllerDelegate {    
    let button = ASAuthorizationAppleIDButton(type: .signIn, style: .white)
    var completion: (() -> Void)? = nil
    
    fileprivate var currentNonce: String?
    
    /* Apple 로그인 버튼 설정 */
    func configure(completion: (() -> Void)?) {
        button.addTarget(self, action: #selector(handleAppleIdRequest), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.cornerRadius = 0
        self.completion = completion
    }
    
    /* Apple 로그인 요청 */
    @objc func handleAppleIdRequest() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        let nonce = randomNonceString()
        currentNonce = nonce
        
        request.requestedScopes = []
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    
    /* Apple 로그인 완료 */
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            self.completion?()
            return
        }
        
        guard let nonce = currentNonce else {
            NSLog("Invalid state: A login callback was received, but no login request was sent.")
            self.completion?()
            return
        }
        guard let appleIDToken = appleCredential.identityToken else {
            NSLog("Unable to fetch identity token")
            self.completion?()
            return
        }
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            NSLog("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
            self.completion?()
            return
        }
        
        // Initialize a Firebase credential.
        let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                  idToken: idTokenString,
                                                  rawNonce: nonce)
        // Sign in with Firebase.
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                NSLog(error.localizedDescription)
                self.completion?()
                return
            }
        }
        
        let userIdentifier = appleCredential.user
        NSLog("Apple login completed. identifier = \(userIdentifier), token = \(idTokenString)")
        
        if let identifierData = userIdentifier.data(using: .utf8) {
            DispatchQueue.global().async {
                Repository.instance.openSession(Session(identifier: identifierData.base64EncodedString())) {
                    self.completion?()
                }
            }
        } else {
            completion?()
        }
    }
    
    /* Nonce 생성 */
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    /* Sha256 */
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}
