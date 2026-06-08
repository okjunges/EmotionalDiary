//
//  EmotionOptionCell.swift
//  EmotionalDiary
//
//  Created by 김완수 on 5/15/26.
//

import UIKit

final class EmotionOptionCell: UICollectionViewCell {

    @IBOutlet weak var optionImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    func configure(title: String, imageName: String?, isSelected: Bool) {
        titleLabel.text = title

        if let imageName = imageName {
            optionImageView.image = UIImage(named: imageName)
            optionImageView.isHidden = false
        } else {
            optionImageView.image = nil
            optionImageView.isHidden = true
        }

        contentView.layer.cornerRadius = 10
        contentView.layer.borderWidth = isSelected ? 2 : 1
        contentView.layer.borderColor = isSelected ? UIColor(named: "BtnColor")!.cgColor : UIColor.lightGray.cgColor
    }
}
