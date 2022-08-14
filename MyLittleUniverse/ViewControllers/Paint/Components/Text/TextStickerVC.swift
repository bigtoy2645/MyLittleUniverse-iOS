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
    var emotion = BehaviorRelay<Emotion>(value: Emotion.empty)
    let isFocused = PublishSubject<Bool>()
    let maxCount = 200
    var completeHandler: ((String) -> ())?
    private let disposeBag = DisposeBag()
    private let placeHolder = "그 때의 상황 또는 나만의 의미를 적어보세요. 꼭 쓰지 않아도 괜찮아요."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblPartOfSpeech.layer.borderWidth = 1
        lblPartOfSpeech.layer.borderColor = lblPartOfSpeech.textColor.cgColor
        textArea.layer.borderWidth = 1
        textArea.layer.borderColor = UIColor.gray300.cgColor
        textArea.layer.cornerRadius = 10
        textView.text = placeHolder
        textView.textColor = .disableGray
        textView.textContainer.maximumNumberOfLines = 0
        
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
            .subscribe(onNext: { _ in
                if !self.textView.isFirstResponder {
                    self.textViewFocusOut()
                }
            })
            .disposed(by: disposeBag)
        
        // 글자 수
        textView.rx.text
            .orEmpty
            .map {
                let count = ($0 == self.placeHolder ? 0 : $0.count)
                return "\(count)/\(self.maxCount)"
            }
            .bind(to: lblCount.rx.text)
            .disposed(by: disposeBag)
        
        // 글자 수 제한
        textView.rx.text.orEmpty
            .scan("") { (previous, new) -> String in
                (new.count <= self.maxCount) ? new : previous
            }
            .bind(to: textView.rx.text)
            .disposed(by: disposeBag)
        
        // TextView Focus
        textView.rx.didBeginEditing
            .subscribe(onNext: {
                self.textArea.layer.borderColor = UIColor.mainBlack.cgColor
                if self.textView.text == self.placeHolder {
                    self.textView.text = ""
                    self.textView.textColor = .mainBlack
                }
                self.isFocused.onNext(true)
            })
            .disposed(by: disposeBag)
        
        // TextView Unfocus
        textView.rx.didEndEditing
            .subscribe(onNext: {
                self.textViewFocusOut()
                self.isFocused.onNext(false)
            })
            .disposed(by: disposeBag)
    }

    /* TextView Focus Out */
    func textViewFocusOut() {
        self.textArea.layer.borderColor = UIColor.gray300.cgColor
        if self.textView.text.isEmpty {
            self.textView.text = self.placeHolder
            self.textView.textColor = .disableGray
        }
        if self.textView.text != self.placeHolder {
            self.completeHandler?(self.textView.text)
        }
    }
    
    func sizeOfString(_ string: String, constrainedToWidth width: Double, font: UIFont) -> CGSize {
        (string as NSString).boundingRect(with: CGSize(width: width, height: Double.infinity),
                                          options: .usesLineFragmentOrigin,
                                          attributes: [NSAttributedString.Key.font: font],
                                          context: nil).size
    }
    
    // MARK: - InterfaceBuilder Links
    
    @IBOutlet weak var lblPartOfSpeech: UILabel!
    @IBOutlet weak var lblWord: UILabel!
    @IBOutlet weak var lblDefinition: UILabel!
    
    @IBOutlet weak var textArea: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var lblCount: UILabel!
}
