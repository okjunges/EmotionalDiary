//
//  Energy.swift
//  EmotionalDiary
//
//  Created by 김완수 on 5/11/26.
//

enum Energy: String, CaseIterable {

    case high
    case medium
    case low
    
    var title: String {
        switch self {
        case .high: return "높음"
        case .medium: return "중간"
        case .low: return "낮음"
        }
    }
}
