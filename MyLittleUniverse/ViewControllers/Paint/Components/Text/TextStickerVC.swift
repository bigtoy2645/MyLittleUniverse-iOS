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
    let maxCount = 40
    var completeHandler: ((String) -> ())?
    private let disposeBag = DisposeBag()
    private let placeHolder = "감정을 만났던 상황 또는 나만의 감정 의미를 적어보세요."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblPartOfSpeech.layer.borderWidth = 1
        lblPartOfSpeech.layer.borderColor = lblPartOfSpeech.textColor.cgColor
        textArea.layer.borderWidth = 1
        textArea.layer.borderColor = UIColor.gray300.cgColor
        textArea.layer.cornerRadius = 10
        textView.text = placeHolder
        textView.textColor = .disableGray
        textView.textContainer.maximumNumberOfLines = 2
        
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
                if changedText != self.placeHolder {
                    self.completeHandler?(changedText)
                }
            })
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
            })
            .disposed(by: disposeBag)
        
        // TextView Unfocus
        textView.rx.didEndEditing
            .subscribe(onNext: {
                self.textArea.layer.borderColor = UIColor.gray300.cgColor
                if self.textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    self.textView.text = self.placeHolder
                    self.textView.textColor = .disableGray
                }
            })
            .disposed(by: disposeBag)
    }
    
    func sizeOfString(_ string: String, constrainedToWidth width: Double, font: UIFont) -> CGSize {
        (string as NSString).boundingRect(with: CGSize(width: width, height: Double.infinity),
                                          options: .usesLineFragmentOrigin,
                                          attributes: [NSAttributedString.Key.font: font],
                                          context: nil).size
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        var textWidth = textView.frame.inset(by: textView.textContainerInset).width
        textWidth -= 2.0 * textView.textContainer.lineFragmentPadding
        
        let boundingRect = sizeOfString(newText, constrainedToWidth: Double(textWidth), font: textView.font!)
        let numberOfLines = boundingRect.height / textView.font!.lineHeight;

        return numberOfLines <= 2
    }
    
    // MARK: - InterfaceBuilder Links
    
    @IBOutlet weak var lblPartOfSpeech: UILabel!
    @IBOutlet weak var lblWord: UILabel!
    @IBOutlet weak var lblDefinition: UILabel!
    
    @IBOutlet weak var textArea: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var lblCount: UILabel!
}
