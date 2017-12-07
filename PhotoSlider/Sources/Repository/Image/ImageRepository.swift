//
//  ImageRepository.swift
//  PhotoSlider
//
//  Created by Dooho Chang on 2017. 12. 7..
//  Copyright © 2017년 Dooho Chang. All rights reserved.
//

import RxSwift

protocol ImageRepository {
    func loadImage(from: URL) -> Single<UIImage>
}
