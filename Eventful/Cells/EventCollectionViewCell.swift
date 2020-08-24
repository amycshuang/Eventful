//
//  EventCollectionViewCell.swift
//  Eventful
//
//  Created by Amy Chin Siu Huang on 5/9/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import UIKit
import SnapKit
import Alamofire

class EventCollectionViewCell: UICollectionViewCell {
    
    weak var delegate: FavoriteProtocol?

    var eventImage: UIImageView!
    var eventName: UILabel!
    var eventDate: UILabel!
    var eventTime: UILabel!
    var eventLocation: UILabel!
    var eventLocationDetailed: UILabel!
    var favoriteButton: UIButton!
    var eventTags: UILabel!
    
    var locationIcon: UIImageView!
    var dateIcon: UIImageView!
    
    let loadingImage = UIImage(named: "loadingimage")
    var originalImageData: NSData!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        originalImageData = loadingImage!.pngData()! as NSData
        
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 20
        contentView.clipsToBounds = false
        contentView.layer.masksToBounds = false
        contentView.layer.shadowColor = UIColor(red: 0.7569, green: 0.7569, blue: 0.7569, alpha: 1.0).cgColor
        contentView.layer.shadowOpacity = 0.8
        contentView.layer.shadowRadius = 5
        contentView.layer.shadowOffset = CGSize(width: -5, height: 5)
        contentView.layer.shadowPath = UIBezierPath(roundedRect: contentView.bounds, cornerRadius: 20).cgPath
        
        eventImage = UIImageView()
        eventImage.contentMode = .scaleAspectFill
        eventImage.layer.cornerRadius = 8
        eventImage.layer.masksToBounds = true
        eventImage.clipsToBounds = true
        contentView.addSubview(eventImage)
        
        eventName = UILabel()
        eventName.textColor = .black
        eventName.font = UIFont.boldSystemFont(ofSize: 18)
        contentView.addSubview(eventName)
        
        eventDate = UILabel()
        eventDate.textColor = .darkGray
        eventDate.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        contentView.addSubview(eventDate)
        
        eventTime = UILabel()
        eventTime.textColor = .darkGray
        eventTime.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        contentView.addSubview(eventTime)
        
        eventLocation = UILabel()
        eventLocation.textColor = .darkGray
        eventLocation.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        contentView.addSubview(eventLocation)

        eventLocationDetailed = UILabel()
        eventLocationDetailed.textColor = .gray
        eventLocationDetailed.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        contentView.addSubview(eventLocationDetailed)
        
        favoriteButton = UIButton()
        favoriteButton.setImage(UIImage(named: "favoriteicon"), for: .normal)
        favoriteButton.addTarget(self, action: #selector(favorited), for: .touchUpInside)
        contentView.addSubview(favoriteButton)
        
        locationIcon = UIImageView()
        locationIcon.image = UIImage(named: "locationicon")
        locationIcon.contentMode = .scaleAspectFit
        contentView.addSubview(locationIcon)
        
        dateIcon = UIImageView()
        dateIcon.image = UIImage(named: "dateicon")
        dateIcon.contentMode = .scaleAspectFit
        contentView.addSubview(dateIcon)

        eventTags = UILabel()
        eventTags.textColor = .darkGray
        eventTags.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        contentView.addSubview(eventTags)
        
        setUpConstraints()
    }
    
    @objc func favorited() {
        delegate?.favoritePressed(cell: self)
    }
    
    func configure(event: Event) {
        eventName.text = event.eventName
        eventLocation.text = event.eventLocation
        eventLocationDetailed.text = event.eventLocationDetailed
        eventDate.text = event.eventDate
        eventTime.text = "from \(event.eventStartTime) to \(event.eventEndTime)"
        if event.isFavorite {
            favoriteButton.setImage(UIImage(named: "favoriteiconfilled"), for: .normal)
        }
        else {
            favoriteButton.setImage(UIImage(named: "favoriteicon"), for: .normal)
        }
        eventImage.image = event.eventImage
        var eventTagText = ""
        for tag in event.eventTags {
            eventTagText = eventTagText + " #\(tag)"
        }
        eventTags.text = eventTagText
    }
    
    func setUpConstraints() {
        
        let outerPadding: CGFloat = 16
        let innerPaddingV: CGFloat = 8
        let innerPaddingH: CGFloat = 5
        let favoriteIconSize: CGFloat = 25
        let iconSize: CGFloat = 20
        
        favoriteButton.snp.makeConstraints { (make) in
            make.top.equalTo(contentView.snp.top).offset(outerPadding)
            make.right.equalTo(contentView.snp.right).offset(-outerPadding)
            make.height.width.equalTo(favoriteIconSize)
        }
        
        eventName.snp.makeConstraints { (make) in
            make.top.equalTo(contentView.snp.top).offset(outerPadding)
            make.left.equalTo(contentView.snp.left).offset(outerPadding)
            make.right.equalTo(favoriteButton.snp.left).offset(-innerPaddingH)
        }
        
        locationIcon.snp.makeConstraints { (make) in
            make.top.equalTo(eventName.snp.bottom).offset(innerPaddingV)
            make.left.equalTo(eventName.snp.left)
            make.height.width.equalTo(iconSize)
        }
        
        eventLocation.snp.makeConstraints { (make) in
            make.left.equalTo(locationIcon.snp.right).offset(innerPaddingH)
            make.top.equalTo(locationIcon.snp.top)
            make.right.equalTo(contentView.snp.right).offset(-iconSize)
        }
        
        eventLocationDetailed.snp.makeConstraints { (make) in
            make.top.equalTo(eventLocation.snp.bottom).offset(innerPaddingH)
            make.left.equalTo(eventLocation.snp.left)
            make.right.equalTo(eventLocation.snp.right)
        }
        
        dateIcon.snp.makeConstraints { (make) in
            make.top.equalTo(eventLocationDetailed.snp.bottom).offset(innerPaddingH)
            make.left.equalTo(locationIcon.snp.left)
            make.width.height.equalTo(iconSize)
        }
        
        eventDate.snp.makeConstraints { (make) in
            make.top.equalTo(dateIcon.snp.top)
            make.left.equalTo(dateIcon.snp.right).offset(innerPaddingV)
        }
        
        eventTime.snp.makeConstraints { (make) in
            make.top.equalTo(eventDate.snp.top)
            make.left.equalTo(eventDate.snp.right).offset(innerPaddingH)
        }
        
        eventImage.snp.makeConstraints { (make) in
            make.top.equalTo(eventTime.snp.bottom).offset(innerPaddingV)
            make.left.equalTo(dateIcon.snp.left)
            make.right.equalTo(contentView.snp.right).offset(-outerPadding)
            make.bottom.equalTo(contentView.snp.bottom).offset(-2*outerPadding)
        }
        
        eventTags.snp.makeConstraints { (make) in
            make.left.equalTo(contentView.snp.left).offset(outerPadding)
            make.top.equalTo(eventImage.snp.bottom).offset(6)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
