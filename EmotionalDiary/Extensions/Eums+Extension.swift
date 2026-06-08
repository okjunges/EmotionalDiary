//
//  Emotion+Extension.swift
//  EmotionalDiary
//
//  Created by 김완수 on 5/15/26.
//

extension Emotion {
    static let allCases: [Emotion] = [
        .happy, .satisfied, .normal, .worried, .sad, .angry, .stress, .tired, .calm
    ]
}

extension Energy {
    static let allCases: [Energy] = [.high, .medium, .low]
}

extension SocialContext {
    static let allCases: [SocialContext] = [
        .alone, .family, .friends, .partner, .coworkers, .acquaintances, .strangers
    ]
}

extension TimeSlot {
    static let allCases: [TimeSlot] = [.lateAtNight, .morning, .afternoon, .evening, .night]
}
