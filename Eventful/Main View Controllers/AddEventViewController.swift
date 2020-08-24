//
//  AddEventViewController.swift
//  Eventful
//
//  Created by Amy Chin Siu Huang on 5/10/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import UIKit
import SnapKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseFirestore
import Firebase

class AddEventViewController: UIViewController {
    
    var ref: DatabaseReference!
    
    weak var delegate: AddEventProtocol?
    var eventCreated: Event?
    
    var eventName: String?
    var eventDate: String?
    var eventStartTime: String?
    var eventEndTime: String?
    var eventLocation: String?
    var eventLocationDetailed: String?
    var eventDescription: String?
    var eventTags: [String] = []
    var eventImageUrl: String?
    var eventImage: UIImage?
    var isFavorite: Bool?

    init(delegate: AddEventProtocol?) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var scrollView: UIScrollView!
    
    var eventNameLabel: UILabel!
    var eventNameText: UITextField!
    var locationLabel: UILabel!
    var locationText: UITextField!
    var locationDetailedText: UITextField!
    var dateLabel: UILabel!
    var dateText: UITextField!
    var timeLabel: UILabel!
    var startTimeText: UITextField!
    var endTimeText: UITextField!
    var descriptionLabel: UILabel!
    var descriptionText: UITextView!
    var tagLabel: UILabel!
    var imageLabel: UILabel!
    var image: UIImageView!
    var addEventButton: UIButton!
    var cancelButton: UIButton!
    
    var labelSize:CGFloat = 18
    
    let filterReuseIdentifier = "filterReuseIdentifier"
    var filterCollectionView: UICollectionView!
    let filterpadding: CGFloat = 5
    var filters: [Filter] = []
    var selectedFilters: [Filter] = []
    
    var filterRow1: [Filter] = []
    var filterRow2: [Filter] = []
    
    var datePicker = UIDatePicker()
    var startTimePicker = UIDatePicker()
    var endTimePicker = UIDatePicker()

