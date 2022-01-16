//
//  ViewController.swift
//  MyLittleUniverse
//
//  Created by yurim on 2021/11/09.
//

import UIKit
import Firebase
import GoogleSignIn
import RxSwift

class ViewController: UIViewController {
    
    var token: String?
    let signInConfig = GIDConfiguration.init(clientID: "473547658230-7hsfeljikdbaqv1u5o39a0vmc1skl1uf.apps.googleusercontent.com")
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnLogin.layer.cornerRadius = 10
        txtID.layer.cornerRadius = 10
        txtPwd.layer.cornerRadius = 10
        
        lblTitle.attributedText = NSMutableAttributedString(string: "MY\nLITTLE\nUNIVERSE", attributes: nil)
        
        // Login
        btnLogin.rx.tap
            .bind {
//                guard self.token != nil else { return }
                guard let homeVC = self.storyboard?.instantiateViewController(withIdentifier: HomeViewController.storyboardID) else { return }
                
                homeVC.modalPresentationStyle = .fullScreen
                self.present(homeVC, animated: false)
            }
            .disposed(by: disposeBag)
    }
    
    /* Google Login */
    @IBAction func googleLoginButtonPressed(_ sender: Any) {
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
            guard error == nil else { return }
            guard let user = user else { return }
            
            user.authentication.do { authentication, error in
                if let errorDescription = error?.localizedDescription {
                    NSLog("Google login failed. Error = \(errorDescription)")
                    return
                }
                guard let authentication = authentication,
                      let token = authentication.idToken else { return }
                
                NSLog("Google login completed. Token = \(token)")
                self.token = token
            }
        }
    }
    
    // MARK: - InterfaceBuilder Links
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnGoogleLogin: GIDSignInButton!
    
    @IBOutlet weak var txtID: UITextField!
    @IBOutlet weak var txtPwd: UITextField!
}

