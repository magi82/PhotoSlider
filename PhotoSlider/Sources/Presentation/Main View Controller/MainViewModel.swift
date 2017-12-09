//
//  MainViewModel.swift
//  PhotoSlider
//
//  Created by Dooho Chang on 2017. 12. 9..
//  Copyright © 2017년 Dooho Chang. All rights reserved.
//

import RxSwift
import RxCocoa
import RxOptional

protocol MainViewModel: MainViewControllerBindable {}

class MainViewModelImpl: MainViewModel {
    let container: ContainerForMainViewModel
    
    // View states
    let durationValueLabelText: Driver<String?>
    let presentAlbum: Signal<AlbumViewControllerBindable>
    
    // View actions
    let increaseButtonTapped = PublishSubject<Void>()
    let decreaseButtonTapped = PublishSubject<Void>()
    let enterButtonTapped = PublishSubject<Void>()
    
    init(
        initialPhotoDuration: Double,
        container: ContainerForMainViewModel
    ) {
        self.container = container
        
        let increase = increaseButtonTapped.map { Double(+0.5) }
        let decrease = decreaseButtonTapped.map { Double(-0.5) }
        
        let duration = Observable.merge(increase, decrease)
            .scan(initialPhotoDuration) { duration, add in
                max(min(duration + add, 10), 1)
            }
            .startWith(initialPhotoDuration)
            .share(replay: 1, scope: .whileConnected)
        
        self.durationValueLabelText = duration
            .map { "\($0) 초" }
            .asDriver(onErrorDriveWith: .empty())
        
        let presentAlbumViewModel = enterButtonTapped
            .withLatestFrom(duration)
            .map { container.albumViewModel(photoDuration: $0) }
            .share()
        
        let dismissAlbumViewModel = presentAlbumViewModel
            .flatMapLatest { $0.dismiss } // AlbumViewModel will be dellocated after this signal
        
        let currentAlbumViewModel = Observable
            .merge(
                presentAlbumViewModel.map { $0 as AlbumViewModel? },
                dismissAlbumViewModel.map { AlbumViewModel?.none }
            )
            .share(replay: 1, scope: .whileConnected)
        
        self.presentAlbum = currentAlbumViewModel
            .filterNil()
            .map { $0 as AlbumViewControllerBindable }
            .asSignal(onErrorSignalWith: .empty())
    }
}
