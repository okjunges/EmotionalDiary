//
//  FaceIDService.swift
//  EmotionalDiary
//
//  Created by 김완수 on 5/28/26.
//

import LocalAuthentication

final class FaceIDService {

    static let shared = FaceIDService()
    private init() {}

    func authenticate(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "앱 잠금 해제를 위해 인증해주세요."
            ) { success, _ in
                DispatchQueue.main.async {
                    completion(success)
                }
            }
        } else {
            completion(false)
        }
    }
}
