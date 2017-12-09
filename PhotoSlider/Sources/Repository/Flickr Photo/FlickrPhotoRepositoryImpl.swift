//
//  FlickrPhotoRepositoryImpl.swift
//  PhotoSlider
//
//  Created by Dooho Chang on 2017. 12. 7..
//  Copyright © 2017년 Dooho Chang. All rights reserved.
//

import RxSwift
import Moya
import SwiftyJSON

class FlickrPhotoRepositoryImpl: FlickrPhotoRepository {
    let apiProvider: MoyaProvider<FlickrAPI>
    
    init(apiProvider: MoyaProvider<FlickrAPI>) {
        self.apiProvider = apiProvider
    }
    
    func getPublicPhotos() -> Single<[FlickrPhoto]> {
        return self.apiProvider
            .rx.request(.getPublicPhotos)
            .map { response -> [FlickrPhoto] in
                guard (200 ..< 300) ~= response.statusCode else {
                    throw FlickrPhotoRepositoryError.invalidStatusCode(response.statusCode)
                }
                
                return try self.parsePhotos(from: response)
            }
    }
    
    private func parsePhotos(from response: Response) throws -> [FlickrPhoto] {
        let string = try response.mapString()
        let json = JSON(parseJSON: string)
        guard let jsonPhotos = json["items"].array else {
            throw FlickrPhotoRepositoryError.jsonParsingError(string)
        }
        
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
        
        return FlickrPhoto(
            title: title,
            imageURL: imageURL
        )
    }
}
