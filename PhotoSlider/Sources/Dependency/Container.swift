//
//  Container.swift
//  PhotoSlider
//
//  Created by Dooho Chang on 2017. 12. 8..
//  Copyright © 2017년 Dooho Chang. All rights reserved.
//

import Moya
import Then

// Simple dependency registration without external DI Frameworks
class Container {
    static let instance = Container()
    
    // Register Repository dependencies
    private lazy var flickrPhotoRepository: FlickrPhotoRepository
        = FlickrPhotoRepositoryImpl(
            apiProvider: MoyaProvider<FlickrAPI>()
        )
    
    private lazy var imageRepository: ImageRepository
        = ImageRepositoryImpl(
            imageProvider: MoyaProvider<ImageTarget>()
        )

    // Register Service dependencies
    private lazy var photoService: PhotoService
        = PhotoServiceImpl(
            filckrPhotoRepository: flickrPhotoRepository,
            imageRepository: imageRepository
        )
    
    // Register ViewModel Dependencies
    private func photoSliderViewModel(photoDuration: Double) -> PhotoSliderViewModel {
        return PhotoSliderViewModelImpl(photoDuration: photoDuration)
    }
    
    func albumViewModel(photoDuration: Double) -> AlbumViewModel {
        return AlbumViewModelImpl(
            photoSliderViewModel: photoSliderViewModel(photoDuration: photoDuration),
            photoService: photoService
        )
    }
    
    private lazy var mainViewModel: MainViewModel
        = MainViewModelImpl(
            initialPhotoDuration: 3,
            container: Container.instance
        )
    
    // Register View dependencies
    private func photoSliderView() -> PhotoSliderView {
        return PhotoSliderView()
    }
    
    func albumViewController() -> AlbumViewController {
        return AlbumViewController(
            photoSliderView: photoSliderView()
        )
    }
    
    lazy var mainViewController: MainViewController
        = MainViewController(container: Container.instance)
    
    lazy var rootWindow: UIWindow
        = UIWindow().then {
            let rootViewController = mainViewController
                .then { $0.bind(mainViewModel) }
            $0.rootViewController = rootViewController
        }
}

extension Container: ContainerForMainViewController, ContainerForMainViewModel {}

protocol ContainerForMainViewController {
    func albumViewController() -> AlbumViewController
}

protocol ContainerForMainViewModel {
    func albumViewModel(photoDuration: Double) -> AlbumViewModel
}
