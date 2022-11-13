//
//  Repository.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/05/07.
//

import Foundation
import RxSwift
import RxCocoa
import FirebaseAuth

class Repository: NSObject {
    static let instance = Repository()
    
    public private(set) var userName: String = ""
    public private(set) var momentsCount = BehaviorRelay<Int>(value: 0)
    public private(set) var moments = BehaviorRelay<[Moment]>(value: [])
    public private(set) var monthlyMoments = BehaviorRelay<[Moment]>(value: [])
    public private(set) var session = BehaviorRelay<Session?>(value: nil)
    
    public private(set) var isEmpty = BehaviorRelay<Bool>(value: true)
    public private(set) var isMonthEmpty = BehaviorRelay<Bool>(value: true)
    public private(set) var isLogin = BehaviorRelay<Bool>(value: false)
    
    let db = DataManager()
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
                if !$0.name.isEmpty {
                    self?.db.updateUserName($0.name)
                }
            })
            .disposed(by: disposeBag)
        
        _ = moments
            .subscribe(onNext: { [weak self] in
                self?.saveData(data: $0, key: Key.moments.rawValue)
            })
            .disposed(by: disposeBag)
        
        momentsCount.map { $0 == 0 }
            .subscribe(onNext: isEmpty.accept(_:))
            .disposed(by: disposeBag)
        
        moments
            .map {
                let date = Date()
                return $0.filter({ ($0.year == date.year) && ($0.month == date.month) })
            }
            .subscribe(onNext: monthlyMoments.accept(_:))
            .disposed(by: disposeBag)
        
        monthlyMoments
            .map { $0.isEmpty }
            .subscribe(onNext: isMonthEmpty.accept(_:))
            .disposed(by: disposeBag)
        
        _ = momentsCount
            .subscribe(onNext: {
                UserDefaults.standard.setValue($0, forKey: Key.momentsCount.rawValue)
            })
            .disposed(by: disposeBag)
        
        // 세션 정보 변경 시 DB에 정보 업데이트 및 불러오기
        session
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                self.saveData(data: $0, key: Key.session.rawValue)
            })
            .disposed(by: disposeBag)
    }
    
    /* 감정 추가 */
    func add(moment: Moment, completion: ((Bool) -> Void)?) {
        db.addMoment(moment) { result in
            if result {
                self.momentsCount.accept(self.momentsCount.value + 1)
                var newMoments = self.moments.value
                if let momentIndex = newMoments.firstIndex(of: moment) {
                    newMoments[momentIndex] = moment
                } else {
                    newMoments.append(moment)
                }
                self.moments.accept(newMoments)
            }
            completion?(result)
        }
    }
    
    /* 감정 삭제 */
    func remove(moment: Moment, completion: ((Bool) -> Void)?) {
        db.removeMoment(moment) { result in
            if result {
                self.momentsCount.accept(self.momentsCount.value - 1)
                var newMoments = self.moments.value
                newMoments = newMoments.filter { $0 != moment }
                self.moments.accept(newMoments)
            }
            completion?(result)
        }
    }
    
    /* 사용자 이름 등록 */
    func register(userName: String) {
        user.accept(User(name: userName))
    }
    
    /* 로그인 */
    func openSession(_ session: Session, completion: (() -> Void)?) {
        db.updateSession(session)
        self.session.accept(session)
        
        let group = DispatchGroup()
        // 감정, 사용자명 불러올 때까지 대기
        // 이 달 감정 불러오기
        group.enter()
        db.loadMomentCount { count in
            if count == 0 { // UserDefaults 정보 있을 경우 업데이트
                self.moments.value.forEach { self.db.addMoment($0) }
                self.momentsCount.accept(self.moments.value.count)
                group.leave()
            } else if count != self.momentsCount.value {
                let date = Date()
                self.momentsCount.accept(count)
                self.db.loadMoments(year: date.year, month: date.month) { moments in
                    var newMoments = self.moments.value.filter { ($0.year != date.year) || ($0.month != date.month) }
                    newMoments.append(contentsOf: moments)
                    self.moments.accept(newMoments)
                    group.leave()
                }
            } else {
                group.leave()
            }
        }
        
        // 사용자명 불러오기
        group.enter()
        db.loadUserName { userName in
            if let userName = userName, self.userName != userName {
                self.user.accept(User(name: userName))
            } else {
                // UserDefaults 정보 있을 경우 업데이트
                if !self.userName.isEmpty {
                    self.db.updateUserName(self.userName)
                }
            }
            group.leave()
        }
        
        // 대기
        if completion != nil {
            _ = group.wait(timeout: .now() + 10)
            completion?()
        }
    }
    
    /* 로그아웃 */
    func closeSession() {
        user.accept(User(name: ""))
        moments.accept([])
        session.accept(nil)
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    // MARK: - UserDefaults Data Processing
    
    enum Key: String {
        case user = "User"
        case moments = "Moments"
        case momentsCount = "MomentsCount"
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
                DispatchQueue.global().async {
                    self.openSession(userData, completion: nil)
                }
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
        // 감정 개수
        if let momentsCountValue = userDefaults.value(forKey: Key.momentsCount.rawValue) as? Int {
            momentsCount.accept(momentsCountValue)
        } else {
            momentsCount.accept(moments.value.count)
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
