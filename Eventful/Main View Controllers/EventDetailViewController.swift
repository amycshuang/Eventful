//
//  EventDetailViewController.swift
//  Eventful
//
//  Created by Amy Chin Siu Huang on 5/12/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import UIKit
import EventKit
import EventKitUI

class EventDetailViewController: UIViewController {
    
    weak var delegate: EventDetailProtocol?
    var eventSelected: Event?
    
    init(delegate: EventDetailProtocol, eventSelected: Event) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
        self.eventSelected = eventSelected
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var scrollView: UIScrollView!
    var eventName: UILabel!
    var eventLocation: UILabel!
    var eventLocationDetailed: UILabel!
    var eventDate: UILabel!
    var eventTime: UILabel!
    var eventDescription: UITextView!
    var eventTags: UILabel!
    var eventImage: UIImageView!
    var locationIcon: UIImageView!
    var dateIcon: UIImageView!
    var addToCalendarButton: UIBarButtonItem!
    var dateObject: Date!
    
    var color = UIColor.black
    var labelSize: CGFloat = 16
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.backgroundColor = .white
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.title = "Event Details"
        
        makeDateObject()
        
        scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        scrollView.contentSize.width = view.bounds.width
        scrollView.contentSize.height = view.bounds.height + 700
        scrollView.isUserInteractionEnabled = true
        view.addSubview(scrollView)
        
        eventName = UILabel()
        eventName.text = eventSelected?.eventName
        eventName.numberOfLines = 0
        eventName.textColor = color
        eventName.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        scrollView.addSubview(eventName)
        
        eventLocation = UILabel()
        eventLocation.text = eventSelected?.eventLocation
        eventName.numberOfLines = 0
        eventLocation.textColor = color
        eventLocation.font = UIFont.systemFont(ofSize: labelSize, weight: .regular)
        scrollView.addSubview(eventLocation)
        
        eventLocationDetailed = UILabel()
        eventLocationDetailed.text = eventSelected?.eventLocationDetailed
        eventName.numberOfLines = 0
        eventLocationDetailed.textColor = .darkGray
        eventLocationDetailed.font = UIFont.systemFont(ofSize: labelSize, weight: .regular)
        scrollView.addSubview(eventLocationDetailed)
        
        eventDate = UILabel()
        eventDate.text = eventSelected?.eventDate
        eventName.numberOfLines = 0
        eventDate.textColor = color
        eventDate.font = UIFont.systemFont(ofSize: labelSize, weight: .regular)
        scrollView.addSubview(eventDate)
        
        eventTime = UILabel()
        eventTime.text = "from \(eventSelected!.eventStartTime) to \(eventSelected!.eventEndTime)"
        eventName.numberOfLines = 0
        eventTime.textColor = color
        eventTime.font = UIFont.systemFont(ofSize: labelSize, weight: .regular)
        scrollView.addSubview(eventTime)
        
        addToCalendarButton = UIBarButtonItem(image: UIImage(named: "addtocalendarbutton"), style: .plain, target: self, action: #selector(addToCalendar))
        self.navigationItem.rightBarButtonItem = addToCalendarButton
        
        eventTags = UILabel()
        if let eventTagList = eventSelected?.eventTags {
            var eventTagText = "Tags: "
            for tag in eventTagList {
                eventTagText = eventTagText + " #\(tag)"
            }
            eventTags.text = eventTagText
        }
        eventName.numberOfLines = 0
        eventTags.textColor = color
        eventTags.font = UIFont.systemFont(ofSize: labelSize, weight: .medium)
        scrollView.addSubview(eventTags)
        
        eventImage = UIImageView()
        eventImage.contentMode = .scaleAspectFill
        eventImage.clipsToBounds = true
        eventImage.layer.masksToBounds = true
        eventImage.image = eventSelected?.eventImage
        scrollView.addSubview(eventImage)
    
        locationIcon = UIImageView()
        locationIcon.image = UIImage(named: "locationicon")
        locationIcon.contentMode = .scaleAspectFit
        scrollView.addSubview(locationIcon)
        
        dateIcon = UIImageView()
        dateIcon.image = UIImage(named: "dateicon")
        dateIcon.contentMode = .scaleAspectFit
        scrollView.addSubview(dateIcon)
        
        eventDescription = UITextView()
        eventDescription.font = UIFont.systemFont(ofSize: labelSize, weight: .regular)
        eventDescription.text = eventSelected?.eventDescription
        eventDescription.isEditable = false
        eventDescription.isUserInteractionEnabled = true
        scrollView.addSubview(eventDescription)
        
        setUpConstraints()
        
    }
    
