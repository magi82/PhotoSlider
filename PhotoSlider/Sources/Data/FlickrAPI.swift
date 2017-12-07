//
//  FlickrAPI.swift
//  PhotoSlider
//
//  Created by Dooho Chang on 2017. 12. 7..
//  Copyright © 2017년 Dooho Chang. All rights reserved.
//

import Moya

enum FlickrAPI: TargetType {
    case getPublicPhotos
    
    var baseURL: URL {
        return .flickrBaseURL
    }
    
    var path: String {
        switch self {
        case .getPublicPhotos:
            return "/services/feeds/photos_public.gne"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        return .requestParameters(
            parameters: [
                "format": "json",
                "nojsoncallback": "1"
            ],
            encoding: URLEncoding.default
        )
    }
    
    var headers: [String: String]? {
        return nil
    }
}
