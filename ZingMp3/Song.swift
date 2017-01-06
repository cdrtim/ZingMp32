//
//  Song.swift
//  ZingMp3
//
//  Created by Pham Ngoc Hai on 1/5/17.
//  Copyright © 2017 pnh. All rights reserved.
//

import Foundation
import UIKit
struct Song {
    var title = ""
    var artistName = ""
    var thumbnail: UIImage
    var sourceOnline  = ""
    var sourceLocal = ""
    var localThumbnail  = ""
    let baseThumbnail = "http://zmp3-photo.d.za.zdn.vn/"
    init (title: String, artistName: String, thumbnail: String, source: String)
    {
        self.title = title
        self.artistName = artistName
        let thumbnailURL = baseThumbnail+thumbnail
        let dataImg = NSData(contentsOf: NSURL(string: thumbnailURL)! as URL)
        self.thumbnail = UIImage(data: dataImg as! Data)!
        self.sourceOnline = source
    }

    
    init(title: String, artistName: String, localThumbnail: String, localSource: String){
        self.title = title
        self.artistName = artistName
        self.localThumbnail = localThumbnail
        print(self.localThumbnail)
        let dataImage = NSData(contentsOfFile: self.localThumbnail)
        print(dataImage)
        self.thumbnail = UIImage(data: dataImage! as Data)!
        
 
        self.sourceLocal = localSource
    }

    
}
