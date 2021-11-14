//
//  ViewController.swift
//  MyLittleUniverse
//
//  Created by yurim on 2021/11/09.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnLogin: UIButton!
    
    @IBOutlet weak var txtID: UITextField!
    @IBOutlet weak var txtPwd: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnLogin.layer.cornerRadius = 10
        txtID.layer.cornerRadius = 10
        txtPwd.layer.cornerRadius = 10
        
        lblTitle.attributedText = NSMutableAttributedString(string: "MY\nLITTLE\nUNIVERSE", attributes: nil)
    }
    
    /* Login */
    @IBAction func loginButtonPressed(_ sender: UIButton) {
    }
}

