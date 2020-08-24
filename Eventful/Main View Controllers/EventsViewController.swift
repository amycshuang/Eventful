//
//  EventsViewController.swift
//  Eventful
//
//  Created by Amy Chin Siu Huang on 5/9/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import UIKit
import SnapKit
import FirebaseDatabase
import Firebase

protocol AddEventProtocol: class {
    func AddNewEvent(event: Event)
}

protocol EventDetailProtocol: class {
    func reloadEvents() 
}

protocol FavoriteProtocol: class {
    func favoritePressed(cell: EventCollectionViewCell)
}

protocol UserPostedEventProtocol: class {
    func UserPostedEvent(event: Event)
}

class EventsViewController: UIViewController {
    
    var ref: DatabaseReference!
    
    var eventCollectionView: UICollectionView!
    let eventReuseIdentifier = "eventReuseIdentifier"
    let eventPadding: CGFloat = 18
    var events: [Event] = []
    
    var addEventButton: UIButton!
    var refreshController:UIRefreshControl = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        self.navigationItem.title = "Events"
    
        ref = Database.database().reference()
        
        setUpNavigation()
        
        refreshController.addTarget(self, action: #selector(refreshCollection), for: .valueChanged)
        refreshController.tintColor = UIColor(red: 0.4549, green: 0.7255, blue: 1, alpha: 1.0)
        
        let eventLayout = UICollectionViewFlowLayout()
        eventLayout.scrollDirection = .vertical
        eventLayout.minimumInteritemSpacing = eventPadding
        eventLayout.minimumLineSpacing = eventPadding
        eventCollectionView = UICollectionView(frame: .zero, collectionViewLayout: eventLayout)
        eventCollectionView.backgroundColor = .white
        eventCollectionView.register(EventCollectionViewCell.self, forCellWithReuseIdentifier: eventReuseIdentifier)
        eventCollectionView.dataSource = self
        eventCollectionView.delegate = self
        eventCollectionView.refreshControl = refreshController
        view.addSubview(eventCollectionView)
        eventCollectionView.addSubview(refreshController)
        
        addEventButton = UIButton()
        addEventButton.setImage(UIImage(named: "addbutton"), for: .normal)
        addEventButton.layer.cornerRadius = 24
        addEventButton.imageView?.layer.cornerRadius = 24
        addEventButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: addEventButton.bounds.width - addEventButton.bounds.height)
        addEventButton.layer.shadowColor = UIColor(red: 0.7569, green: 0.7569, blue: 0.7569, alpha: 1.0).cgColor
        addEventButton.layer.shadowRadius = 1
        addEventButton.layer.shadowOpacity = 0.8
        addEventButton.layer.shadowOffset = CGSize(width: -4, height: 4)
        addEventButton.addTarget(self, action: #selector(addEvent), for: .touchUpInside)
        view.addSubview(addEventButton)
    
        setUpInitialView { (success) in
            if success {
                resetLikedEvents()
            }
        }
        getUserPosts()
        setUpConstraints()
    }
    
    @objc func refreshCollection() {
        getEvents()
        getUserPosts()
        getUserLikedEvents()
        resetLikedEvents()
        eventCollectionView.reloadData()
        refreshController.endRefreshing()
    }
    
    func setUpInitialView(completion: (_ success: Bool) -> Void) {
        getEvents()
        getUserLikedEvents()
        completion(true)
    }
    
    func getEvents() {
        ref.child("Events").observeSingleEvent(of: .value) { (snapshot) in
            var events = [Event]()
            for eventSnapshot in snapshot.children {
                let event = Event(snapshot: eventSnapshot as! DataSnapshot)
                NetworkManager.getImage(imageURL: event.eventImageUrl) { (image) in
                    DispatchQueue.main.async {
                        event.eventImage = image
                    }
                }
                events.append(event)
            }
            self.events = events
            self.eventCollectionView.reloadData()
        }
    }
    
