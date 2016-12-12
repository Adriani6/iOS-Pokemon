//
//  UImageExtension.swift
//  iOS_CW
//
//  Created by ADRIAN IWASZKIEWICZ (1502689) on 07/12/2016.
//  Copyright © 2016 ADRIAN IWASZKIEWICZ (1502689). All rights reserved.
//
// THIS CLASS EXTENSION IS NO LONGER NEEDED AS TIME DID NOT ALLOW FOR FULL IMPLEMENTATION AND CODE WAS REPEATED 3 TIMES IN TOTAL FOR THAT FACT.

import Foundation
import UIKit

extension UIImageView {
    func getDataFromUrl(url:String, completion: ((data: NSData?) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: url)!) { (data, response, error) in
            completion(data: NSData(data: data!))
            }.resume()
    }
    
    func downloadImage(url:String){
        getDataFromUrl(url) { data in
            dispatch_async(dispatch_get_main_queue()) {
                self.contentMode = UIViewContentMode.ScaleAspectFill
                self.image = UIImage(data: data!)
            }
        }
    }
}