//
//  FavoriteViewController.swift
//  APOD
//
//  Created by Atmaja Kadam on 2022/03/19.
//  Copyright © 2022 my. All rights reserved.
//

import UIKit

class FavoriteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FavCellDelegate {


    @IBOutlet weak var favTableView: UITableView!
    var favList = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        favList = UserDefaults.standard.array(forKey: "favList") as! [String]

            favTableView.delegate = self
            favTableView.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        favList = UserDefaults.standard.array(forKey: "favList") as! [String]
        favTableView.reloadData()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favList.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favCell") as! FavoriteTableCell
        cell.setFavData(model: favList[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func didDeleteApod(item: String) {
        for index in 0..<favList.count{
            let apod = favList[index]
            if (apod == item){
                favList.remove(at: index)
                UserDefaults.standard.setValue(favList, forKeyPath: "favList")
                break
            }
        }
        favTableView.reloadData()
    }
    

}
