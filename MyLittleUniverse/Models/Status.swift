//
//  Status.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/04/29.
//

import Foundation

enum Status: String {
    case positive = "좋아요"
    case negative = "좋지 않아요"
    case neutral = "둘 다 아니에요"
    case random = "복합적이에요"
}

extension Status {
    func emotions() -> [Emotion] {
        switch self {
        case .positive:
            return positiveEmotions
        case .negative:
            return negativeEmotions
        case .neutral:
            return neutralEmotions
        case .random:
            return [positiveEmotions, negativeEmotions, neutralEmotions].flatMap { $0 }.shuffled()
        }
    }
}

let positiveEmotions = [
    Emotion(word: "감격한", origin: "감격하다", part: .verb, definition: "마음에 깊이 느끼어 크게 감동하다."),
    Emotion(word: "감사한", origin: "감사하다", part: .verb, definition: "고맙게 여기다."),
    Emotion(word: "기대되는", origin: "기대하다", part: .verb, definition: "어떤 일이 원하는 대로 이루어지기를 바라면서 기다리다."),
    Emotion(word: "설레는", origin: "설레다", part: .verb, definition: "마음이 가라앉지 아니하고 들떠서 두근거리다."),
    Emotion(word: "신나는", origin: "신나다", part: .verb, definition: "어떤 일에 흥미나 열성이 생겨 기분이 매우 좋아지다."),
    Emotion(word: "안심하는", origin: "안심하다", part: .verb, definition: "모든 걱정을 떨쳐 버리고 마음을 편히 가지다."),
    Emotion(word: "자신하는", origin: "자신하다", part: .verb, definition: "어떤 일을 해낼 수 있다거나 어떤 일이 꼭 그렇게 되리라는 데 대하여 스스로 굳게 믿다."),
    Emotion(word: "경이로운", origin: "경이롭다", part: .adjective, definition: "놀랍고 신기한 데가 있다."),
    Emotion(word: "기쁜", origin: "기쁘다", part: .adjective, definition: "욕구가 충족되어 마음이 흐뭇하고 흡족하다."),
    Emotion(word: "너그러운", origin: "너그럽다", part: .adjective, definition: "마음이 넓고 아량이 있다."),
    Emotion(word: "놀라운", origin: "놀랍다", part: .adjective, definition: "감동을 일으킬 만큼 훌륭하거나 굉장하다."),
    Emotion(word: "다정한", origin: "다정하다", part: .adjective, definition: "정이 많다. 또는 정분이 두텁다."),
    Emotion(word: "든든한", origin: "든든하다", part: .adjective, definition: "어떤 것에 대한 믿음으로 마음이 허전하거나 두렵지 않고 굳세다."),
    Emotion(word: "따뜻한", origin: "따뜻하다", part: .adjective, definition: "감정, 태도, 분위기 따위가 정답고 포근하다."),
    Emotion(word: "만족스러운", origin: "만족스럽다", part: .adjective, definition: "매우 만족할 만한 데가 있다."),
    Emotion(word: "반가운", origin: "반갑다", part: .adjective, definition: "그리워하던 사람을 만나거나 원하는 일이 이루어져서 마음이 즐겁고 기쁘다."),
    Emotion(word: "뿌듯한", origin: "뿌듯하다", part: .adjective, definition: "기쁨이나 감격이 마음에 가득 차서 벅차다."),
    Emotion(word: "사랑스러운", origin: "사랑스럽다", part: .adjective, definition: "생김새나 행동이 사랑을 느낄 만큼 귀여운 데가 있다."),
    Emotion(word: "상냥한", origin: "상냥하다", part: .adjective, definition: "성질이 싹싹하고 부드럽다."),
    Emotion(word: "여유로운", origin: "여유롭다", part: .adjective, definition: "여유가 있다."),
    Emotion(word: "자랑스러운", origin: "자랑스럽다", part: .adjective, definition: "남에게 드러내어 뽐낼 만한 데가 있다."),
    Emotion(word: "재미있는", origin: "재미 있다", part: .adjective, definition: "아기자기하게 즐겁고 유쾌한 기분이나 느낌이 있다."),
    Emotion(word: "즐거운", origin: "즐겁다", part: .adjective, definition: "마음에 거슬림이 없이 흐뭇하고 기쁘다."),
    Emotion(word: "편안한", origin: "편안하다", part: .adjective, definition: "편하고 걱정 없이 좋다."),
    Emotion(word: "풍성한", origin: "풍성하다", part: .adjective, definition: "넉넉하고 많다."),
    Emotion(word: "행복한", origin: "행복하다", part: .adjective, definition: "생활에서 충분한 만족과 기쁨을 느끼어 흐뭇하다."),
    Emotion(word: "홀가분한", origin: "홀가분하다", part: .adjective, definition: "거추장스럽지 아니하고 가볍고 편안하다."),
    Emotion(word: "활기찬", origin: "활기차다", part: .adjective, definition: "힘이 넘치고 생기가 가득하다."),
    Emotion(word: "애틋한", origin: "애틋하다", part: .adjective, definition: "섭섭하고 안타까워 애가 타는 듯하다."),
    Emotion(word: "짜릿한", origin: "짜릿하다", part: .adjective, definition: "심리적 자극을 받아 마음이 순간적으로 조금 흥분되고 떨리는 듯하다."),
    Emotion(word: "후련한", origin: "후련하다", part: .adjective, definition: "좋지 아니하던 속이 풀리거나 내려서 시원하다."),
    Emotion(word: "감동적인", origin: "감동적", part: .adverb, definition: "크게 느끼어 마음이 움직이는."),
    Emotion(word: "힘이 나는", origin: "힘 나다", part: .inverb, definition: "자신감이나 용기가 생기다.")
]

