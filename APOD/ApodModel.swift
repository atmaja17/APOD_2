//
//  ApodModel.swift
//  APOD
//
//  Created by Atmaja Kadam on 2022/03/19.
//  Copyright © 2022 my. All rights reserved.
//

import Foundation
import UIKit

struct Apod : Codable{
    var title: String = ""
    var explanation: String = ""
    var date: String = ""
    var url: String?
}
class ApodViewModel: NSObject {
    var apod = Apod()
    
    func hitRequestWithParameter(param:[String:String]?, success:@escaping (Apod) -> Void, failure:@escaping(Error?) -> Void ) {
        NetworkManager.sharedInstance.hitRequestWithParameter(param: param) { (bool, response, error) in
        if bool {
            do {
                let jsonDic =  try JSONDecoder().decode(Apod.self, from: response as! Data)
                DispatchQueue.main.async {
                    print(jsonDic)
                    self.apod = jsonDic
                    success(self.apod)
                }
            } catch {
                print("caught in apod viewmodel")
            }
        }else {
            failure(error)
        }
      }
    }
    func getModelForCoredata() -> Apod{
        return self.apod
    }
}

