//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Ali Şahbaz on 25.01.2021.
//

import Foundation

enum FlickrEndpoint: ApiProtocol {
    case searchByLatLon(latitude: Double, longitude: Double)
    
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
        case .searchByLatLon(let latitude, let longitude):
            var bboxString : String {
                    let minimumLon = max(longitude - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
                    let minimumLat = max(latitude - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.0)
                    let maximumLon = min(longitude + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
                    let maximumLat = min(latitude + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
                    return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
            }
            let parameters = [
                Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
                Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
                Constants.FlickrParameterKeys.BoundingBox: bboxString,
                Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
                Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
                Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
                Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
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
