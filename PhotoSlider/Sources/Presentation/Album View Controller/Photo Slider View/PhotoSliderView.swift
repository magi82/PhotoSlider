//
//  PhotoSliderView.swift
//  PhotoSlider
//
//  Created by Dooho Chang on 2017. 12. 8..
//  Copyright © 2017년 Dooho Chang. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

protocol PhotoSliderViewBindable {
    var setPhoto: Signal<(photo: Photo, animatingDuration: Double)> { get }
}

class PhotoSliderView: FadingImageView {
    private var disposeBag = DisposeBag()
    
    func bind(_ viewModel: PhotoSliderViewBindable) {
        self.disposeBag = DisposeBag()
        
        viewModel.setPhoto
            .flatMapFirst { [weak self] arguments -> Signal<Never> in
                guard let `self` = self else { return .empty() }
                return self.rx
                    .set(
                        photo: arguments.photo,
                        animatingDuration: arguments.animatingDuration
                    )
                    .asSignal(onErrorSignalWith: .empty())
            }
            .emit()
            .disposed(by: disposeBag)
    }
}

extension Reactive where Base: PhotoSliderView {
    func set(photo: Photo, animatingDuration: Double) -> Completable {
        return fadeOut(duration: animatingDuration / 2)
            .andThen(
                fadeIn(image: photo.image, duration: animatingDuration / 2)
            )
    }
}
