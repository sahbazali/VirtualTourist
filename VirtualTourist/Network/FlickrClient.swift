//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Ali Şahbaz on 31.01.2021.
//

import Foundation

public protocol FlickrClientProtocol {
    func searchByLatLon(latitude: Double,longitude: Double, pageCount: Int, completion:@escaping (Result<FlickrSearchPhotosResponseModel, Error>) -> Void)
}

public class FlickrClient: FlickrClientProtocol{
    
    class func sharedinstance() -> FlickrClient {
        struct Singleton {
            static var sharedinstance = FlickrClient()
        }
        return Singleton.sharedinstance
    }
    
    private init() {}
    
    public func searchByLatLon(latitude: Double, longitude: Double, pageCount: Int, completion: @escaping (Result<FlickrSearchPhotosResponseModel, Error>) -> Void) {
        NetworkManager.request(endpoint: FlickrEndpoint.searchByLatLon(latitude: latitude, longitude: longitude, pageCount: pageCount), loginResponseParse: true) { (result: Result<FlickrSearchPhotosResponseModel, Error>) in
            switch result {
            case.success(let response):
                completion(.success(response))
            case.failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
}
