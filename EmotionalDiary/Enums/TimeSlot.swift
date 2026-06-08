//
//  TimeSlot.swift
//  EmotionalDiary
//
//  Created by 김완수 on 5/11/26.
//

enum TimeSlot: String, CaseIterable {
    case lateAtNight
    case morning
    case afternoon
    case evening
    case night
    
    var title: String {
        switch self {
        case .lateAtNight: return "새벽\n00~06시"
        case .morning: return "아침\n06~11시"
        case .afternoon: return "점심\n11~16시"
        case .evening: return "저녁\n16~21시"
        case .night: return "밤\n21~24시"
        }
    }
    
    var saveTitle: String {
        switch self {
        case .lateAtNight: return "새벽"
        case .morning: return "아침"
        case .afternoon: return "점심"
        case .evening: return "저녁"
        case .night: return "밤"
        }
    }
    
    var order: Int {
        switch self {
        case .lateAtNight: return 0
        case .morning: return 1
        case .afternoon: return 2
        case .evening: return 3
        case .night: return 4
        }
    }
}