    func makeDateObject() {
        let monthDictionary:[String: Int] = ["January": 1, "February": 2, "March": 3, "April": 4, "May": 5, "June": 6, "July": 7, "August": 8, "September": 9, "October": 10, "November": 11, "December": 12]
        if let date = eventSelected?.eventDate {
            let datearray = date.components(separatedBy: " ")
            var month = datearray[0]
            var day = datearray[1]
            if let i = day.firstIndex(of: ",") {
                day.remove(at: i)
            }
            var year = datearray[2]
            day = day.trimmingCharacters(in: .whitespacesAndNewlines)
            month = month.trimmingCharacters(in: .whitespacesAndNewlines)
            year = year.trimmingCharacters(in: .whitespacesAndNewlines)
            if let dateMonth = monthDictionary[month], let dateYear = Int(year), let dateDay = Int(day) {
                let calendar = Calendar.current
                let dateComponents = DateComponents(calendar: calendar, year: dateYear, month: dateMonth, day: dateDay)
                dateObject = calendar.date(from: dateComponents)
            }
        }
    }
    
    func alert() {
        let alert = UIAlertController(title: "Success!", message: "Event Successfully Added To Your Calendar", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func addToCalendar() {
        makeDateObject()
        let eventStore: EKEventStore = EKEventStore()
        eventStore.requestAccess(to: .event) { (granted, error) in
            if (granted) && (error == nil) {
                let eventCreated: EKEvent = EKEvent(eventStore: eventStore)
                eventCreated.title = self.eventSelected?.eventName
                eventCreated.startDate = self.dateObject!
                eventCreated.endDate = self.dateObject!
                eventCreated.location = self.eventSelected?.eventLocation
                eventCreated.notes = self.eventSelected?.eventDescription
                eventCreated.calendar = eventStore.defaultCalendarForNewEvents
                do {
                    try eventStore.save(eventCreated, span: .thisEvent)
                }
                catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
            else {
                print("There was an error adding your event to the calendar")
            }
        }
        self.alert()
    }
    
    
    func setUpConstraints() {
        
        let verticalPadding: CGFloat = 15
        let horizontalPadding: CGFloat = 25
        let iconSize: CGFloat = 22
        
        scrollView.snp.makeConstraints { (make) in
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.top.equalTo(view.snp.top)
            make.bottom.equalTo(view.snp.bottom)
        }

        eventImage.snp.makeConstraints { (make) in
            make.top.equalTo(scrollView.snp.top)
            make.left.equalTo(scrollView.snp.left)
            make.right.equalTo(scrollView.snp.right)
            make.width.equalTo(scrollView.snp.width)
            make.height.equalTo(280)
        }
        
        eventName.snp.makeConstraints { (make) in
            make.top.equalTo(eventImage.snp.bottom).offset(verticalPadding)
            make.centerX.equalTo(scrollView.snp.centerX)
            let width = view.bounds.width - 50
            make.width.equalTo(width)
        }
        
        locationIcon.snp.makeConstraints { (make) in
            make.left.equalTo(scrollView.snp.left).offset(horizontalPadding)
            make.top.equalTo(eventName.snp.bottom).offset(verticalPadding)
            make.width.height.equalTo(iconSize)
        }
        
        eventLocation.snp.makeConstraints { (make) in
            make.top.equalTo(eventName.snp.bottom).offset(verticalPadding)
            make.left.equalTo(locationIcon.snp.right).offset(10)
        }
        
        eventLocationDetailed.snp.makeConstraints { (make) in
            make.top.equalTo(eventLocation.snp.bottom).offset(6)
            make.left.equalTo(eventLocation.snp.left)
        }
        
        dateIcon.snp.makeConstraints { (make) in
            make.left.equalTo(scrollView.snp.left).offset(horizontalPadding)
            make.top.equalTo(eventLocationDetailed.snp.bottom).offset(verticalPadding)
            make.width.height.equalTo(iconSize)
        }
        
        eventDate.snp.makeConstraints { (make) in
            make.left.equalTo(eventLocation.snp.left)
            make.top.equalTo(eventLocationDetailed.snp.bottom).offset(verticalPadding)
        }
        
        eventTime.snp.makeConstraints { (make) in
            make.left.equalTo(eventDate.snp.left)
            make.top.equalTo(eventDate.snp.bottom).offset(6)
        }
        
        eventTags.snp.makeConstraints { (make) in
            make.left.equalTo(scrollView.snp.left).offset(horizontalPadding)
            make.top.equalTo(eventTime.snp.bottom).offset(verticalPadding)
        }
        
        eventDescription.snp.makeConstraints { (make) in
            make.left.equalTo(scrollView.snp.left).offset(horizontalPadding)
            make.right.equalTo(scrollView.snp.right).offset(-horizontalPadding)
            make.height.equalTo(200)
            make.top.equalTo(eventTags.snp.bottom).offset(verticalPadding)
        }
        
    }

}
