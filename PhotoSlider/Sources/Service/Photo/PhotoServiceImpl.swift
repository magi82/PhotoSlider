//
//  PhotoServiceImpl.swift
//  PhotoSlider
//
//  Created by Dooho Chang on 2017. 12. 8..
//  Copyright © 2017년 Dooho Chang. All rights reserved.
//

import RxSwift

class PhotoServiceImpl: PhotoService {
    
    let filckrPhotoRepository: FlickrPhotoRepository
    let imageRepository: ImageRepository
    
    init(
        filckrPhotoRepository: FlickrPhotoRepository,
        imageRepository: ImageRepository
    ) {
        self.filckrPhotoRepository = filckrPhotoRepository
        self.imageRepository = imageRepository
    }
    
    func getPhotos() -> Observable<Photo> {
        return Observable.deferred {
            self.filckrPhotoRepository
                .getPublicPhotos()
                .asObservable()
                .flatMap { flickrPhotos -> Observable<Photo> in
                    let loadPhotoRequests = flickrPhotos
                        .map { flickrPhoto -> Observable<Photo> in
                            self.loadPhoto(from: flickrPhoto)
                                .asObservable()
                                .catchError { _ in .empty() } // 개별 이미지 로드가 실패하더라도 에러를 발생시키지 않는다.
                        }
                    
                    return Observable.merge(loadPhotoRequests)
                }
        }
    }
    
    private func loadPhoto(from flickrPhoto: FlickrPhoto) -> Single<Photo> {
        return imageRepository
            .loadImage(from: flickrPhoto.imageURL)
            .map { image -> Photo in
                Photo(
                    title: flickrPhoto.title,
                    image: image,
                    description: flickrPhoto.description
                )
            }
    }
}
