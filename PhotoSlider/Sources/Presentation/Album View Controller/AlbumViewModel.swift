//
//  AlbumViewModel.swift
//  PhotoSlider
//
//  Created by Dooho Chang on 2017. 12. 9..
//  Copyright © 2017년 Dooho Chang. All rights reserved.
//

import RxSwift
import RxCocoa

protocol AlbumViewModel: AlbumViewControllerBindable {}

class AlbumViewModelImpl: AlbumViewModel {
    private let disposeBag = DisposeBag()
    
    let photoSliderViewModel: PhotoSliderViewBindable
    
    enum Event {
        case reload
        case photos([Photo])
    }
    private let events = PublishSubject<Event>() // unique mutable state of AlbumViewModelImpl
    
    // View Actions
    var viewDidAppear = PublishSubject<Void>()
    
    init(
        photoSliderViewModel: PhotoSliderViewModel,
        photoService: PhotoService
    ) {
        self.photoSliderViewModel = photoSliderViewModel
        
        let shouldReload = events.filterReloadEvent()
        let photosLoaded = events.filterPhotosEvent()
        
        let implementation = AlbumViewModelImpl.self
        
        // Events generate future events
        implementation
            .generateEvents(
                fromReloadEvents: shouldReload,
                photoService: photoService
            )
            .bind(to: events)
            .disposed(by: disposeBag)
        
        implementation
            .generateEvents(
                fromPhotosEvents: photosLoaded,
                photoSliderViewModel: photoSliderViewModel
            )
            .bind(to: events)
            .disposed(by: disposeBag)
        
        // First viewDidAppear starts event
        viewDidAppear
            .take(1)
            .do(onNext: { [events] in events.onNext(.reload) })
            .subscribe()
            .disposed(by: disposeBag)
    }
}

extension AlbumViewModelImpl {
    private static let remainingThreshold = 3

    class func generateEvents(
        fromReloadEvents reload: Observable<Void>,
        photoService: PhotoService
    ) -> Observable<Event> {
        return reload
            .flatMap { _ -> Single<Event> in
                photoService.getPhotos()
                    .map { Event.photos($0) }
                    .catchError { _ in .just(.reload) } // retry when service errored
            }
    }
    
    class func generateEvents(
        fromPhotosEvents photos: Observable<[Photo]>,
        photoSliderViewModel: PhotoSliderViewModel
    ) -> Observable<Event> {
        return photos
            .concatMap { photos -> Observable<Event> in
                let remainingCountToReload = min(remainingThreshold, photos.count - 1)
                
                return photoSliderViewModel.present(photos: photos)
                    .filter { $0 == remainingCountToReload }
                    .map { _ in Event.reload }
            }
    }
}

extension Observable where Element == AlbumViewModelImpl.Event {
    func filterReloadEvent() -> Observable<Void> {
        return self.flatMap { event -> Observable<Void> in
            if case .reload = event { return .just(Void()) }
            return .empty()
        }
    }
    
    func filterPhotosEvent() -> Observable<[Photo]> {
        return self.flatMap { event -> Observable<[Photo]> in
            if case let .photos(photos) = event { return .just(photos) }
            return .empty()
        }
    }
}
