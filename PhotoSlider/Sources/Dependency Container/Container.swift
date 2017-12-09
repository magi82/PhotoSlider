//
//  Container.swift
//  PhotoSlider
//
//  Created by Dooho Chang on 2017. 12. 8..
//  Copyright © 2017년 Dooho Chang. All rights reserved.
//

import Moya

// Simple dependency registration without external DI Frameworks
class Container {
    // Register singleton dependencies
    private lazy var flickrPhotoRepository: FlickrPhotoRepository
        = FlickrPhotoRepositoryImpl(
            apiProvider: MoyaProvider<FlickrAPI>()
        )
    
    private lazy var imageRepository: ImageRepository
        = ImageRepositoryImpl(
            imageProvider: MoyaProvider<ImageTarget>()
        )
    
    private lazy var photoService: PhotoService
        = PhotoServiceImpl(
            filckrPhotoRepository: flickrPhotoRepository,
            imageRepository: imageRepository
        )
}
