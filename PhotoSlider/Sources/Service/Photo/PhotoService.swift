//
//  PhotoService.swift
//  PhotoSlider
//
//  Created by Dooho Chang on 2017. 12. 8..
//  Copyright © 2017년 Dooho Chang. All rights reserved.
//

import RxSwift

protocol PhotoService {
    func getPhotos() -> Observable<Photo> // get public photo stream from flickr
}

struct Photo {
    let title: String
    let image: UIImage
    let description: String?
}
