//
//  PaintViewModel.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/05/25.
//

import Foundation
import RxSwift
import RxCocoa

struct Handler {
    let undo: (() -> Void)
    let redo: (() -> Void)
}

class PaintViewModel {
    let stickers = BehaviorRelay<[StickerEdgeView]>(value: [])
    let bgHexColor = BehaviorRelay<Int>(value: 0xFFFFFF)
    let emotion = BehaviorRelay<Emotion>(value: Emotion.empty)
    let bgColor = BehaviorSubject<UIColor>(value: .white)
    let leftControl = BehaviorRelay<UIButton?>(value: nil)
    let isEditing = BehaviorRelay<Bool>(value: false)
    
    private let disposeBag = DisposeBag()
    
    init() {
        bgHexColor.map { UIColor(rgb: $0) }
            .bind(to: bgColor)
            .disposed(by: disposeBag)
    }
    
    /* 스티커 추가 */
    func addSticker(_ sticker: StickerEdgeView) {
        var newStickers = stickers.value
        newStickers.append(sticker)
        stickers.accept(newStickers)
    }
    
    /* 스티커 삭제 */
    func removeSticker(_ sticker: StickerEdgeView) {
        let newStickers = stickers.value.filter { $0.sticker.value != sticker.sticker.value }
        stickers.accept(newStickers)
    }
}
