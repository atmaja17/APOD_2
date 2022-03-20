//
//  NetworkManager.swift
//  APOD
//
//  Created by Atmaja Kadam on 2022/03/19.
//  Copyright © 2022 my. All rights reserved.
//

import Foundation
import UIKit

final class NetworkManager: NSObject, URLSessionDelegate{
    var sessionConfiguration:URLSessionConfiguration?
    var session:URLSession?
    var url:URL?
    
    static let sharedInstance = NetworkManager()
    
    override init() {
        super.init()
        sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration?.timeoutIntervalForRequest = 120.0
        sessionConfiguration?.urlCache = nil
        session = URLSession(configuration:sessionConfiguration!, delegate:self, delegateQueue:nil)
    }
    func setupURL(param: [String: String]?){
        url = URL.init(string: URLAPI)
        var queryItems = [URLQueryItem(name: "api_key", value: DEMO_KEY)]
        if let parameters = param{
            queryItems.append(URLQueryItem(name: "date", value: parameters["date"]))
        }
        var urlComps = URLComponents(string: URLAPI)
        urlComps?.queryItems = queryItems
        url = urlComps?.url
    }

    func hitRequestWithParameter(param:[String:String]?, completion:@escaping (Bool,Any,Error?) -> Void ) {
        
        setupURL(param: param)
        let request = URLRequest.init(url: url!)

        let task = session?.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                completion(false,response as Any,error!)
                return
            }
            completion(true,data,error)
        }
        task?.resume()
    }
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if challenge.protectionSpace.host == "api.nasa.gov" {
                let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
                completionHandler(URLSession.AuthChallengeDisposition.useCredential, credential)
            }
        }
    }
   
}
