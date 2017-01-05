//
//  tableViewOnline.swift
//  ZingMp3
//
//  Created by Pham Ngoc Hai on 1/5/17.
//  Copyright © 2017 pnh. All rights reserved.
//

import UIKit

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
                //                print(stringData)
                let json = self.convertStringtoDictionary(string: stringData)
                if (json != nil)
                {
                    self.addSongtoList(json: json!)
                }
                 
                })
            }
        }
        
                }
    func getID(path: NSString ) -> String
    {
        let id = (path.lastPathComponent as NSString).deletingPathExtension
        return id
        
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
        
        let currentSong = Song(title: title, artistName: artistName, thumbnail: thumbnail, source: source)
        listSong.append(currentSong)
        DispatchQueue.main.async {
            self.myTableView.reloadData()
        }
        
}
// UItableViewDelegate
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return listSong.count
//        
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.imageView?.image = listSong[indexPath.row].thumbnail
        cell.textLabel?.text = listSong[indexPath.row].title
        cell.textLabel?.textColor = UIColor.white
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listSong.count
    }
}
