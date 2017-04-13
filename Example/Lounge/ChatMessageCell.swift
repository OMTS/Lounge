//
//  ChatMessageCell.swift
//  chatTemplateDemo
//
//  Created by Eddy Claessens on 16/12/15.
//  Copyright © 2015 OMTS. All rights reserved.
//

import UIKit

struct MessageCellValues {
    
    // label font
    static let labelFontName = "Helvetica-Light"
    static let labelFontSize : CGFloat = 14
}

class ChatMessageCell: UITableViewCell {

    @IBOutlet weak var textLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        textLB.font = UIFont(name: MessageCellValues.labelFontName, size: MessageCellValues.labelFontSize)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
