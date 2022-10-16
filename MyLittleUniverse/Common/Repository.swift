//
//  Repository.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/05/07.
//

import Foundation
import RxSwift
import RxCocoa

class Repository: NSObject {
    static let instance = Repository()
    
    public private(set) var userName: String = ""
    public private(set) var moments = BehaviorRelay<[Moment]>(value: [])
    
    public private(set) var isEmpty = BehaviorRelay<Bool>(value: true)
    public private(set) var isMonthEmpty = BehaviorRelay<Bool>(value: true)
    public private(set) var isLogin = BehaviorRelay<Bool>(value: false)
    
    private let session = BehaviorRelay<Session?>(value: nil)
    private let db = DataManager()
    private var user = BehaviorRelay<User>(value: User(name: ""))
    private let disposeBag = DisposeBag()
    
    override init() {
        super.init()
        
        session
            .map { $0 != nil }
            .subscribe(onNext: isLogin.accept(_:))
            .disposed(by: disposeBag)
        
        // 데이터 불러오기
        loadData()
        
        // 데이터 갱신 시 저장
        _ = user
            .subscribe(onNext: { [weak self] in
                self?.saveData(data: $0, key: Key.user.rawValue)
                self?.userName = $0.name
            })
            .disposed(by: disposeBag)
        
        _ = moments
            .subscribe(onNext: { [weak self] in
                self?.saveData(data: $0, key: Key.moments.rawValue)
            })
            .disposed(by: disposeBag)
        
        moments.map { $0.isEmpty }
            .subscribe(onNext: isEmpty.accept(_:))
            .disposed(by: disposeBag)
        
        moments
            .map {
                let date = Date()
                return $0.filter({ ($0.year == date.year) && ($0.month == date.month) }).isEmpty
            }
            .subscribe(onNext: isMonthEmpty.accept(_:))
            .disposed(by: disposeBag)
        
        // 세션 정보 변경 시 DB에 정보 업데이트 및 불러오기
        session
            .subscribe(onNext: { [weak self] in
                self?.saveData(data: $0, key: Key.session.rawValue)
            })
            .disposed(by: disposeBag)
    }
    
    /* 감정 추가 */
    func add(moment: Moment) {
        var newMoments = moments.value
        if let momentIndex = newMoments.firstIndex(of: moment) {
            newMoments[momentIndex] = moment
        } else {
            newMoments.append(moment)
        }
        moments.accept(newMoments)
    }
    
    /* 감정 삭제 */
    func remove(moment: Moment) {
        var newMoments = moments.value
        newMoments = newMoments.filter { $0 != moment }
        moments.accept(newMoments)
    }
    
    /* 사용자 이름 등록 */
    func register(userName: String) {
        user.accept(User(name: userName))
    }
    
    /* 로그인 */
    func openSession(_ session: Session) {
        self.session.accept(session)
        
        db.updateSession(session)
        db.loadMoments { moments in
            if moments.isEmpty {
                // UserDefaults 정보 있을 경우 업데이트
                if !self.moments.value.isEmpty {
                    self.db.updateMoments(self.moments.value)
                }
            } else {
                self.moments.accept(moments)
            }
        }
        
        db.loadUserName { userName in
            if let userName = userName {
                self.user.accept(User(name: userName))
            } else {
                // UserDefaults 정보 있을 경우 업데이트
                if !self.userName.isEmpty {
                    self.db.updateUserName(self.userName)
                }
            }
        }
    }
    
    /* 로그아웃 */
    func closeSession() {
        //user.accept(User(name: ""))
        //moments.accept([])
        session.accept(nil)
    }
    
    // MARK: - UserDefaults Data Processing
    
    enum Key: String {
        case user = "User"
        case moments = "Moments"
        case session = "Session"
    }
    
    /* 데이터 불러오기 */
    private func loadData() {
        let userDefaults = UserDefaults.standard
        let decoder = JSONDecoder()
        
        // 세션
        if let jsonString = userDefaults.value(forKey: Key.session.rawValue) as? String {
            if let jsonData = jsonString.data(using: .utf8),
               let userData = try? decoder.decode(Session.self, from: jsonData) {
                session.accept(userData)
            }
        }
        // 닉네임
        if let jsonString = userDefaults.value(forKey: Key.user.rawValue) as? String {
            if let jsonData = jsonString.data(using: .utf8),
               let userData = try? decoder.decode(User.self, from: jsonData) {
                user.accept(userData)
            }
        }
        // 감정
        if let jsonString = userDefaults.value(forKey: Key.moments.rawValue) as? String {
            if let jsonData = jsonString.data(using: .utf8),
               let momentsData = try? decoder.decode([Moment].self, from: jsonData) {
                moments.accept(momentsData)
            }
        }
    }
    
    /* 데이터 저장하기 */
    private func saveData<T: Encodable>(data: T, key: String) {
        let userDefaults = UserDefaults.standard
        let encoder = JSONEncoder()
        
        if let jsonData = try? encoder.encode(data) {
            if let jsonString = String(data: jsonData, encoding: .utf8){
                userDefaults.set(jsonString, forKey: key)
            }
        }
        // 동기화
        userDefaults.synchronize()
    }
}
