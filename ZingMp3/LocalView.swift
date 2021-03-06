//
//  LocalView.swift
//  ZingMp3
//
//  Created by Pham Ngoc Hai on 1/6/17.
//  Copyright © 2017 pnh. All rights reserved.
//

import UIKit

class LocalView: UIViewController, UITableViewDelegate, UITableViewDataSource, ParseLyric {
    var listSong = [Song]()
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var txtfield_lyric: UITextView!
    @IBOutlet weak var myTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        blurView.isHidden = true
        txtfield_lyric.isHidden = true
        getData()
        
        
        
    }
    // Do any additional setup after loading the view.
    override func viewWillAppear(_ animated: Bool  )
    {   getData()
        myTableView.reloadData()
    }
    func getData()
    {
        listSong.removeAll()
        if let dir = kDOCUMENT_DIRECTORY_PATH
        {
            do {
                let folders = try FileManager.default.contentsOfDirectory(atPath: dir)
                for folder in folders
                {
                    if folder != ".DS_Store"
                    {
                        let info = NSDictionary(contentsOfFile: dir+"/"+folder+"/"+"info.plist")
                        let title = info!["title"] as! String
                        let artistName = info!["artistName"] as! String
                        let thumbnail = info!["localThumbnail"] as! String
                        let thumbNailPath = dir + thumbnail
                        let sourceLocal = dir + "/\(title)/\(title).mp3"
                        var lyric = info!["lyric"] as! String
                        if lyric == "" {
                        
                        let returnLyric = "DD co loi"
                            lyric = returnLyric
//                            print(lyric)
                        }
                        else{
//                         print(lyric)
                        }
                        let currentSong = Song(title: title, artistName: artistName, localThumbnail: thumbNailPath, localSource: sourceLocal, lyrics: lyric)
                        listSong.append(currentSong)
                    }
                }
                myTableView.reloadData()
                
            } catch let  err as NSError
            {
                print(err)
            }
            
        }
    }
    func lyric(_ audioPlayer: AudioPlayer) {
        
        blurView.isHidden = !blurView.isHidden
        txtfield_lyric.isHidden = !txtfield_lyric.isHidden
        
        txtfield_lyric.text = audioPlayer.lyric
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listSong.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.imageView?.image = listSong[indexPath.row].thumbnail
        cell.textLabel?.text = listSong[indexPath.row].title
        cell.textLabel?.textColor = UIColor.white
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let audioPlay = AudioPlayer.sharedInstance
        audioPlay.pathString = listSong[indexPath.row].sourceLocal
        audioPlay.titleSong = listSong[indexPath.row].title + "(\(listSong[indexPath.row].artistName))"
        audioPlay.generalListSongs = listSong
        
    audioPlay.songPosition = indexPath.row
        audioPlay.isLocalSong = true
        audioPlay.setupInfo()
        audioPlay.setupAudio()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "setUpObjAudio"), object: nil)
        
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let edit  = UITableViewRowAction(style: .normal, title: "Delete") {
            action, index in
            self.removeSongAtIndexPath(index: indexPath.row)
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "setUpObjAudio"), object: nil)
        }
        edit.backgroundColor = UIColor(red: 248/255, green: 55/255, blue: 186/255, alpha: 1.0)
        return [edit]
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func removeSongAtIndexPath(index: Int)
    {
        if let dir = kDOCUMENT_DIRECTORY_PATH
        {
            do{
                let path  = "/\(dir)/\(listSong[index].title)"
                try FileManager.default.removeItem(atPath: path)
                listSong.remove(at: index)
                self.myTableView.reloadData()
                
            } catch let err as NSError
            {
                print(err)
                
            }
            
            
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FuckYou"{
            let audioPlayerView = segue.destination as! AudioPlayerView
            audioPlayerView.lyricDelegate = self //B6: Khởi tạo lyricDelegate, gán bằng self, self ở đây chính là class TableViewOnline đã tuân thủ delegate ParseLyric bên trên. Finish. Tìm 1 tutorial về delegate mà đọc, bài này khó hiểu vì sử dụng embed UIVIewController trong UIView. Tìm 1 bài ViewControllerA push sang ViewControllerB ấy
        }
    }
    
    
    
}
