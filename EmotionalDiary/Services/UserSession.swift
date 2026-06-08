//
//  UserSession.swift
//  EmotionalDiary
//
//  Created by 김완수 on 5/11/26.
//

final class UserSession {

    static let shared = UserSession()
    private init() {}

    var currentUser: AppUser?
}
