//
//  tableViewOnline.swift
//  ZingMp3
//
//  Created by Pham Ngoc Hai on 1/5/17.
//  Copyright © 2017 pnh. All rights reserved.
//

import UIKit
let kDOCUMENT_DIRECTORY_PATH =  NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true).first
class tableViewOnline: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var myTableView: UITableView!
    var listSong = [Song]()
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
    }
    func getData()
    {
        let data  =  try? Data(contentsOf: URL(string: "http://mp3.zing.vn/bang-xep-hang/bai-hat-Viet-Nam/IWZ9Z08I.html")!)
        //        print(String(data: data! as Data, encoding: String.Encoding.utf8)!)
        let doc = TFHpple(htmlData: data)
        if let elements = doc?.search(withXPathQuery: "//h3[@class='title-item']/a") as? [TFHppleElement]
        {
            for element in elements
            {
                DispatchQueue.global(qos: .default).async(execute: {
                    let id = self.getID(path: element.object(forKey: "href") as NSString)
                    let url = URL(string: "http://api.mp3.zing.vn/api/mobile/song/getsonginfo?keycode=fafd463e2131914934b73310aa34a23f&requestdata={\"id\":\"\(id)\"}".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
                    var stringData = ""
                    do {
                        stringData =  try String(contentsOf: url!)               }
                    catch let err as NSError
                    {
                        print(err)
                    }
                                    print(url!)
                    let json = self.convertStringtoDictionary(string: stringData)
                    if (json != nil)
                    {
                        self.addSongtoList(json: json!)
                    }
                    
                })
            }
        }
        
    }
    func getID(path: NSString ) -> NSString
        
    {
        let id = (path.lastPathComponent as NSString).deletingPathExtension
        return id as NSString
    }
    func convertStringtoDictionary(string : String) -> [String: AnyObject]?
    {
        if let data = string.data(using: String.Encoding.utf8)
        { do {
            let json =  try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject]
            return json!
        } catch {
            print("Something went wrong")
            }
        }
        return nil
    }
    func addSongtoList(json: [String: AnyObject])
    {
        let title = json["title"] as! String
        let artistName = json["artist"] as! String
        let thumbnail = json["thumbnail"] as! String
        let source = json["source"]!["128"] as! String
        let lyric = json["lyrics_file"] as! String
        print(lyric)
        let currentSong = Song(title: title, artistName: artistName, thumbnail: thumbnail, source: source, lyrics: lyric)
            listSong.append(currentSong)
        DispatchQueue.main.async {
            self.myTableView.reloadData()
        }
        
    }
    func downloadSong(_ index: Int)
    {
        let dataSong = try? Data(contentsOf: URL(string:listSong[index].sourceOnline)!)
        if let dir = kDOCUMENT_DIRECTORY_PATH {
            //writing
            let pathToWriteSong = "\(dir)/\(listSong[index].title)"
            do {
                try FileManager.default.createDirectory(atPath: pathToWriteSong, withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError {
                print(error.localizedDescription);
            }
            
            writeDatatoPath(data: dataSong! as NSObject, path: "\(pathToWriteSong)/\(listSong[index].title).mp3")
            writeInfoSong(song: listSong[index], path: pathToWriteSong)
            
        }
        
    }
    
    
    func writeDatatoPath(data: NSObject, path: String)
        
    {
        if let dataToWrite = data as? NSData
        {
            try? dataToWrite.write(to: URL(fileURLWithPath: path), options: [.atomic])
            
        }
        else if let datainfro = data as? NSDictionary {
            datainfro.write(toFile: path, atomically: true)
        }
        
        
    }
    func writeInfoSong(song: Song , path: String)
        
    {
        // thao tac voi Plist
        let dictData = NSMutableDictionary()
        dictData.setValue(song.title, forKey: "title")
        dictData.setValue(song.artistName, forKey: "artistName")
        dictData.setValue("/\(song.title)/thumbnail.png", forKey: "localThumbnail")
        print("/\(song.title)/thumbnail.png")
        dictData.setValue(song.sourceOnline, forKey: "sourceOnline")
        dictData.setValue(song.lyric, forKey: "lyrics_file")

        //writing info
        writeDatatoPath(data: dictData, path: "\(path)/info.plist")
        // writing thumbnail
        let dataThumbnail = NSData(data: UIImagePNGRepresentation(song.thumbnail)!)
        
        writeDatatoPath(data: dataThumbnail, path: "\(path)/thumbnail.png")
        
        
        var returnString = "Không có lời. Ahihi"
        if song.lyric != "" {
            let url = URL(string: song.lyric)!
            //            returnString = try! String(contentsOf: url, encoding: NSUTF8StringEncoding)
            returnString = try! String(contentsOf: url, encoding: String.Encoding.utf8)
            print(url)
        }
        
        // download + write to file
        
        do {
            
            try returnString.write(toFile: "\(path)/lyrics_file.txt", atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("xyz")
        }}
    
    

    
    // UItableViewDelegate
    //    func numberOfSections(in tableView: UITableView) -> Int {
    //        return listSong.count
    //
    //    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.imageView?.image = listSong[indexPath.row].thumbnail
        cell.textLabel?.text = "\(listSong[indexPath.row].title) Ca Sỹ: \(listSong[indexPath.row].artistName)"

        cell.textLabel?.textColor = UIColor.white
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listSong.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let audioPlayer = AudioPlayer.sharedInstance
        audioPlayer.pathString = listSong[indexPath.row].sourceOnline
        audioPlayer.titleSong = "\(listSong[indexPath.row].title) Ca sy: \(listSong[indexPath.row].artistName)"
        audioPlayer.setupAudio()
        
        NotificationCenter.default.post(name:  Notification.Name(rawValue: "setUpObjAudio"), object: nil)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let edit  = UITableViewRowAction(style: .normal, title: "Download") {
            action, index in
            DispatchQueue.global(qos: .default).async(execute: {
                self.downloadSong(indexPath.row)
                
            })
            self.myTableView.reloadData()
            
        }
        edit.backgroundColor = UIColor(red: 248/255, green: 55/255, blue: 186/255, alpha: 1.0)
        return [edit]
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
