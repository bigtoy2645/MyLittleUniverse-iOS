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
    
    private var user = BehaviorRelay<User>(value: User(name: ""))
    private let disposeBag = DisposeBag()
    
    override init() {
        super.init()
        
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
    
    enum Key: String {
        case user = "User"
        case moments = "Moments"
    }
    
    // MARK: - Data Processing
    
    /* 데이터 불러오기 */
    private func loadData() {
        let userDefaults = UserDefaults.standard
        let decoder = JSONDecoder()
        
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
