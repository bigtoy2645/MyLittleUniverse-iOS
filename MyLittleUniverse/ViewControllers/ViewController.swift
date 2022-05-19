//
//  ViewController.swift
//  MyLittleUniverse
//
//  Created by yurim on 2021/11/09.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    let length = BehaviorRelay<Int>(value: 0)
    let isValid = BehaviorRelay<Bool>(value: false)
    
    private let maxLength = 12
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnStart.layer.cornerRadius = 4
        
        if !Repository.instance.userName.isEmpty { pushNextVC() }
        
        setupBindings()
    }
    
    /* Binding */
    func setupBindings() {
        txtName.rx.text.map { text in
            guard let text = text else { return 0 }
            return text.count
        }
        .subscribe(onNext: length.accept(_:))
        .disposed(by: disposeBag)
        
        txtName.rx.text.map { text in
            guard let text = text else { return true }
            let lengthValidation = (text.count > 0 && text.count <= self.maxLength)
            let regexValidation = self.checkNamePolicy(text: text)
            return lengthValidation && regexValidation
        }
            .subscribe(onNext: isValid.accept(_:))
            .disposed(by: disposeBag)
        
        length.map { self.isValid.value || $0 == 0 }
            .bind(to: lblError.rx.isHidden)
            .disposed(by: disposeBag)
        
        length.map {
            if $0 == 0 { return UIColor(rgb: 0xC4C4C4) }
            return self.isValid.value ? .black : .errorRed
        }
        .bind(to: underLineView.rx.backgroundColor)
        .disposed(by: disposeBag)
        
        // 시작 버튼 활성화
        isValid
            .bind(to: btnStart.rx.isEnabled)
            .disposed(by: disposeBag)
        
        // 시작 버튼 색상
        isValid
            .map { $0 ? .bgGreen : UIColor(rgb: 0xBDC5C0) }
            .bind(to: btnStart.rx.backgroundColor)
            .disposed(by: disposeBag)
        
        // 시작 라벨 색상
        isValid
            .map { $0 ? .pointPurple : .white }
            .bind(to: lblStart.rx.textColor)
            .disposed(by: disposeBag)
        
        btnStart.rx.tap
            .bind {
                guard let name = self.txtName.text else { return }
                Repository.instance.register(userName: name)
                self.pushNextVC()
            }
            .disposed(by: disposeBag)
        
        btnClose.rx.tap
            .bind {
                guard let alertVC = Route.getVC(.alertVC) as? AlertVC else { return }
                
                alertVC.modalPresentationStyle = .overFullScreen
                let alert = Alert(title: "정말로 종료하시겠어요?",
                                  runButtonTitle: "종료",
                                  cancelButtonTitle: "취소")
                alertVC.vm.alert.accept(alert)
                alertVC.addCancelButton() { self.dismiss(animated: false) }
                alertVC.addRunButton(color: UIColor.errorRed) {
                    self.dismiss(animated: false)
                    UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { exit(0) }
                }
                
                self.present(alertVC, animated: false)
            }
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.overrideUserInterfaceStyle = .dark
    }
    
    private func pushNextVC() {
        let nextViewId: Route.ViewId = Repository.instance.moments.value.isEmpty ? .initVC : .monthlyVC
        let nextVC = Route.getVC(nextViewId)
        self.navigationController?.pushViewController(nextVC, animated: false)
    }
    
    private func checkNamePolicy(text: String) -> Bool {
        let arr = Array(text)
        let pattern = "^[가-힣ㄱ-ㅎㅏ-ㅣ]$"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else { return true }
        
        for index in 0..<arr.count {
            let results = regex.matches(in: String(arr[index]), options: [], range: NSRange(location: 0, length: 1))
            if results.count == 0 { return false }
        }
        return true
    }
    
    // MARK: - InterfaceBuilder Links
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var underLineView: UIView!
    @IBOutlet weak var lblError: UILabel!
    
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var lblStart: UILabel!
}

