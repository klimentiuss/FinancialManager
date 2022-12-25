//
//  TransactionTableViewCell.swift
//  FinancesManagerApp
//
//  Created by Daniil Klimenko on 25.12.2022.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {

    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var walletLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
