//
//  HistoryTableViewCell.swift
//  Smart Jog
//
//  Created by Beena on 23/10/20.
//  Copyright © 2020 Christy_Beena. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var avarageSpeedLabel: UILabel!
    
    @IBOutlet weak var distanceCoveredLabel: UILabel!
    
    class var identifier:String{
        
        return String(describing: self)
        
    }
    class var nib:UINib{
        
        return UINib(nibName: identifier, bundle: nil)
    }
    
    

    override func awakeFromNib() {
        
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)

    }
    
}
