//
//  PhotoSliderViewModel.swift
//  PhotoSlider
//
//  Created by Dooho Chang on 2017. 12. 9..
//  Copyright © 2017년 Dooho Chang. All rights reserved.
//

import RxSwift
import RxCocoa

protocol PhotoSliderViewModel: PhotoSliderViewBindable {
    func present(photos: [Photo]) -> Observable<Int> // number of remaining photos
}

class PhotoSliderViewModelImpl: PhotoSliderViewModel {
    let photoDuration: Double
    private let photoStream = PublishSubject<Photo>() // unique mutable state of PhotoSliderViewModelImpl
    
    let setPhoto: Signal<(photo: Photo, animatingDuration: Double)>
    
    init(photoDuration: Double) {
        self.photoDuration = photoDuration
        
        let animatingDuration = min(photoDuration / 5, 1)
        
        self.setPhoto = photoStream
            .map { (photo: $0, animatingDuration: animatingDuration) }
            .asSignal(onErrorSignalWith: .empty())
    }
    
    func present(photos: [Photo]) -> Observable<Int> {
        return Observable.deferred {
            let stream = Observable.from(photos)
                .concatMap { photo -> Observable<Photo> in
                    let duration = Observable<Photo>.empty()
                        .delay(self.photoDuration, scheduler: MainScheduler.instance)
                    
                    return Observable.just(photo).concat(duration)
                }
            
            let streamWithSideEffect = stream
                .do(onNext: { photo in
                    self.photoStream.onNext(photo)
                })
            
            return streamWithSideEffect
                .scan(photos.count) { count, _ in count - 1 } // number of remaining photos
        }
    }
}
