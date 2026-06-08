//
//  EmotionRecordCell.swift
//  EmotionalDiary
//
//  Created by 김완수 on 5/16/26.
//

import UIKit

class EmotionRecordCell: UITableViewCell {

    @IBOutlet weak var cardView: UIView!

    @IBOutlet weak var timeSlotLabel: UILabel!
    @IBOutlet weak var emotionImageView: UIImageView!

    @IBOutlet weak var emotionTitleLabel: UILabel!
    @IBOutlet weak var intensityLabel: UILabel!
    @IBOutlet weak var lblArrow: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none

        cardView.layer.cornerRadius = 15
        cardView.clipsToBounds = true
        
        lblArrow.layer.cornerRadius = 15
        lblArrow.clipsToBounds = true
    }

    func configure(record: EmotionRecord) {

        timeSlotLabel.text = record.timeSlot.title

        emotionImageView.image = UIImage(
            named: record.emotion.imageName
        )

        emotionTitleLabel.text = record.emotion.title

        intensityLabel.text = "강도 \(record.intensity)/5"
    }
}
