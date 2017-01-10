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
    var lyric = ""
    let baseThumbnail = "http://zmp3-photo.d.za.zdn.vn/"
    init (title: String, artistName: String, thumbnail: String, source: String, lyrics: String)
    {
        self.title = title
        self.lyric = lyrics
//        print(lyrics)
        self.artistName = artistName
        let thumbnailURL = baseThumbnail+thumbnail
        let dataImg = NSData(contentsOf: NSURL(string: thumbnailURL)! as URL)
        self.thumbnail = UIImage(data: dataImg as! Data)!
        self.sourceOnline = source
    }

    
    init(title: String, artistName: String, localThumbnail: String, localSource: String, lyrics: String){
        self.title = title
        self.lyric = lyrics
        self.artistName = artistName
        self.localThumbnail = localThumbnail
//        print(self.localThumbnail)
        let dataImage = NSData(contentsOfFile: self.localThumbnail)
//        print(dataImage)
        self.thumbnail = UIImage(data: dataImage! as Data)!
        
 
        self.sourceLocal = localSource
    }

    
}
