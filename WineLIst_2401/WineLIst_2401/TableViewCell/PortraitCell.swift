//
//  TableViewCell.swift
//  T3
//
//  Created by Seokhyun Song on 2023/01/19.
//

import UIKit

class PortraitCell: UITableViewCell {

    static let identifier = "PortraitCell"
    static func nib() -> UINib {
        return UINib(nibName: "PortraitCell", bundle: nil)
    }

    @IBOutlet weak var korNameLabel: UILabel!
    @IBOutlet weak var engNameLabel: UILabel!
    @IBOutlet weak var provinceLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
