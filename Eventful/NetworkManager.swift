//
//  NetworkManager.swift
//  Eventful
//
//  Created by Amy Chin Siu Huang on 5/14/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import Foundation
import Alamofire

class NetworkManager {
    
    static func getImage(imageURL: String, completion: @escaping((UIImage) -> Void)) {
        AF.request(imageURL, method: .get).validate().responseData { (response) in
            switch response.result {
            case .success(let data):
                if let image = UIImage(data: data) {
                    completion(image)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
