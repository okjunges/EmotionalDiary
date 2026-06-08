//
//  EmotionStatCell.swift
//  EmotionalDiary
//
//  Created by 김완수 on 5/17/26.
//

import UIKit

class EmotionStatCell: UITableViewCell {

    @IBOutlet weak var innerView: UIView!

    @IBOutlet weak var emotionImageView: UIImageView!
    @IBOutlet weak var emotionTitleLabel: UILabel!

    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none

        innerView.layer.cornerRadius = 18
        innerView.clipsToBounds = true

        innerView.layer.borderWidth = 1
        innerView.layer.borderColor = UIColor(named: "LightTextColor")?.cgColor ?? UIColor.lightGray.cgColor

        progressView.transform = CGAffineTransform(scaleX: 1, y: 4)

        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
    }

    func configure(stat: EmotionStat) {

        emotionImageView.image = UIImage(
            named: stat.emotion.imageName
        )

        emotionTitleLabel.text = stat.emotion.title

        let percentText = "\(Int(stat.percent * 100))%"
        percentLabel.text = percentText

        progressView.progress = Float(stat.percent)
    }
}