    func getUserPosts() {
        ref.child("Users").child(User.name!).child("Posts").observeSingleEvent(of: .value) { (snapshot) in
            var userPosts = [Event]()
            for userPostsSnapshot in snapshot.children {
                let userPost = Event(snapshot: userPostsSnapshot as! DataSnapshot)
                NetworkManager.getImage(imageURL: userPost.eventImageUrl) { (image) in
                    DispatchQueue.main.async {
                        userPost.eventImage = image
                    }
                }
                userPosts.append(userPost)
            }
            User.userPosts = userPosts
        }
        self.eventCollectionView.reloadData()
    }
    
    func getUserLikedEvents() {
        ref.child("Users").child(User.name!).child("Liked").observeSingleEvent(of: .value) { (snapshot) in
            var likedEvents = [Event]()
            for likedEventsSnapshot in snapshot.children {
                let likedEvent = Event(snapshot: likedEventsSnapshot as! DataSnapshot)
                NetworkManager.getImage(imageURL: likedEvent.eventImageUrl) { (image) in
                    DispatchQueue.main.async {
                        likedEvent.eventImage = image
                    }
                }
                likedEvents.append(likedEvent)
            }
            User.likedEvents = likedEvents
        }
        self.eventCollectionView.reloadData()
    }
    
    func resetLikedEvents() {
        eventCollectionView.reloadData()
    }
    
    func setUpNavigation() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.backgroundColor = UIColor(red: 0.4549, green: 0.7255, blue: 1, alpha: 1.0)
        self.navigationController?.navigationBar.standardAppearance = navBarAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.4549, green: 0.7255, blue: 1, alpha: 1.0)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.view.backgroundColor = .white
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.boldSystemFont(ofSize: 18)]
    }
    
    @objc func addEvent() {
        let vc = AddEventViewController(delegate: self)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setUpConstraints() {
        
        eventCollectionView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(20)
            make.bottom.equalToSuperview()
        }
        
        addEventButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview().offset(-15)
            make.width.height.equalTo(48)
        }
    }

}

extension EventsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return events.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = eventCollectionView.dequeueReusableCell(withReuseIdentifier: eventReuseIdentifier, for: indexPath) as! EventCollectionViewCell
        cell.delegate = self
        let event = events[indexPath.item]
        if User.likedEvents.contains(event) {
            event.isFavorite = true
        }
        cell.configure(event: event)
        return cell
    }
    
}

extension EventsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = eventCollectionView.frame.width - 45
        return CGSize(width: width, height: 225)
    }
}

extension EventsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let event = events[indexPath.item]
        let vc = EventDetailViewController(delegate: self, eventSelected: event)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension EventsViewController: AddEventProtocol {
    func AddNewEvent(event: Event) {
        events.append(event)
        eventCollectionView.reloadData()
    }
}

extension EventsViewController: FavoriteProtocol {
    func favoritePressed(cell: EventCollectionViewCell) {
        let indexPath = eventCollectionView.indexPath(for: cell)
        let eventPressed: Event = events[indexPath!.item]
        eventPressed.isFavorite.toggle()
        userLiked()
        addToFirebase()
        eventCollectionView.reloadData()
    }
    
    func userLiked() {
        var tempArray: [Event] = []
        User.likedEvents = []
        for event in events {
            if event.isFavorite {
                tempArray.append(event)
            }
        }
        User.likedEvents = tempArray
        tempArray = []
    }
        
    func addToFirebase() {
        self.ref.child("Users").child(User.name!).child("Liked").removeValue()
        for event in User.likedEvents {
            self.ref.child("Users").child(User.name!).child("Liked").childByAutoId().setValue(["eventName": event.eventName, "eventDate": event.eventDate, "eventStartTime": event.eventStartTime, "eventEndTime": event.eventEndTime, "eventLocation": event.eventLocation, "eventLocationDetailed": event.eventLocationDetailed, "eventDescription": event.eventDescription, "eventTags": event.eventTags, "eventImageUrl": event.eventImageUrl, "isFavorite": event.isFavorite])
        }
        eventCollectionView.reloadData()
    }
}

extension EventsViewController: EventDetailProtocol {
    func reloadEvents() {
        eventCollectionView.reloadData()
    }
}
