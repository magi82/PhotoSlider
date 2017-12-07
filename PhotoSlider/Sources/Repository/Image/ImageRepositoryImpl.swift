//
//  ImageRepositoryImpl.swift
//  PhotoSlider
//
//  Created by Dooho Chang on 2017. 12. 7..
//  Copyright © 2017년 Dooho Chang. All rights reserved.
//

import RxSwift
import Moya

class ImageRepositoryImpl: ImageRepository {
    let imageProvider: MoyaProvider<ImageTarget>
    
    init(imageProvider: MoyaProvider<ImageTarget>) {
        self.imageProvider = imageProvider
    }
    
    func loadImage(from url: URL) -> Single<UIImage> {
        return Single.deferred {
            self.imageProvider
                .rx.request(.loadImage(url: url))
                .map { try $0.mapImage() }
        }
    }
}
