//
//  NameVC.swift
//  MyLittleUniverse
//
//  Created by yurim on 2021/11/09.
//

import UIKit
import RxSwift
import RxCocoa

class NameVC: UIViewController {
    let length = BehaviorRelay<Int>(value: 0)
    let validation = BehaviorRelay<RegexResult>(value: .ko)
    let isValid = BehaviorRelay<Bool>(value: false)
    
    enum RegexResult: String {
        case ko = "한글만 입력 가능합니다."
        case length = "최대 한글 12글자 이내로 입력 가능합니다."
        case verified = ""
    }
    
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
            return text.utf16.count
        }
        .subscribe(onNext: length.accept(_:))
        .disposed(by: disposeBag)
        
        validation.map { $0 == .verified }
            .subscribe(onNext: isValid.accept(_:))
            .disposed(by: disposeBag)
        
        txtName.rx.text.map { text in
            guard let text = text else { return .verified }
            let lengthValidation = (text.utf16.count > 0 && text.utf16.count <= self.maxLength)
            let regexValidation = self.checkNamePolicy(text: text)
            if !lengthValidation        { return .length }
            else if !regexValidation    { return .ko }
            return .verified
        }
        .subscribe(onNext: validation.accept(_:))
        .disposed(by: disposeBag)
        
        validation.map { $0.rawValue }
            .bind(to: lblError.rx.text)
            .disposed(by: disposeBag)
        
        isValid.map { $0 || self.length.value == 0 }
            .bind(to: lblError.rx.isHidden)
            .disposed(by: disposeBag)
        
        isValid.map {
            if self.length.value == 0 { return .gray300 }
            return $0 ? .black : .errorRed
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
        navigationController?.overrideUserInterfaceStyle = .light
    }
    
    /* 화면 클릭 시 키보드 내림 */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    
    /* 등록된 감정 개수에 따라 다음 화면 표시 */
    private func pushNextVC() {
        let nextViewId: Route.ViewId = Repository.instance.moments.value.isEmpty ? .initVC : .monthlyVC
        let nextVC = Route.getVC(nextViewId)
        self.navigationController?.pushViewController(nextVC, animated: false)
        
        if nextViewId == .monthlyVC {
            // 감정 등록 화면으로 이동
            let registerVC = Route.getVC(.selectStatusVC)
            nextVC.navigationController?.pushViewController(registerVC, animated: false)
        }
    }
    
    /* 정규식 검증 */
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

