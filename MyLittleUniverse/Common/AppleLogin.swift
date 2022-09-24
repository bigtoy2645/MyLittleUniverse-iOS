//
//  AppleLogin.swift
//  AlcheraBank
//
//  Created by 김유림 on 2022/09/15.
//

import UIKit
import AuthenticationServices

class AppleLogin: NSObject, ASAuthorizationControllerDelegate {
    static var session: Session?
    
    let button = ASAuthorizationAppleIDButton(type: .signIn, style: .whiteOutline)
    var completion: (() -> Void)? = nil
    
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
        request.requestedScopes = [.email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    
    /* Apple 로그인 정보 저장 */
    func saveAppleLogin(identifier: String, email: String) {
        // ID 변경 > 계정 변경 > ID,이메일 업데이트
        // ID 동일 > 이메일 가리기/보이기에 의한 변동 > 이메일 업데이트
//        let oldIdentifier = UserDefaults.standard.value(forKey: DefaultsKey.appleId) as? String ?? ""
//        if identifier != oldIdentifier {
//            UserDefaults.standard.setValue(identifier, forKey: DefaultsKey.appleId)
//            UserDefaults.standard.setValue(email, forKey: DefaultsKey.appleEmail)
//        } else {
//            UserDefaults.standard.setValue(email, forKey: DefaultsKey.appleEmail)
//        }
//
//        Session.identifier = identifier
//        Session.email = email
    }
    
    /* Apple 로그인 완료 */
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as?  ASAuthorizationAppleIDCredential else { return }
        
        let userIdentifier = credential.user
        var email = credential.email
        
        NSLog("Apple login completed. identifier = \(userIdentifier), email = \(email ?? ""))")
        
//        if let credentialEmail = credential.email {
//            UserDefaults.standard.setValue(credentialEmail, forKey: DefaultsKey.appleEmail)
//            email = credentialEmail
//        } else {
//            email = UserDefaults.standard.value(forKey: DefaultsKey.appleEmail) as? String
//        }
        
        saveAppleLogin(identifier: userIdentifier, email: email ?? "")
        
        completion?()
    }
}