    var color: UIColor = UIColor(red: 0.4549, green: 0.7255, blue: 1, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.title = "New Event"
        
        ref = Database.database().reference()
        
        makeFilters()
        
        scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        scrollView.contentSize.height = view.bounds.height + 180
        view.addSubview(scrollView)
        
        eventNameLabel = UILabel()
        eventNameLabel.text = "event name: "
        eventNameLabel.textColor = color
        eventNameLabel.font = UIFont.systemFont(ofSize: labelSize, weight: .medium)
        scrollView.addSubview(eventNameLabel)
        
        eventNameText = UITextField()
        eventNameText.placeholder = "event name"
        eventNameText.backgroundColor = .white
        eventNameText.borderStyle = .roundedRect
        scrollView.addSubview(eventNameText)
        
        locationLabel = UILabel()
        locationLabel.text = "location: "
        locationLabel.textColor = color
        locationLabel.font = UIFont.systemFont(ofSize: labelSize, weight: .medium)
        scrollView.addSubview(locationLabel)
        
        locationText = UITextField()
        locationText.placeholder = "location"
        locationText.backgroundColor = .white
        locationText.borderStyle = .roundedRect
        scrollView.addSubview(locationText)
        
        locationDetailedText = UITextField()
        locationDetailedText.placeholder = "location details"
        locationDetailedText.borderStyle = .roundedRect
        scrollView.addSubview(locationDetailedText)
        
        dateLabel = UILabel()
        dateLabel.text = "date: "
        dateLabel.textColor = color
        dateLabel.font = UIFont.systemFont(ofSize: labelSize, weight: .medium)
        scrollView.addSubview(dateLabel)
        
        dateText = UITextField()
        dateText.placeholder = "mm/dd/yyyy"
        dateText.textAlignment = .center
        dateText.backgroundColor = .white
        dateText.borderStyle = .roundedRect
        scrollView.addSubview(dateText)
        
        makeDatePicker()
        
        timeLabel = UILabel()
        timeLabel.text = "time: "
        timeLabel.textColor = color
        timeLabel.font = UIFont.systemFont(ofSize: labelSize, weight: .medium)
        scrollView.addSubview(timeLabel)
        
        startTimeText = UITextField()
        startTimeText.placeholder = "from"
        startTimeText.backgroundColor = .white
        startTimeText.borderStyle = .roundedRect
        scrollView.addSubview(startTimeText)
        
        makeStartTimePicker()
        
        endTimeText = UITextField()
        endTimeText.placeholder = "to"
        endTimeText.backgroundColor = .white
        endTimeText.borderStyle = .roundedRect
        scrollView.addSubview(endTimeText)
        
        makeEndTimePicker()
        
        descriptionLabel = UILabel()
        descriptionLabel.text = "description: "
        descriptionLabel.textColor = color
        descriptionLabel.font = UIFont.systemFont(ofSize: labelSize, weight: .medium)
        scrollView.addSubview(descriptionLabel)
        
        descriptionText = UITextView()
        descriptionText.clipsToBounds = true
        descriptionText.layer.borderWidth = 1.0
        descriptionText.layer.borderColor = UIColor.lightGray.cgColor
        descriptionText.font = UIFont.systemFont(ofSize: labelSize, weight: .medium)
        descriptionText.isEditable = true
        descriptionText.layer.cornerRadius = 10
        scrollView.addSubview(descriptionText)
        
        tagLabel = UILabel()
        tagLabel.text = "tags: "
        tagLabel.textColor = color
        tagLabel.font = UIFont.systemFont(ofSize: labelSize, weight: .medium)
        scrollView.addSubview(tagLabel)
        
        let filterlayout = UICollectionViewFlowLayout()
        filterlayout.scrollDirection = .vertical
        filterlayout.minimumInteritemSpacing = filterpadding
        filterlayout.minimumLineSpacing = filterpadding
        filterlayout.sectionInset = UIEdgeInsets(top: 8.0, left: 0.0, bottom: 0.0, right: 0.0)
        filterCollectionView = UICollectionView(frame: .zero, collectionViewLayout: filterlayout)
        filterCollectionView.backgroundColor = .clear
        filterCollectionView.allowsMultipleSelection = true
        filterCollectionView.dataSource = self
        filterCollectionView.delegate = self
        filterCollectionView.register(FilterCollectionViewCell.self, forCellWithReuseIdentifier: filterReuseIdentifier)
        filterCollectionView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(filterCollectionView)
    
        imageLabel = UILabel()
        imageLabel.text = "tap to select an image from \n your photo gallery!"
        imageLabel.numberOfLines = 0
        imageLabel.textColor = color
        imageLabel.font = UIFont.systemFont(ofSize: labelSize, weight: .medium)
        scrollView.addSubview(imageLabel)
        
        image = UIImageView()
        image.image = UIImage(named: "defaultimage")
        image.layer.borderWidth = 1
        image.layer.cornerRadius = 10
        image.clipsToBounds = true
        image.layer.borderColor = UIColor.lightGray.cgColor
        image.contentMode = .scaleAspectFill
        image.isUserInteractionEnabled = true
        let addAnImage = UITapGestureRecognizer(target: self, action: #selector(addImage))
        image.addGestureRecognizer(addAnImage)
        scrollView.addSubview(image)
        
        addEventButton = UIButton()
        addEventButton.setTitle("ADD EVENT", for: .normal)
        addEventButton.setTitleColor(color, for: .normal)
        addEventButton.addTarget(self, action: #selector(addEvent), for: .touchUpInside)
        addEventButton.layer.borderColor = color.cgColor
        addEventButton.layer.borderWidth = 1
        addEventButton.layer.cornerRadius = 20
        scrollView.addSubview(addEventButton)
        
        setUpConstraints()
        
    }
    
    func makeFilters() {
        let food = Filter(filter: "food", isSelected: false)
        let fun = Filter(filter: "fun", isSelected: false)
        let study = Filter(filter: "study", isSelected: false)
        let recruiting = Filter(filter: "recruiting", isSelected: false)
        let clubs = Filter(filter: "clubs", isSelected: false)
        let info = Filter(filter: "info", isSelected: false)
        let plants = Filter(filter: "plants", isSelected: false)
        let dogs = Filter(filter: "dogs", isSelected: false)
        filterRow1 = [food, fun, study, recruiting]
        filterRow2 = [clubs, info, plants, dogs]
    }
    
    func makeDatePicker() {
        let toolbar = UIToolbar(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: 44)))
        toolbar.sizeToFit()
        let dateDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(dateDone))
        toolbar.items = [dateDoneButton]
        dateText.inputAccessoryView = toolbar
        dateText.inputView = datePicker
        datePicker.datePickerMode = .date
        datePicker.minimumDate = Calendar.current.date(byAdding: .year, value: 0, to: Date())
        datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())
    }
    
    @objc func dateDone() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        dateText.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    func makeStartTimePicker() {
        let toolbar = UIToolbar(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: 44)))
        toolbar.sizeToFit()
        let startTimeDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(startTimeDone))
        toolbar.items = [startTimeDoneButton]
        startTimeText.inputAccessoryView = toolbar
        startTimeText.inputView = startTimePicker
        startTimePicker.datePickerMode = .time
    }
    
    func makeEndTimePicker() {
        let toolbar = UIToolbar(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: 44)))
        toolbar.sizeToFit()
        let endTimeDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(endTimeDone))
        toolbar.items = [endTimeDoneButton]
        endTimeText.inputAccessoryView = toolbar
        endTimeText.inputView = endTimePicker
        endTimePicker.datePickerMode = .time
    }
    
    @objc func startTimeDone() {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        startTimeText.text = formatter.string(from: startTimePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func endTimeDone() {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        endTimeText.text = formatter.string(from: endTimePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func addImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func alert() {
        let alert = UIAlertController(title: "Invalid Event", message: "Please Fill Out All Fields", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel))
        self.present(alert, animated: true, completion: nil)
    }
    
    func noImageAlert() {
        let alert = UIAlertController(title: "Invalid Event", message: "Please Add An Image", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel))
        self.present(alert, animated: true, completion: nil)
    }
    
    func nameCharacterAlert() {
        let alert = UIAlertController(title: "Invalid Event", message: "Please Shorten Your Event Name", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel))
        self.present(alert, animated: true, completion: nil)
    }
    
    func locationCharacterAlert() {
        let alert = UIAlertController(title: "Invalid Event", message: "Please Shorten Your Location", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel))
        self.present(alert, animated: true, completion: nil)
    }
    
    func errorAlert() {
        let alert = UIAlertController(title: "Error", message: "Something Went Wrong", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func addEvent(completion: @escaping ((String) -> Void)) {
        setTags()
        let currentImage = image.image
        let currentImageData: NSData = currentImage!.pngData()! as NSData
        let originalImage = UIImage(named: "defaultimage")
        let originalImageData: NSData = originalImage!.pngData()! as NSData
        if let event = eventNameText.text?.trimmingCharacters(in: .whitespacesAndNewlines), let date = dateText.text?.trimmingCharacters(in: .whitespacesAndNewlines), let startTime = startTimeText.text?.trimmingCharacters(in: .whitespacesAndNewlines), let endTime = endTimeText.text?.trimmingCharacters(in: .whitespacesAndNewlines), let location = locationText.text?.trimmingCharacters(in: .whitespacesAndNewlines), let locationDetailed = locationDetailedText.text?.trimmingCharacters(in: .whitespacesAndNewlines), let description = descriptionText.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            if event == "" || date == "" || startTime == "" || endTime == "" || location == "" || description == "" {
                alert()
            }
            else if currentImageData.isEqual(originalImageData) == true {
                noImageAlert()
            }
            else if event.count > 42 {
                nameCharacterAlert()
            }
            else if location.count > 42 {
                locationCharacterAlert()
            }
            else {
                uploadEventToFirebaseStorage(event: event, date: date, startTime: startTime, endTime: endTime, location: location, locationDetailed: locationDetailed, description: description, eventTags: eventTags, isfavorite: false)
            }
        }
    }
    
    func uploadEventToFirebaseStorage(event: String, date: String, startTime: String, endTime: String, location: String, locationDetailed: String, description: String, eventTags: [String], isfavorite: Bool) {
        guard let photo = image.image, let data = photo.jpegData(compressionQuality: 0.1) else {
            errorAlert()
            return
        }
        let photoName = UUID().uuidString
        let photoReference = Storage.storage().reference().child("Event Images").child(photoName)
        photoReference.putData(data, metadata: nil) { (metadata, err) in
            if let err = err {
                self.errorAlert()
                print(err.localizedDescription)
                return
            }
            photoReference.downloadURL { (url, err) in
                if let err = err {
                    self.errorAlert()
                    print(err.localizedDescription)
                    return
                }
                guard let url = url else {
                    self.errorAlert()
                    return
                }
                self.eventImageUrl = url.absoluteString
                let photoURL = url.absoluteString
                self.ref?.child("Events").childByAutoId().setValue(["eventName": event, "eventDate": date, "eventStartTime": startTime, "eventEndTime": endTime, "eventLocation": location, "eventLocationDetailed": locationDetailed, "eventDescription": description, "eventTags": eventTags, "eventImageUrl": photoURL, "isFavorite": false])
                self.ref?.child("Users").child(User.name!).child("Posts").childByAutoId().setValue(["eventName": event, "eventDate": date, "eventStartTime": startTime, "eventEndTime": endTime, "eventLocation": location, "eventLocationDetailed": locationDetailed, "eventDescription": description, "eventTags": eventTags, "eventImageUrl": photoURL, "isFavorite": false])
                self.eventCreated = Event(eventName: event, eventDate: date, eventStartTime: startTime, eventEndTime: endTime, eventLocation: location, eventLocationDetailed: locationDetailed, eventDescription: description, eventTags: eventTags, eventImageUrl: self.eventImageUrl!, eventImage: self.image.image!, isFavorite: false)
                User.userPosts.append(self.eventCreated!)
                self.delegate?.AddNewEvent(event: self.eventCreated!)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func setTags() {
        for filter in selectedFilters {
            eventTags.append(filter.filter)
        }
    }

    func setUpConstraints() {
        
        let verticalPadding: CGFloat = 40
        let horizontalPadding: CGFloat = 25
        
        scrollView.snp.makeConstraints { (make) in
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.top.equalTo(view.snp.top)
            make.bottom.equalTo(view.snp.bottom)
        }
        
        eventNameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(scrollView.snp.left).offset(horizontalPadding)
            make.top.equalTo(scrollView.snp.top).offset(30)
        }
        
        eventNameText.snp.makeConstraints { (make) in
            make.left.equalTo(eventNameLabel.snp.right).offset(horizontalPadding)
            make.width.equalTo(235)
            make.centerY.equalTo(eventNameLabel.snp.centerY)
        }
        
        locationLabel.snp.makeConstraints { (make) in
            make.left.equalTo(scrollView.snp.left).offset(horizontalPadding)
            make.top.equalTo(eventNameLabel.snp.bottom).offset(verticalPadding)
        }
        
        locationText.snp.makeConstraints { (make) in
            make.left.equalTo(locationLabel.snp.right).offset(horizontalPadding)
            make.width.equalTo(265)
            make.centerY.equalTo(locationLabel.snp.centerY)
        }
        
        locationDetailedText.snp.makeConstraints { (make) in
            make.left.equalTo(locationText.snp.left)
            make.width.equalTo(locationText.snp.width)
            make.top.equalTo(locationText.snp.top).offset(verticalPadding)
        }
        
        dateLabel.snp.makeConstraints { (make) in
            make.left.equalTo(scrollView.snp.left).offset(horizontalPadding)
            make.top.equalTo(locationDetailedText.snp.bottom).offset(verticalPadding)
        }
        
        dateText.snp.makeConstraints { (make) in
            make.left.equalTo(dateLabel.snp.right).offset(horizontalPadding)
            make.width.equalTo(205)
            make.centerY.equalTo(dateLabel.snp.centerY)
        }
        
        timeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(scrollView.snp.left).offset(horizontalPadding)
            make.top.equalTo(dateLabel.snp.bottom).offset(verticalPadding)
        }
        
        startTimeText.snp.makeConstraints { (make) in
            make.left.equalTo(timeLabel.snp.right).offset(horizontalPadding)
            make.width.equalTo(90)
            make.centerY.equalTo(timeLabel.snp.centerY)
        }
        
        endTimeText.snp.makeConstraints { (make) in
            make.left.equalTo(startTimeText.snp.right).offset(horizontalPadding)
            make.width.equalTo(90)
            make.centerY.equalTo(timeLabel.snp.centerY)
        }

        descriptionLabel.snp.makeConstraints { (make) in
            make.left.equalTo(scrollView.snp.left).offset(horizontalPadding)
            make.top.equalTo(timeLabel.snp.bottom).offset(verticalPadding)
        }
        
        descriptionText.snp.makeConstraints { (make) in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(10)
            make.left.equalTo(scrollView.snp.left).offset(horizontalPadding)
            make.width.equalTo(scrollView.snp.width).offset(-2*horizontalPadding)
            make.height.equalTo(200)
        }
        
        tagLabel.snp.makeConstraints { (make) in
            make.left.equalTo(scrollView.snp.left).offset(horizontalPadding)
            make.top.equalTo(descriptionText.snp.bottom).offset(verticalPadding)
        }
        
        filterCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(tagLabel.snp.bottom).offset(10)
            make.left.right.equalTo(view).offset(horizontalPadding)
            make.height.equalTo(80)
        }
        
        imageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(filterCollectionView.snp.bottom).offset(30)
            make.left.equalTo(scrollView.snp.left).offset(horizontalPadding)
        }
        
        image.snp.makeConstraints { (make) in
            make.left.equalTo(scrollView.snp.left).offset(horizontalPadding)
            make.top.equalTo(imageLabel.snp.bottom).offset(20)
            make.height.width.equalTo(180)
        }
        
        addEventButton.snp.makeConstraints { (make) in
            make.top.equalTo(image.snp.bottom).offset(50)
            make.centerX.equalTo(scrollView.snp.centerX)
            make.height.equalTo(40)
            make.width.equalTo(160)
        }
        
    }
    
}

