//
//  AppleLogin.swift
//  AlcheraBank
//
//  Created by 김유림 on 2022/09/15.
//

import UIKit
import AuthenticationServices

class AppleLogin: NSObject, ASAuthorizationControllerDelegate {    
    let button = ASAuthorizationAppleIDButton(type: .signIn, style: .white)
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
        request.requestedScopes = []
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    
    /* Apple 로그인 완료 */
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
        
        let userIdentifier = credential.user
        
        NSLog("Apple login completed. identifier = \(userIdentifier)")
        
        if let identifierData = userIdentifier.data(using: .utf8) {
            Repository.instance.openSession(Session(identifier: identifierData.base64EncodedString()))
        }
        
        completion?()
    }
}
