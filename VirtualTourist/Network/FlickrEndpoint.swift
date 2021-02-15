//
//  FlickrEndpoint.swift
//  VirtualTourist
//
//  Created by Ali Şahbaz on 31.01.2021.
//

import Foundation

enum FlickrEndpoint: ApiProtocol {
    case searchByLatLon(latitude: Double, longitude: Double, pageCount: Int)
    
    var apiKey: String {
        switch self {
            default: return ""
        }
    }
    
    var scheme: String {
        switch self {
            default: return Constants.Flickr.APIScheme
        }
    }
    
    var baseURL: String {
        switch self {
            default: return Constants.Flickr.APIHost
        }
    }
    
    var path: String {
        switch self {
        case.searchByLatLon:
            return Constants.Flickr.APIPath
        }
    }
    
    var parameters: [URLQueryItem]? {
        switch self {
        case .searchByLatLon(let latitude, let longitude, let pageCount):
            var page: Int {
                let page = min(pageCount, 4000/Constants.FlickrParameterValues.PhotosPerPage)
                return Int(arc4random_uniform(UInt32(page)) + 1)
            }
            var bboxString : String {
                    let minimumLon = max(longitude - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
                    let minimumLat = max(latitude - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.0)
                    let maximumLon = min(longitude + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
                    let maximumLat = min(latitude + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
                    return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
            }
            let parameters : [String: Any] = [
                Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
                Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
                Constants.FlickrParameterKeys.BoundingBox: bboxString,
                Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
                Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
                Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
                Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback,
                Constants.FlickrParameterKeys.PhotosPerPage: Constants.FlickrParameterValues.PhotosPerPage,
                Constants.FlickrParameterKeys.Page : "\(page)"
            ]
            var queryItems : [URLQueryItem] = []
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                queryItems.append(queryItem)
            }
            return queryItems
        }
    }
    
    var body: Data? {
        switch self {
        case .searchByLatLon:
            return nil
        }
    }
    
    var headers: [HTTPHeader]? {
        switch self {
        case .searchByLatLon:
            return nil
        }
    }
    
    var method: String {
        switch self {
        case .searchByLatLon:
            return "GET"
        }
    }
}

func getRandomPageNumber(totalPicsAvailable: Int, maxNumPicsdisplayed: Int) -> Int {
    let flickrLimit = 4000
    // Available total number of pics or flickr limit
    let numberPages = min(totalPicsAvailable, flickrLimit) / maxNumPicsdisplayed
    let randomPageNum = Int.random(in: 0...numberPages)
    print("totalPicsAvaible is \(totalPicsAvailable), numPage is \(numberPages)",
         "randomPageNum is \(randomPageNum)" )
    
    return randomPageNum
}
