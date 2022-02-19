//
//  PaintTextViewController.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/02/06.
//

import UIKit
import RxSwift

class PaintTextViewController: UIViewController, UITextViewDelegate {
    static let identifier = "paintTextView"
    
    var disposeBag = DisposeBag()
    var completeHandler: ((String) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblVerbs.layer.borderWidth = 1
        lblVerbs.layer.borderColor = lblVerbs.textColor.cgColor
        textArea.layer.borderWidth = 1
        textArea.layer.borderColor = UIColor.black.withAlphaComponent(0.2).cgColor
        textArea.layer.cornerRadius = 10
        
        setupBindings()
    }
    
    /* Binding */
    func setupBindings() {
        textView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        textView.rx.text
            .orEmpty
            .distinctUntilChanged()
            .subscribe(onNext: { changedText in
                self.completeHandler?(changedText)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - InterfaceBuilder Links
    
    @IBOutlet weak var lblVerbs: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    @IBOutlet weak var textArea: UIView!
    @IBOutlet weak var textView: UITextView!
}
