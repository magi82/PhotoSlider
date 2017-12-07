//
//  URL.swift
//  PhotoSlider
//
//  Created by Dooho Chang on 2017. 12. 7..
//  Copyright © 2017년 Dooho Chang. All rights reserved.
//

import Foundation

extension URL {
    // Register constant with extension
    static var flickrBaseURL: URL {
        return URL(string: "https://api.flickr.com")!
    }
}
