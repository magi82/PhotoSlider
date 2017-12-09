//
//  FadingImageView.swift
//  PhotoSlider
//
//  Created by Dooho Chang on 2017. 12. 8..
//  Copyright © 2017년 Dooho Chang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class FadingImageView: UIImageView { }

extension Reactive where Base: FadingImageView {
    // Reactive methods for fading effects
    func fadeIn(image: UIImage, duration: Double) -> Completable {
        return Completable
            .create { [weak base] observer in
                base?.image = image
                UIView.animate(
                    withDuration: duration,
                    animations: { base?.alpha = 1.0 },
                    completion: { _ in observer(.completed) }
                )
                
                return Disposables.create()
            }
    }
    
    func fadeOut(duration: Double) -> Completable {
        return Completable
            .create { [weak base] observer in
                UIView.animate(
                    withDuration: duration,
                    animations: { base?.alpha = 0 },
                    completion: { _ in
                        base?.image = nil
                        observer(.completed)
                    }
                )
                
                return Disposables.create()
            }
    }
}
