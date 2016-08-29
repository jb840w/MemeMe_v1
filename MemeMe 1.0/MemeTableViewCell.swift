//
//  MemeTableViewCell.swift
//  MemeMe 1.0
//
//  Created by 840west on 8/28/16.
//  Copyright © 2016 840west. All rights reserved.
//

import UIKit

class MemeTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // customize imageView like you need
        self.imageView?.frame = CGRectMake(10, 0, 40, 40)
        self.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        // customize other elements
        self.textLabel?.frame = CGRectMake(60, 0, self.frame.width - 45, 20)
        self.detailTextLabel?.frame = CGRectMake(60, 20, self.frame.width - 45, 15)
    }

}
