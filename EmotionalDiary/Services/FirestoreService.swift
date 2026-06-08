//
//  FirestoreService.swift
//  EmotionalDiary
//
//  Created by 김완수 on 5/11/26.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

final class FirestoreService {

    static let shared = FirestoreService()
    private init() {}

    private let db = Firestore.firestore()

    // 데이터 저장
    func addEmotionRecord(record: EmotionRecord,completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(
                domain: "Auth",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "로그인된 사용자가 없습니다."]
            )))
            return
        }

        let data: [String: Any] = [
            "emotion": record.emotion.rawValue,              // happy, sad, stress
            "emotionTitle": record.emotion.title,            // 행복, 슬픔, 스트레스
            "emotionImageName": record.emotion.imageName,    // happy.png

            "situation": record.situation.rawValue,          // 과제, 공부 등

            "energy": record.energy.rawValue,                // high, medium, low
            "energyTitle": record.energy.title,              // 높음, 중간, 낮음

            "intensity": record.intensity,

            "socialContext": record.socialContext.rawValue,  // alone, friends
            "socialContextTitle": record.socialContext.title, // 혼자, 친구

            "timeSlot": record.timeSlot.rawValue,            // morning, night
            "timeSlotTitle": record.timeSlot.saveTitle,          // 아침, 밤
            "timeSlotOrder": record.timeSlot.order,          // 0, 1

            "memo": record.memo,

            "recordDate": record.recordDate,                 // 2026-05-15
            "yearMonth": record.yearMonth,                   // 2026-05

            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ]

        db.collection("users")
            .document(uid)
            .collection("emotionRecords")
            .addDocument(data: data) { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                completion(.success(()))
            }
    }
    
    // 데이터 읽기
    func fetchEmotionRecords(recordDate: String, completion: @escaping (Result<[EmotionRecord], Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(
                domain: "Auth",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "로그인된 사용자가 없습니다."]
            )))
            return
        }

        db.collection("users")
            .document(uid)
            .collection("emotionRecords")
            .whereField("recordDate", isEqualTo: recordDate)
            .order(by: "timeSlotOrder", descending: false)
            .order(by: "createdAt", descending: false)
            .getDocuments { snapshot, error in

                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }

                let records: [EmotionRecord] = documents.compactMap { document -> EmotionRecord? in

                    let data = document.data()

                    guard
                        let emotionRaw = data["emotion"] as? String,
                        let situationRaw = data["situation"] as? String,
                        let energyRaw = data["energy"] as? String,
                        let intensity = data["intensity"] as? Int,
                        let socialContextRaw = data["socialContext"] as? String,
                        let timeSlotRaw = data["timeSlot"] as? String,
                        let memo = data["memo"] as? String,
                        let recordDate = data["recordDate"] as? String,
                        let yearMonth = data["yearMonth"] as? String,

                        let emotion = Emotion(rawValue: emotionRaw),
                        let situation = Situation(rawValue: situationRaw),
                        let energy = Energy(rawValue: energyRaw),
                        let socialContext = SocialContext(rawValue: socialContextRaw),
                        let timeSlot = TimeSlot(rawValue: timeSlotRaw)

                    else {
                        return nil
                    }

                    return EmotionRecord(
                        id: document.documentID,
                        emotion: emotion,
                        situation: situation,
                        energy: energy,
                        intensity: intensity,
                        socialContext: socialContext,
                        timeSlot: timeSlot,
                        memo: memo,
                        recordDate: recordDate,
                        yearMonth: yearMonth
                    )
                }

                completion(.success(records))
            }
    }
    
    func fetchRecentEmotionRecords(limit: Int = 10, completion: @escaping (Result<[EmotionRecord], Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(
                domain: "Auth",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "로그인된 사용자가 없습니다."]
            )))
            return
        }

        db.collection("users")
            .document(uid)
            .collection("emotionRecords")
            .order(by: "recordDate", descending: true)
            .order(by: "timeSlotOrder", descending: true)
            .order(by: "createdAt", descending: true)
            .limit(to: limit)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                let records: [EmotionRecord] = snapshot?.documents.compactMap { document -> EmotionRecord? in
                    let data = document.data()

                    guard
                        let emotionRaw = data["emotion"] as? String,
                        let situationRaw = data["situation"] as? String,
                        let energyRaw = data["energy"] as? String,
                        let intensity = data["intensity"] as? Int,
                        let socialContextRaw = data["socialContext"] as? String,
                        let timeSlotRaw = data["timeSlot"] as? String,
                        let memo = data["memo"] as? String,
                        let recordDate = data["recordDate"] as? String,
                        let yearMonth = data["yearMonth"] as? String,
                        let emotion = Emotion(rawValue: emotionRaw),
                        let situation = Situation(rawValue: situationRaw),
                        let energy = Energy(rawValue: energyRaw),
                        let socialContext = SocialContext(rawValue: socialContextRaw),
                        let timeSlot = TimeSlot(rawValue: timeSlotRaw)
                    else {
                        return nil
                    }

                    return EmotionRecord(
                        id: document.documentID,
                        emotion: emotion,
                        situation: situation,
                        energy: energy,
                        intensity: intensity,
                        socialContext: socialContext,
                        timeSlot: timeSlot,
                        memo: memo,
                        recordDate: recordDate,
                        yearMonth: yearMonth
                    )
                } ?? []

                completion(.success(records))
            }
    }
    
    func fetchMonthlyEmotionRecords(yearMonth: String, completion: @escaping (Result<[EmotionRecord], Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(
                domain: "Auth",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "로그인된 사용자가 없습니다."]
            )))
            return
        }

        db.collection("users")
            .document(uid)
            .collection("emotionRecords")
            .whereField("yearMonth", isEqualTo: yearMonth)
            .order(by: "recordDate", descending: false)
            .order(by: "timeSlotOrder", descending: false)
            .order(by: "createdAt", descending: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                let records: [EmotionRecord] = snapshot?.documents.compactMap { document -> EmotionRecord? in
                    let data = document.data()

                    guard
                        let emotionRaw = data["emotion"] as? String,
                        let situationRaw = data["situation"] as? String,
                        let energyRaw = data["energy"] as? String,
                        let intensity = data["intensity"] as? Int,
                        let socialContextRaw = data["socialContext"] as? String,
                        let timeSlotRaw = data["timeSlot"] as? String,
                        let memo = data["memo"] as? String,
                        let recordDate = data["recordDate"] as? String,
                        let yearMonth = data["yearMonth"] as? String,
                        let emotion = Emotion(rawValue: emotionRaw),
                        let situation = Situation(rawValue: situationRaw),
                        let energy = Energy(rawValue: energyRaw),
                        let socialContext = SocialContext(rawValue: socialContextRaw),
                        let timeSlot = TimeSlot(rawValue: timeSlotRaw)
                    else {
                        return nil
                    }

                    return EmotionRecord(
                        id: document.documentID,
                        emotion: emotion,
                        situation: situation,
                        energy: energy,
                        intensity: intensity,
                        socialContext: socialContext,
                        timeSlot: timeSlot,
                        memo: memo,
                        recordDate: recordDate,
                        yearMonth: yearMonth
                    )
                } ?? []

                completion(.success(records))
            }
    }
    
    // 데이터 수정
    func updateEmotionRecordMemo(recordId: String, memo: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(
                domain: "Auth",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "로그인된 사용자가 없습니다."]
            )))
            return
        }

        db.collection("users")
            .document(uid)
            .collection("emotionRecords")
            .document(recordId)
            .updateData([
                "memo": memo,
                "updatedAt": FieldValue.serverTimestamp()
            ]) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }
    
    // 데이터 삭제
    func deleteEmotionRecord(recordId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(
                domain: "Auth",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "로그인된 사용자가 없습니다."]
            )))
            return
        }

        db.collection("users")
            .document(uid)
            .collection("emotionRecords")
            .document(recordId)
            .delete { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }
}
