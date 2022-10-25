//
//  DataManager.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/10/12.
//

import Foundation
import SystemConfiguration

import FirebaseDatabase
import RxSwift
import RxCocoa

class DataManager: NSObject {
    var session: Session?
    private let disposeBag = DisposeBag()
    
    /* 네트워크 체크 */
    static func isNetworkConnected() -> Bool {
        var sockAddress = sockaddr_in()
        sockAddress.sin_len = UInt8(MemoryLayout.size(ofValue: sockAddress))
        sockAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &sockAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    /* 사용자명 불러오기 */
    func loadUserName(completion: ((String?) -> Void)?) {
        guard let session = session else { return }
        
        let ref = Database.database().reference()
        ref.child("users/\(session.identifier)/name").observeSingleEvent(of: .value) { snapshot in
            completion?(snapshot.value as? String)
        }
    }
    
    /// TODO
    /// 총 감정 개수 업데이트 : 추가 :+1, 삭제:-1
    /// 나의 세계 감정들 업데이트 : words/자신하는 +2
    /// 꾸미기/삭제 시 데이터 추가/삭제
    
    /* 감정 정보 불러오기 */
    func loadMoments(month: String, completion: (([Moment]) -> Void)?) {
        guard let session = session else { return }
        
        let ref = Database.database().reference()
        // 단일 응답 크기 제한 : 256MB
        // 단일 쓰기 크기 제한 : 16MB
        ref.child("users/\(session.identifier)/moments/\(month)").observeSingleEvent(of: .value) { snapshot in
            guard let dateValues = snapshot.value as? Dictionary<String, String> else {
                completion?([])
                return
            }
            
            let decoder = JSONDecoder()
            var moments: [Moment] = []

            // moments/202210/timestamp-word
            for jsonString in dateValues.values {
                if let jsonData = jsonString.data(using: .utf8),
                   let momentsData = try? decoder.decode(Moment.self, from: jsonData) {
                    moments.append(momentsData)
                }
            }
            completion?(moments)
        }
    }
    
    /* 총 감정 개수 불러오기 */
    func loadMomentCount(completion: ((Int?) -> Void)?) {
        guard let session = session else { return }
        
        let ref = Database.database().reference()
        ref.child("users/\(session.identifier)/momentCount").observeSingleEvent(of: .value) { snapshot in
            completion?(snapshot.value as? Int)
        }
    }
    
    /* 세션 정보 업데이트 */
    func updateSession(_ session: Session) {
        let ref = Database.database().reference()
        
        let refLoginDate = ref.child("users/\(session.identifier)/lastLogin")
        let lastLoginDate = Date().timeIntervalSinceReferenceDate
        refLoginDate.setValue(lastLoginDate)
        self.session = session
    }
    
    /* 사용자명 업데이트 */
    func updateUserName(_ name: String) {
        guard let session = session else { return }
        
        let ref = Database.database().reference()
        let refUser = ref.child("users/\(session.identifier)/name")
        refUser.setValue(name)
    }
    
    /* 감정 정보 업데이트 */
    func updateMoments(_ moments: [Moment]) {
        guard let session = session else { return }
        
        let ref = Database.database().reference()
        let encoder = JSONEncoder()
        
        for moment in moments {
            if let jsonData = try? encoder.encode(moment),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                let yearMonth = String(format: "%04d%02d", moment.year, moment.month)
                let momentPath = "users/\(session.identifier)/moments/\(yearMonth)/\(Int(moment.timeStamp))-\(moment.emotion.word)"
                let refMoments = ref.child(momentPath)
                refMoments.setValue(jsonString)
            }
        }
    }
}