let negativeEmotions = [
    Emotion(word: "외로운", origin: "외롭다", part: .adjective, definition: "홀로 되거나 의지할 곳이 없어 쓸쓸하다."),
    Emotion(word: "먹먹한", origin: "먹먹하다", part: .adjective, definition: "체한 것같이 가슴이 답답하다."),
    Emotion(word: "창피한", origin: "창피하다", part: .adjective, definition: "체면이 깎이는 일이나 아니꼬운 일을 당하여 부끄럽다."),
    Emotion(word: "따분한", origin: "따분하다", part: .adjective, definition: "재미가 없어 지루하고 답답하다."),
    Emotion(word: "부끄러운", origin: "부끄럽다", part: .adjective, definition: "일을 잘 못하거나 양심에 거리끼어 볼 낯이 없거나 매우 떳떳하지 못하다."),
    Emotion(word: "나약한", origin: "나약하다", part: .adjective, definition: "의지가 굳세지 못하다."),
    Emotion(word: "슬픈", origin: "슬프다", part: .adjective, definition: "원통한 일을 겪거나 불쌍한 일을 보고 마음이 아프고 괴롭다."),
    Emotion(word: "해탈한", origin: "해탈하다", part: .verb, definition: "얽매임에서 벗어나다."),
    Emotion(word: "위태로운", origin: "위태롭다", part: .adjective, definition: "어떤 형세가 마음을 놓을 수 없을 만큼 위험한 듯하다."),
    Emotion(word: "두려운", origin: "두렵다", part: .adjective, definition: "어떤 대상을 무서워하여 마음이 불안하다."),
    Emotion(word: "무서운", origin: "무섭다", part: .adjective, definition: "어떤 대상에 대하여 꺼려지거나 무슨 일이 일어날까 겁나는 데가 있다."),
    Emotion(word: "부담스러운", origin: "부담스럽다", part: .adjective, definition: "어떠한 의무나 책임을 져야 할 듯한 느낌이 있다."),
    Emotion(word: "초조한", origin: "초조하다", part: .adjective, definition: "애가 타서 마음이 조마조마하다."),
    Emotion(word: "무모한", origin: "무모하다", part: .adjective, definition: "앞뒤를 잘 헤아려 깊이 생각하는 신중성이나 꾀가 없다."),
    Emotion(word: "벌거벗은", origin: "벌거벗다", part: .verb, definition: "아주 알몸이 되도록 입은 옷을 모두 벗다."),
    Emotion(word: "공허한", origin: "공허하다", part: .adjective, definition: "아무것도 없이 텅 비다."),
    Emotion(word: "답답한", origin: "답답하다", part: .adjective, definition: "숨이 막힐 듯이 갑갑하다."),
    Emotion(word: "무안한", origin: "무안하다", part: .adjective, definition: "수줍거나 창피하여 볼 낯이 없다."),
    Emotion(word: "서늘한", origin: "서늘하다", part: .adjective, definition: "사람의 성격이나 태도 따위가 차가운 데가 있다."),
    Emotion(word: "무거운", origin: "무겁다", part: .adjective, definition: "비중이나 책임 따위가 크거나 중대하다."),
    Emotion(word: "뻔뻔한", origin: "뻔뻔하다", part: .adjective, definition: "부끄러운 짓을 하고도 염치없이 태연하다."),
    Emotion(word: "혼란스러운", origin: "혼란스럽다", part: .adjective, definition: "보기에 뒤죽박죽이 되어 어지럽고 질서가 없는 데가 있다."),
    Emotion(word: "야속한", origin: "야속하다", part: .adjective, definition: "무정한 행동이나 그런 행동을 한 사람이 섭섭하게 여겨져 언짢다."),
    Emotion(word: "허전한", origin: "허전하다", part: .adjective, definition: "무엇을 잃거나 의지할 곳이 없어진 것같이 서운한 느낌이 있다."),
    Emotion(word: "겁먹은", origin: "겁먹다", part: .verb, definition: "무섭거나 두려워하는 마음을 가지다."),
    Emotion(word: "허무한", origin: "허무하다", part: .adjective, definition: "무가치하고 무의미하게 느껴져 매우 허전하고 쓸쓸하다."),
    Emotion(word: "허탈한", origin: "허탈하다", part: .adjective, definition: "몸에 기운이 빠지고 정신이 멍하다."),
    Emotion(word: "처참한", origin: "처참하다", part: .adjective, definition: "몸서리칠 정도로 슬프고 끔찍하다."),
    Emotion(word: "거북한", origin: "거북하다", part: .adjective, definition: "마음이 어색하고 겸연쩍어 편하지 않다."),
    Emotion(word: "울적한", origin: "울적하다", part: .adjective, definition: "마음이 답답하고 쓸쓸하다."),
    Emotion(word: "긴장되는", origin: "긴장되다", part: .verb, definition: "마음을 조이고 정신을 바짝 차리게 되다."),
    Emotion(word: "우울한", origin: "우울하다", part: .adjective, definition: "근심스럽거나 답답하여 활기가 없다."),
    Emotion(word: "찝찝한", origin: "찝찝하다", part: .adjective, definition: "개운하지 않고 무엇인가 마음에 걸리는 데가 있다.")
]

