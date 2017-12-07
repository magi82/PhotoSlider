//
//  FlickrPhotoRepository.swift
//  PhotoSlider
//
//  Created by Dooho Chang on 2017. 12. 7..
//  Copyright © 2017년 Dooho Chang. All rights reserved.
//

import RxSwift

protocol FlickrPhotoRepository {
    func getPublicPhotos() -> Single<[FlickrPhoto]>
}

struct FlickrPhoto {
    // Required
    let title: String
    let imageURL: URL
    
    // Optional
    let description: String?
}

enum FlickrPhotoRepositoryError: Error {
    case invalidStatusCode(Int)
    case jsonParsingError
}
