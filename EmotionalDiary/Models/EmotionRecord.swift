//
//  EmotionRecord.swift
//  EmotionalDiary
//
//  Created by 김완수 on 5/11/26.
//

struct EmotionRecord {
    let id: String?

    let emotion: Emotion
    let situation: Situation
    let energy: Energy
    let intensity: Int
    let socialContext: SocialContext
    let timeSlot: TimeSlot

    let memo: String

    let recordDate: String
    let yearMonth: String
}
