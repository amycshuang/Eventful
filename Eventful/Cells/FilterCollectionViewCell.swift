//
//  FilterCollectionViewCell.swift
//  Eventful
//
//  Created by Amy Chin Siu Huang on 5/10/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import UIKit
import SnapKit

class FilterCollectionViewCell: UICollectionViewCell {
    var filterLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.cornerRadius = 8
        contentView.layer.borderColor = UIColor(red: 1, green: 0.502, blue: 0.502, alpha: 1.0).cgColor
        contentView.layer.borderWidth = 1
        
        filterLabel = UILabel()
        filterLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        filterLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(filterLabel)
        
        setUpConstraints()
    }
    
    func configure(filter: Filter) {
        filterLabel.text = filter.filter
        if filter.isSelected {
            contentView.backgroundColor = UIColor(red: 1, green: 0.502, blue: 0.502, alpha: 1.0)
            filterLabel.textColor = .white
        }
        else {
            contentView.backgroundColor = .white
            filterLabel.textColor = UIColor(red: 1, green: 0.502, blue: 0.502, alpha: 1.0)
        }
    }
    
    func setUpConstraints() {
        
        filterLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(contentView.snp.centerX)
            make.centerY.equalTo(contentView.snp.centerY)
            make.height.equalTo(16)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