let neutralEmotions = [
    Emotion(word: "스스러운", origin: "스스럽다", part: .adjective, definition: "서로 사귀는 정분이 두텁지 않아 조심스럽다."),
    Emotion(word: "나른한", origin: "나른하다", part: .adjective, definition: "맥이 풀리거나 고단하여 기운이 없다."),
    Emotion(word: "차분한", origin: "차분하다", part: .adjective, definition: "마음이 가라앉아 조용하다."),
    Emotion(word: "괜찮은", origin: "괜찮다", part: .adjective, definition: "별로 나쁘지 않고 보통 이상이다."),
    Emotion(word: "그리운", origin: "그립다", part: .adjective, definition: "보고 싶거나 만나고 싶은 마음이 간절하다"),
    Emotion(word: "미안한", origin: "미안하다", part: .adjective, definition: "남에게 대하여 마음이 편치 못하고 부끄럽다."),
    Emotion(word: "아리송한", origin: "아리송하다", part: .adjective, definition: "그런 것 같기도 하고 그렇지 않은 것 같기도 하여 분간하기 어렵다."),
    Emotion(word: "묘한", origin: "묘하다", part: .adjective, definition: "일이나 이야기의 내용 따위가 기이하여 표현하거나 규정하기 어렵다."),
    Emotion(word: "애매한", origin: "애매하다", part: .adjective, definition: "희미하여 분명하지 아니하다."),
    Emotion(word: "멍한", origin: "멍하다", part: .adjective, definition: "정신이 나간 것처럼 자극에 대한 반응이 없다."),
    Emotion(word: "회복된", origin: "회복되다", part: .verb, definition: "원래의 상태로 돌아가거나 원래의 상태가 되찾아지다.")
]
