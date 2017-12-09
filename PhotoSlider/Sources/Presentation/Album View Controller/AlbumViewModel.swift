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
    
    // View Actions
    var viewDidAppear = PublishSubject<Void>()
    
    init(
        photoDuration: Double,
        photoSliderViewModel: PhotoSliderViewModel,
        photoService: PhotoService
    ) {
        self.photoSliderViewModel = photoSliderViewModel
        
        let loadMorePhotos = viewDidAppear
        
        let loadedPhotos = loadMorePhotos
            .flatMap { photoService.getPhotos() }
        
        loadedPhotos
            .flatMapFirst {
                photoSliderViewModel.present(photos: $0)
            }
            .subscribe()
            .disposed(by: disposeBag)
    }
}
