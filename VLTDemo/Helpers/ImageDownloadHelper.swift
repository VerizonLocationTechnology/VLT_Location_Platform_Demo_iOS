//
//  ImageDownloadHelper.swift
//
// Created by Verizon Location Technology
// Copyright © 2021 Verizon Location Technology
//

import Foundation
import UIKit

class ImageDownloadHelper {
    func getImage(_for url: String, completion: @escaping ((UIImage?) -> Void)) {
        if let url = URL(string: url) {
            let defaultSession = URLSession(configuration: .default)

             let dataTask = defaultSession.dataTask(with: url) { data, response, error in
                // In production, you'll want to provide some better error handling
                if let error = error {
                    OperationQueue.main.addOperation {
                        completion(nil)
                    }
                    DemoError(file: #file, function: #function, line: #line, error: error).print()
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
                    DemoError(file: #file, function: #function, line: #line, message: "Couldn't create image out of data : \(data)").print()
                    completion(nil)
                }
             }
            dataTask.resume()
        }
    }
}
