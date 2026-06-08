//
//  FirebaseAuthErrorMessage.swift
//  EmotionalDiary
//
//  Created by 김완수 on 5/11/26.
//

import Foundation
import FirebaseAuth

struct FirebaseAuthErrorMessage {
    
    static func convert(_ error: Error) -> String {
        let nsError = error as NSError
        let code = AuthErrorCode(rawValue: nsError.code)
        
        print("Firebase Auth Error Code:", nsError.code)
        print("Firebase Auth Error:", error.localizedDescription)
        
        switch code {
        case .invalidEmail:
            return "올바른 이메일 형식이 아닙니다."
            
        case .userNotFound:
            return "가입되지 않은 이메일입니다."
            
        case .wrongPassword:
            return "비밀번호가 올바르지 않습니다."
            
        case .invalidCredential:
            return "이메일 또는 비밀번호가 올바르지 않습니다."
            
        case .emailAlreadyInUse:
            return "이미 사용 중인 이메일입니다."
            
        case .weakPassword:
            return "비밀번호는 6자리 이상 입력해주세요."
            
        case .networkError:
            return "네트워크 연결을 확인해주세요."
            
        case .userDisabled:
            return "비활성화된 계정입니다."
            
        case .tooManyRequests:
            return "요청이 너무 많습니다. 잠시 후 다시 시도해주세요."
            
        default:
            return "오류가 발생했습니다. 다시 시도해주세요."
        }
    }
}
