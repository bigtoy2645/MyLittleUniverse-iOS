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
    Emotion(word: "보람찬", origin: "보람차다", part: .adjective, definition: "어떤 일을 한 뒤에 결과가 몹시 좋아서 자랑스러움과 자부심을 갖게 할 만큼 만족스럽다."),
    Emotion(word: "신기한", origin: "신기하다", part: .adjective, definition: "믿을 수 없을 정도로 색다르고 놀랍다."),
    Emotion(word: "새로운", origin: "새롭다", part: .adjective, definition: "전과 달리 생생하고 산뜻하게 느껴지는 맛이 있다."),
    Emotion(word: "소중한", origin: "소중하다", part: .adjective, definition: "매우 귀중하다."),
    Emotion(word: "아늑한", origin: "아늑하다", part: .adjective, definition: "따뜻하고 포근한 느낌이 있다."),
    Emotion(word: "달콤한", origin: "달콤하다", part: .adjective, definition: "흥미가 나게 아기자기하거나 간드러진 느낌이 있다."),
    Emotion(word: "고마운", origin: "고맙다", part: .adjective, definition: "남이 베풀어 준 호의나 도움 따위에 대하여 마음이 흐뭇하고 즐겁다."),
    Emotion(word: "힘이 나는", origin: "힘 나다", part: .inverb, definition: "자신감이나 용기가 생기다."),
    Emotion(word: "황홀한", origin: "황홀하다", part: .adjective, definition: "어떤 사물에 마음이나 시선이 혹하여 달뜬 상태이다."),
    Emotion(word: "포근한", origin: "포근하다", part: .adjective, definition: "감정이나 분위기 따위가 보드랍고 따뜻하여 편안한 느낌이 있다."),
    Emotion(word: "근사한", origin: "근사하다", part: .adjective, definition: "그럴듯하게 괜찮다."),
    Emotion(word: "기특한", origin: "기특하다", part: .adjective, definition: "말하는 것이나 행동하는 것이 신통하여 귀염성이 있다."),
    Emotion(word: "시원한", origin: "시원하다", part: .adjective, definition: "막힌 데가 없이 활짝 트이어 마음이 후련하다."),
    Emotion(word: "가뿐한", origin: "가뿐하다", part: .adjective, definition: "몸의 상태가 가볍고 상쾌하다."),
    Emotion(word: "개운한", origin: "개운하다", part: .adjective, definition: "기분이나 몸이 상쾌하고 가뜬하다."),
    Emotion(word: "상쾌한", origin: "상쾌하다", part: .adjective, definition: "느낌이 시원하고 산뜻하다."),
    Emotion(word: "산뜻한", origin: "산뜻하다", part: .adjective, definition: "기분이나 느낌이 깨끗하고 시원하다."),
    Emotion(word: "들뜬", origin: "들뜨다", part: .verb, definition: "마음이나 분위기가 가라앉지 아니하고 조금 흥분되다.")
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
    Emotion(word: "찝찝한", origin: "찝찝하다", part: .adjective, definition: "개운하지 않고 무엇인가 마음에 걸리는 데가 있다."),
    Emotion(word: "짜증나는", origin: "짜증나다", part: .inverb, definition: "마음에 탐탁하지 않아서 역정이 나다."),
    Emotion(word: "심란한", origin: "심란하다", part: .adjective, definition: "마음이 어수선하다."),
    Emotion(word: "속상한", origin: "속상하다", part: .adjective, definition: "화가 나거나 걱정이 되는 따위로 인하여 마음이 불편하고 우울하다."),
    Emotion(word: "화나는", origin: "화나다", part: .verb, definition: "성이 나서 화기가 생기다."),
    Emotion(word: "분노하는", origin: "분노하다", part: .verb, definition: "분개하여 몹시 성을 내다."),
    Emotion(word: "불쾌한", origin: "불쾌하다", part: .adjective, definition: "못마땅하여 기분이 좋지 아니하다."),
    Emotion(word: "민망한", origin: "민망하다", part: .adjective, definition: "낯을 들고 대하기가 부끄럽다."),
    Emotion(word: "더러운", origin: "더럽다", part: .adjective, definition: "못마땅하거나 불쾌하다."),
    Emotion(word: "못마땅한", origin: "못마땅하다", part: .adjective, definition: "마음에 들지 않아 좋지 않다."),
    Emotion(word: "수치스러운", origin: "수치스럽다", part: .adjective, definition: "다른 사람을 볼 낯이 없거나 스스로 떳떳하지 못한 느낌이 있다."),
    Emotion(word: "불만스러운", origin: "불만스럽다", part: .adjective, definition: "보기에 마음에 차지 않아 언짢은 느낌이 있다."),
    Emotion(word: "부루퉁한", origin: "부루퉁하다", part: .adjective, definition: "불만스럽거나 못마땅하여 성난 빛이 얼굴에 나타나 있다."),
    Emotion(word: "열받는", origin: "열받다", part: .inverb, definition: "어떤 일에 화가 나거나 흥분을 하여 몸이 달아오르다."),
    Emotion(word: "막막한", origin: "막막하다", part: .adjective, definition: "꽉 막힌 듯이 답답하다."),
    Emotion(word: "처진", origin: "처지다", part: .verb, definition: "감정 혹은 기분 따위가 바닥으로 잠겨 가라앉다."),
    Emotion(word: "쓸쓸한", origin: "쓸쓸하다", part: .adjective, definition: "외롭고 적적하다."),
    Emotion(word: "방황하는", origin: "방황하다", part: .verb, definition: "분명한 방향이나 목표를 정하지 못하고 갈팡질팡하다."),
    Emotion(word: "지치는", origin: "지치다", part: .verb, definition: "힘든 일을 하거나 어떤 일에 시달려서 기운이 빠지다."),
    Emotion(word: "섭섭한", origin: "섭섭하다", part: .adjective, definition: "기대에 어그러져 마음이 서운하거나 불만스럽다."),
    Emotion(word: "서러운", origin: "서럽다", part: .adjective, definition: "원통하고 슬프다."),
    Emotion(word: "안쓰러운", origin: "안쓰럽다", part: .adjective, definition: "손아랫사람이나 약자의 딱한 형편이 마음이 아프고 가엽다."),
    Emotion(word: "서운한", origin: "서운하다", part: .adjective, definition: "마음에 모자라 아쉽거나 섭섭한 느낌이 있다."),
    Emotion(word: "서글픈", origin: "서글프다", part: .adjective, definition: "쓸쓸하고 외로워 슬프다.")
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
    Emotion(word: "회복된", origin: "회복되다", part: .verb, definition: "원래의 상태로 돌아가거나 원래의 상태가 되찾아지다."),
    Emotion(word: "새삼스러운", origin: "새삼스럽다", part: .adjective, definition: "이미 알고 있는 사실에 대하여 느껴지는 감정이 갑자기 새로운 데가 있다."),
    Emotion(word: "울컥한", origin: "울컥하다", part: .verb, definition: "격한 감정이 갑자기 일어나다."),
    Emotion(word: "고요한", origin: "고요하다", part: .adjective, definition: "조용하고 잠잠하다."),
    Emotion(word: "헷갈리는", origin: "헷갈리다", part: .verb, definition: "여러 가지가 뒤섞여 갈피를 잡지 못하다."),
    Emotion(word: "아쉬운", origin: "아쉽다", part: .adjective, definition: "미련이 남아 서운하다."),
    Emotion(word: "그윽한", origin: "그윽하다", part: .adjective, definition: "깊숙하여 아늑하고 고요하다.")
]
