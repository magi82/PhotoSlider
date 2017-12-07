//
//  FlickrRepositoryImpl.swift
//  PhotoSlider
//
//  Created by Dooho Chang on 2017. 12. 7..
//  Copyright © 2017년 Dooho Chang. All rights reserved.
//

import RxSwift
import Moya
import SwiftyJSON

class FlickrRepositoryImpl: FlickrRepository {
    let apiProvider: MoyaProvider<FlickrAPI>
    
    init(apiProvider: MoyaProvider<FlickrAPI>) {
        self.apiProvider = apiProvider
    }
    
    func getPublicPhotos() -> Single<[FlickrPhoto]> {
        return apiProvider
            .rx.request(.getPublicPhotos)
            .map { response -> [FlickrPhoto] in
                guard (200 ..< 300) ~= response.statusCode else {
                    throw FlickrRepositoryError.invalidStatusCode(response.statusCode)
                }
                
                return try self.parsePhotos(from: response.data)
            }
    }
    
    private func parsePhotos(from data: Data) throws -> [FlickrPhoto] {
        let json = try JSON(data: data)
        guard let jsonPhotos = json["items"].array else { throw FlickrRepositoryError.jsonParsingError }
        
        let photos = jsonPhotos
            .flatMap { self.parsePhoto(from: $0) }
        
        return photos
    }
    
    private func parsePhoto(from json: JSON) -> FlickrPhoto? {
        // generate required properties
        guard let title = json["title"].string,
            let imageURL = json["media"]
                .flatMap({ (key, value) in value.url })
                .first
            else { return nil }
        
        // generate optional description
        let description = json["description"].string

        return FlickrPhoto(
            title: title,
            imageURL: imageURL,
            description: description
        )
    }
}