extension AddEventViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return filterRow1.count
        }
        else {
            return filterRow2.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = filterCollectionView.dequeueReusableCell(withReuseIdentifier: filterReuseIdentifier, for: indexPath) as! FilterCollectionViewCell
        if indexPath.section == 0 {
            let filter = filterRow1[indexPath.row]
            cell.configure(filter: filter)
        }
        else {
            let filter = filterRow2[indexPath.row]
            cell.configure(filter: filter)
        }
        return cell
    }
    
    
}

extension AddEventViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let filter = filterRow1[indexPath.item]
            filter.isSelected.toggle()
            if filter.isSelected {
                selectedFilters.append(filter)
            }
            else if !filter.isSelected {
                removeFilter()
            }
        }
        else {
            let filter = filterRow2[indexPath.item]
            filter.isSelected.toggle()
            if filter.isSelected {
                selectedFilters.append(filter)
            }
            else if !filter.isSelected {
                removeFilter()
            }
        }
        filterCollectionView.reloadData()
    }
    func removeFilter() {
        var tempArray: [Filter] = []
        for index in 0 ..< selectedFilters.count{
            if selectedFilters[index].isSelected == true {
                tempArray.append(selectedFilters[index])
            }
        }
        selectedFilters = tempArray
        tempArray = []
    }
}

extension AddEventViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            let label = UILabel(frame: .zero)
            label.text = filterRow1[indexPath.item].filter
            label.sizeToFit()
            return CGSize(width: label.frame.width + 14, height: 28)
        }
        let label = UILabel(frame: .zero)
        label.text = filterRow2[indexPath.item].filter
        label.sizeToFit()
        return CGSize(width: label.frame.width + 14, height: 28)
    }
}

extension AddEventViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            image.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
