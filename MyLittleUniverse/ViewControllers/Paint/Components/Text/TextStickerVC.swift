//
//  PaintTextViewController.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/02/06.
//

import UIKit
import RxSwift
import RxCocoa

class TextStickerVC: UIViewController, UITextViewDelegate {
    static let identifier = "paintTextView"
    
    let maxCount = 40
    var emotion = BehaviorRelay<Emotion>(value: Emotion.empty)
    var disposeBag = DisposeBag()
    var completeHandler: ((String) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblPartOfSpeech.layer.borderWidth = 1
        lblPartOfSpeech.layer.borderColor = lblPartOfSpeech.textColor.cgColor
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
        
        emotion.map { $0.part.rawValue }
            .bind(to: lblPartOfSpeech.rx.text)
            .disposed(by: disposeBag)
        
        emotion.map { $0.origin }
            .bind(to: lblWord.rx.text)
            .disposed(by: disposeBag)
        
        emotion.map { $0.definition }
            .bind(to: lblDefinition
                    .rx.text)
            .disposed(by: disposeBag)
        
        // 글자 입력 시
        textView.rx.text
            .orEmpty
            .distinctUntilChanged()
            .subscribe(onNext: { changedText in
                DispatchQueue.main.async {
                    self.lblCount.text = "\(changedText.count)/\(self.maxCount)"
                }
                self.completeHandler?(changedText)
            })
            .disposed(by: disposeBag)
        
        // 글자 수 제한
        textView.rx.text.orEmpty
            .scan("") { (previous, new) -> String in
                (new.count <= self.maxCount) ? new : previous
            }
            .bind(to: textView.rx.text)
            .disposed(by: disposeBag)
    }
    
    // MARK: - InterfaceBuilder Links
    
    @IBOutlet weak var lblPartOfSpeech: UILabel!
    @IBOutlet weak var lblWord: UILabel!
    @IBOutlet weak var lblDefinition: UILabel!
    
    @IBOutlet weak var textArea: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var lblCount: UILabel!
}
