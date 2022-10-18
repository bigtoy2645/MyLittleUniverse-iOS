//
//  DataManager.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/10/12.
//

import Foundation
import FirebaseDatabase
import RxSwift
import RxCocoa

class DataManager: NSObject {
    var session: Session?
    private let disposeBag = DisposeBag()
    
    /* 사용자명 불러오기 */
    func loadUserName(completion: ((String?) -> Void)?) {
        guard let session = session else { return }
        
        let ref = Database.database().reference()
        ref.child("users/\(session.identifier)/name").observeSingleEvent(of: .value) { snapshot in
            completion?(snapshot.value as? String)
        }
    }
    
    /* 감정 정보 불러오기 */
    func loadMoments(completion: (([Moment]) -> Void)?) {
        guard let session = session else { return }
        
        let ref = Database.database().reference()
        // 단일 응답 크기 제한 : 256MB
        // 단일 쓰기 크기 제한 : 16MB
        ref.child("users/\(session.identifier)/moments").observeSingleEvent(of: .value) { snapshot in
            guard let dateValues = snapshot.value as? [String: Dictionary<String, String>] else {
                completion?([])
                return
            }
            
            let decoder = JSONDecoder()
            var moments: [Moment] = []

            // moments/202210/timestamp
            for dateValue in dateValues.values {
                for jsonString in dateValue.values {
                    if let jsonData = jsonString.data(using: .utf8),
                       let momentsData = try? decoder.decode(Moment.self, from: jsonData) {
                        moments.append(momentsData)
                    }
                }
            }
            completion?(moments)
        }
    }
    
    /* 세션 정보 업데이트 */
    func updateSession(_ session: Session) {
        let ref = Database.database().reference()
        
        let refLoginDate = ref.child("users/\(session.identifier)/lastLogin")
        let lastLoginDate = Date().timeIntervalSinceReferenceDate
        refLoginDate.setValue(lastLoginDate)
        
        if let email = session.email {
            let refUser = ref.child("users/\(session.identifier)/email")
            refUser.setValue(email)
        }
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
                let momentPath = "users/\(session.identifier)/moments/\(yearMonth)/\(Int(moment.timeStamp))"
                let refMoments = ref.child(momentPath)
                refMoments.setValue(jsonString)
            }
        }
    }
}
