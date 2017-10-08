//
//  TargetTableViewCell.swift
//  radAR
//
//  Created by Suvir Copparam on 10/7/17.
//  Copyright © 2017 Olivia Brown. All rights reserved.
//

import UIKit

class TargetTableViewCell: UITableViewCell {
    // MARK: Properties
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var proximityLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
