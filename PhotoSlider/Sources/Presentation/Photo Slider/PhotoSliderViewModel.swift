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
    func present(photos: [Photo]) -> Observable<Int> // Current presenting photo index
}

class PhotoSliderViewModelImpl: PhotoSliderViewModel {
    let photoDuration: Double
    private let photoStream: PublishSubject<Photo> // Unique mutable state of PhotoSliderViewModelImpl
    
    let setPhoto: Signal<(photo: Photo, animatingDuration: Double)>
    
    init(photoDuration: Double) {
        self.photoDuration = photoDuration
        
        self.setPhoto = photoStream
            .map { (photo: $0, animatingDuration: photoDuration / 8) }
            .asSignal(onErrorSignalWith: .empty())
    }
    
    func present(photos: [Photo]) -> Observable<Int> {
        return Observable.deferred { [photoDuration, photoStream]
            let stream = Observable.from(photos)
                .concatMap { photo -> Observable<Photo> in
                    let duration: Observable<Photo> = .empty()
                        .delay(photoDuration, scheduler: MainScheduler.instance)
                    
                    return .just(photo).concat(duration)
                }
            
            let streamWithSideEffect = stream
                .do(onNext: { photo in
                    photoStream.onNext(photo)
                })
            
            return streamWithSideEffect
                .scan(-1) { count, _ in count + 1 } // index of presenting photo
        }
    }
}
