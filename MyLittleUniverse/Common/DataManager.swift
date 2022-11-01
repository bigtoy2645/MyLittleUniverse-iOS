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
    
    /* Database Reference */
    func refChild() -> DatabaseReference? {
        guard let session = session else { return nil }
        
        let ref = Database.database().reference()
        return ref.child("users/\(session.identifier)")
    }
    
    /* Database Reference */
    func refChild(_ subPath: String) -> DatabaseReference? {
        guard let session = session else { return nil }
        
        let ref = Database.database().reference()
        return ref.child("users/\(session.identifier)/\(subPath)")
    }
    
    /* Moment Reference 경로 */
    func childPath(moment: Moment) -> String {
        let yearMonth = String(format: "%04d%02d", moment.year, moment.month)
        return "moments/\(yearMonth)/\(Int(moment.timeStamp))-\(moment.emotion.word)"
    }
    
    /* 사용자명 불러오기 */
    func loadUserName(completion: ((String?) -> Void)?) {
        refChild("name")?.observeSingleEvent(of: .value) { snapshot in
            completion?(snapshot.value as? String)
        }
    }
    
    /* 감정 정보 불러오기 */
    func loadMoments(year: Int, month: Int, completion: (([Moment]) -> Void)?) {
        // 단일 응답 크기 제한 : 256MB
        // 단일 쓰기 크기 제한 : 16MB
        let yearMonth = String(format: "%04d%02d", year, month)
        refChild("moments/\(yearMonth)")?.observeSingleEvent(of: .value) { snapshot in
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
    func loadMomentCount(completion: ((Int) -> Void)?) {
        refChild("momentCount")?.observeSingleEvent(of: .value) { snapshot in
            completion?(snapshot.value as? Int ?? 0)
        }
    }
    
    /* 감정 종류 불러오기 */
    func loadWordList(completion: (([String]) -> Void)?) {
        refChild("words")?.observeSingleEvent(of: .value) { snapshot in
            guard let wordValues = snapshot.value as? Dictionary<String, Int> else {
                completion?([])
                return
            }
            
            var words: [String] = []
            for word in wordValues {
                if word.value > 0 { words.append(word.key) }
            }
            completion?(words)
        }
    }
    
    /* 감정 개수 불러오기 */
    func loadWordCount(_ word: String, completion: ((Int) -> Void)?) {
        refChild("words/\(word)")?.observeSingleEvent(of: .value) { snapshot in
            completion?(snapshot.value as? Int ?? 0)
        }
    }
    
    /* 세션 정보 업데이트 */
    func updateSession(_ session: Session?) {
        self.session = session
        if let refLoginDate = refChild("lastLogin"), session != nil {
            let lastLoginDate = Date().timeIntervalSinceReferenceDate
            refLoginDate.setValue(lastLoginDate)
        }
    }
    
    /* 사용자명 업데이트 */
    func updateUserName(_ name: String) {
        refChild("name")?.setValue(name)
    }
    
    /* 감정 추가 */
    func addMoment(_ moment: Moment, completion: ((Bool) -> Void)? = nil) {
        guard let ref = refChild(),
              let jsonString = moment.jsonString() else {
            completion?(false)
            return
        }
        
        let word = moment.emotion.word
        let momentKey = childPath(moment: moment)
        
        let updates = [
          "words/\(word)": ServerValue.increment(1),    // 단어
          "momentCount": ServerValue.increment(1),      // 감정 총 개수
          momentKey: jsonString,                        // 감정
        ] as [String : Any]
        
        ref.updateChildValues(updates) { error, _ in
            completion?(error == nil)
        }
    }
    
    /* 감정 삭제 */
    func removeMoment(_ moment: Moment, completion: ((Bool) -> Void)? = nil) {
        guard let ref = refChild() else { return }
        
        let word = moment.emotion.word
        let momentKey = childPath(moment: moment)
        
        let updates = [
          "words/\(word)": ServerValue.increment(-1),   // 단어
          "momentCount": ServerValue.increment(-1),     // 감정 총 개수
          momentKey: NSNull(),                          // 감정
        ] as [String : Any]
        
        ref.updateChildValues(updates) { error, _ in
            completion?(error == nil)
        }
    }
}
