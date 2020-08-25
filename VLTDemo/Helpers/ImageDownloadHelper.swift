//
//  ImageDownloadHelper.swift
//  VLTDemo
//
//  Created by Verizon Location Technology
//  Copyright © 2018 Verizon Location Technology. All rights reserved.
//

import Foundation
import UIKit

class ImageDownloadHelper {
    func getImage(_for url: String, completion: @escaping ((UIImage?) -> Void)) {

        if let url: URL = URL(string: url) {
            let defaultSession = URLSession(configuration: .default)

             let dataTask = defaultSession.dataTask(with: url) { (data, response, error) in
                // In production, you'll want to provide some better error handling
                if let error = error {
                    OperationQueue.main.addOperation {
                        completion(nil)

                    }
                    print(error)
                    return
                }

                // Check for valid data
                guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    completion(nil)
                    return
                }

                if let image = UIImage(data: data) {
                    OperationQueue.main.addOperation {
                        completion(image)
                    }
                } else {
                    print("couldnt create image out of data : \(data)")
                    completion(nil)
                }
            }
            dataTask.resume()
        }
    }
}
