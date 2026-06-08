//
//  AuthService.swift
//  EmotionalDiary
//
//  Created by 김완수 on 5/11/26.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

final class AuthService {

    static let shared = AuthService()
    private init() {}

    private let db = Firestore.firestore()

    var currentUid: String? {
        return Auth.auth().currentUser?.uid
    }

    func signUp(
        email: String,
        password: String,
        nickname: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let uid = result?.user.uid else {
                completion(.failure(NSError(domain: "Auth", code: -1)))
                return
            }

            self?.db.collection("users").document(uid).setData([
                "email": email,
                "nickname": nickname,
                "createdAt": FieldValue.serverTimestamp(),
                "updatedAt": FieldValue.serverTimestamp()
            ]) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }

    func login(
        email: String,
        password: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    func logout() -> Result<Void, Error> {
        do {
            try Auth.auth().signOut()
            UserSession.shared.currentUser = nil
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func fetchCurrentUser(
        completion: @escaping (Result<AppUser, Error>) -> Void
    ) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "Auth", code: -1)))
            return
        }

        db.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = snapshot?.data(),
                  let email = data["email"] as? String,
                  let nickname = data["nickname"] as? String else {
                completion(.failure(NSError(domain: "User", code: -1)))
                return
            }

            let user = AppUser(
                uid: uid,
                email: email,
                nickname: nickname
            )

            UserSession.shared.currentUser = user
            completion(.success(user))
        }
    }
}
