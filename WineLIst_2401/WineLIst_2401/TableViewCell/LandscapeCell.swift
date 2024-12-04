//
//  DemoTableViewCell.swift
//  T1
//
//  Created by Seokhyun Song on 2022/08/28.
//

import UIKit

class LandscapeCell: UITableViewCell {
    
    static let identifier = "LandscapeCell"
    static func nib() -> UINib {
        return UINib(nibName: "LandscapeCell", bundle: nil)
    }
    
    @IBOutlet weak var korNameLabel: UILabel!
    @IBOutlet weak var engNameLabel: UILabel!
    @IBOutlet weak var provinceLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var grapeLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
