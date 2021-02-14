//
//  FlickrSearchPhotosResponseModel.swift
//  VirtualTourist
//
//  Created by Ali Şahbaz on 4.02.2021.
//

import Foundation

public struct FlickrSearchPhotosResponseModel: Codable {
    let photos: Photos
}

public struct Photos: Codable {
    let pages: Int
    let photo: [PhotoModel]
}

public struct PhotoModel: Codable {
    
    let url: String?
    let title: String
    
    enum CodingKeys: String, CodingKey {
        case url = "url_m"
        case title
    }
}
