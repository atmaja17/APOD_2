//
//  FavoriteTableCell.swift
//  APOD
//
//  Created by Atmaja Kadam on 2022/03/20.
//  Copyright © 2022 my. All rights reserved.
//

import Foundation
import UIKit
protocol FavCellDelegate {
    func didDeleteApod(item: String)
}
class FavoriteTableCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    var delegate: FavCellDelegate?
    var item: String?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    func setFavData(model: String){
        self.title.text = model
        item = model
    }
    
    @IBAction func deleteFromFavorite(_ sender: Any) {
        guard let item = item else { return }
        delegate?.didDeleteApod(item: item)
    }
    
}
