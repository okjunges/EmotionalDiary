//
//  Date+Extension.swift
//  EmotionalDiary
//
//  Created by 김완수 on 5/15/26.
//

import Foundation

extension Date {

    func toRecordDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ko_KR")

        return formatter.string(from: self)
    }

    func toYearMonthString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        formatter.locale = Locale(identifier: "ko_KR")

        return formatter.string(from: self)
    }
    
    func toMonthDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "(M/dd)"
        formatter.locale = Locale(identifier: "ko_KR")

        return formatter.string(from: self)
    }

    func toKoreanTitleWithYearString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일 (EEE)"
        formatter.locale = Locale(identifier: "ko_KR")

        return formatter.string(from: self)
    }
    
    func toKoreanTitleString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일 (EEE)"
        formatter.locale = Locale(identifier: "ko_KR")

        return formatter.string(from: self)
    }
}
