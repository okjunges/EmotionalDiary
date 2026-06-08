//
//  SocialContext.swift
//  EmotionalDiary
//
//  Created by 김완수 on 5/11/26.
//

enum SocialContext: String, CaseIterable {

    case alone
    case family
    case friends
    case partner
    case coworkers
    case acquaintances
    case strangers
    
    var title: String {
        switch self {
        case .alone: return "혼자"
        case .family: return "가족"
        case .friends: return "친구"
        case .partner: return "연인"
        case .coworkers: return "동료"
        case .acquaintances: return "지인"
        case .strangers: return "모르는 사람"
        }
    }
}
