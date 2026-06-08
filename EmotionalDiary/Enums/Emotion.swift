//
//  Emotion.swift
//  EmotionalDiary
//
//  Created by 김완수 on 5/11/26.
//

enum Emotion: String, CaseIterable {

    case happy
    case satisfied
    case normal
    case worried
    case sad
    case angry
    case stress
    case tired
    case calm
    
    var situations: [Situation] {
        switch self {
        case .happy:
            return [.achievement, .compliment, .relationship, .fun, .rest, .hobby, .goodFood, .etc]

        case .satisfied:
            return [.productiveDay, .finishedTask, .study, .selfCare, .stableDay, .etc]

        case .normal:
            return [.normalDay, .busy, .rest, .study, .etc]

        case .worried:
            return [.future, .career, .relationship, .study, .money, .selfDoubt, .decision, .etc]

        case .sad:
            return [.loneliness, .disappointment, .relationship, .failure, .overthinking, .etc]

        case .angry:
            return [.conflict, .misunderstanding, .unfairness, .annoyance, .relationship, .etc]

        case .stress:
            return [.assignment, .deadline, .study, .workload, .lackOfSleep, .pressure, .etc]

        case .tired:
            return [.lackOfSleep, .study, .workload, .overthinking, .busy, .etc]

        case .calm:
            return [.rest, .quietTime, .music, .family, .stableDay, .hobby, .etc]
        }
    }
    
    // question + 감정
    var question: String {
        switch self {
        case .happy: return "행복한"
        case .satisfied: return "만족스러운"
        case .normal: return "무난한"
        case .worried: return "고민하는"
        case .sad: return "슬픈"
        case .angry: return "화나는"
        case .stress: return "스트레스 받는"
        case .tired: return "피곤한"
        case .calm: return "편안한"
        }
    }
    
    var title: String {
        switch self {
        case .happy: return "행복"
        case .satisfied: return "만족"
        case .normal: return "보통"
        case .worried: return "고민"
        case .sad: return "슬픔"
        case .angry: return "화남"
        case .stress: return "스트레스"
        case .tired: return "피곤"
        case .calm: return "편안"
        }
    }

    var imageName: String {
        switch self {
        case .happy: return "happy"
        case .satisfied: return "satisfied"
        case .normal: return "normal"
        case .worried: return "worried"
        case .sad: return "sad"
        case .angry: return "angry"
        case .stress: return "stress"
        case .tired: return "tired"
        case .calm: return "calm"
        }
    }
}
