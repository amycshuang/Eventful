//
//  UserProfileViewController.swift
//  Eventful
//
//  Created by Amy Chin Siu Huang on 5/9/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import UIKit
import SnapKit
import GoogleSignIn
import Firebase
import FirebaseDatabase


class UserProfileViewController: UIViewController {
    
    var userImage: UIImageView!
    var userName: UILabel!
    var userEmail: UILabel!
    var signoutButton: UIButton!
    var segmentedControl: CustomSegmentedControl!
    
    var ref: DatabaseReference!
    
    var userCollectionView: UICollectionView!
    let userReuseIdentifier = "userReuseIdentifier"
    
    let padding: CGFloat = 18
    
    var posts: [Event] = []
    var favoritedEvents: [Event] = []
    
    var refreshController: UIRefreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.4549, green: 0.7255, blue: 1, alpha: 1.0)
        self.navigationController?.view.backgroundColor = .white
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.boldSystemFont(ofSize: 18)]
        
        self.view.backgroundColor = .white
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.title = "My Profile"
        
        ref = Database.database().reference()
        
        refreshController.addTarget(self, action: #selector(refreshCollection), for: .valueChanged)
        refreshController.tintColor = UIColor(red: 0.4549, green: 0.7255, blue: 1, alpha: 1.0)
        
        segmentedControl = CustomSegmentedControl(frame: CGRect(x: 0, y: 250, width: self.view.frame.width, height: 50), buttonTitle: ["My Posts", "Liked Posts"])
        segmentedControl.addTarget(self, action: #selector(segmentedControlTapped), for: .valueChanged)
        segmentedControl.backgroundColor = .clear
        view.addSubview(segmentedControl)
        
        userImage = UIImageView()
        userImage.contentMode = .scaleAspectFill
        userImage.layer.cornerRadius = 50
        userImage.layer.masksToBounds = true
        userImage.clipsToBounds = true
        if let imageURL = User.imageURL {
            NetworkManager.getImage(imageURL: imageURL) { (image) in
                DispatchQueue.main.async {
                    self.userImage.image = image
                }
            }
        }
        view.addSubview(userImage)
        
        userName = UILabel()
        userName.textColor = .black
        userName.text = User.name
        userName.font = UIFont.boldSystemFont(ofSize: 18)
        view.addSubview(userName)
        
        userEmail = UILabel()
        userEmail.textColor = .darkGray
        userEmail.text = User.email
        userEmail.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        view.addSubview(userEmail)
        
        signoutButton = UIButton()
        signoutButton.setTitle("Sign Out", for: .normal)
        signoutButton.layer.cornerRadius = 12
        signoutButton.layer.borderWidth = 1
        signoutButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        signoutButton.setTitleColor(UIColor(red: 0.4549, green: 0.7255, blue: 1, alpha: 1.0), for: .normal)
        signoutButton.layer.borderColor = UIColor(red: 0.4549, green: 0.7255, blue: 1, alpha: 1.0).cgColor
        signoutButton.addTarget(self, action: #selector(signoutUser), for: .touchUpInside)
        view.addSubview(signoutButton)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = padding
        layout.minimumInteritemSpacing = padding
        
        userCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        userCollectionView.backgroundColor = .white
        userCollectionView.register(EventCollectionViewCell.self, forCellWithReuseIdentifier: userReuseIdentifier)
        userCollectionView.dataSource = self
        userCollectionView.delegate = self
        userCollectionView.refreshControl = refreshController
        view.addSubview(userCollectionView)
        userCollectionView.addSubview(refreshController)

        posts = User.userPosts
        favoritedEvents = User.likedEvents
        
        setUpInitialView { (success) in
            if success {
                userCollectionView.reloadData()
            }
        }
        
        setUpConstraints()
    }
    
    func setUpInitialView(completion: (_ success: Bool) -> Void) {
        getUserLikedEvents()
        getUserPosts()
        completion(true)
    }
    
    @objc func signoutUser() {
        GIDSignIn.sharedInstance()?.signOut()
        let SceneDelegate = self.view.window!
        SceneDelegate.rootViewController = SignInViewController()
    }
    
    @objc func refreshCollection() {
        favoritedEvents = User.likedEvents
        posts = User.userPosts
        userCollectionView.reloadData()
        refreshController.endRefreshing()
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
        self.userCollectionView.reloadData()
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
        self.userCollectionView.reloadData()
    }
    
    @objc func segmentedControlTapped() {
        userCollectionView.reloadData()
    }

    func setUpConstraints() {
        userImage.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.top).offset(25)
            make.centerX.equalTo(view.snp.centerX)
        }
        userName.snp.makeConstraints { (make) in
            make.top.equalTo(userImage.snp.bottom).offset(20)
            make.centerX.equalTo(view.snp.centerX)
        }
        userEmail.snp.makeConstraints { (make) in
            make.top.equalTo(userName.snp.bottom).offset(15)
            make.centerX.equalTo(view.snp.centerX)
        }
        signoutButton.snp.makeConstraints { (make) in
            make.top.equalTo(userEmail.snp.bottom).offset(15)
            make.centerX.equalTo(view.snp.centerX)
            make.width.equalTo(80)
            make.height.equalTo(30)
        }
        userCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(signoutButton.snp.bottom).offset(100)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

}

extension UserProfileViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if segmentedControl.selectedIndex == 0 {
            return posts.count
        }
        return favoritedEvents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if segmentedControl.selectedIndex == 0 {
            let cell = userCollectionView.dequeueReusableCell(withReuseIdentifier: userReuseIdentifier, for: indexPath) as! EventCollectionViewCell
            let post = posts[indexPath.item]
            if User.likedEvents.contains(post) {
                post.isFavorite = true
            }
            cell.configure(event: post)
            return cell
        }
        let cell = userCollectionView.dequeueReusableCell(withReuseIdentifier: userReuseIdentifier, for: indexPath) as! EventCollectionViewCell
        cell.delegate = self
        cell.configure(event: favoritedEvents[indexPath.item])
        return cell
    }
}

extension UserProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = userCollectionView.frame.width - 45
        return CGSize(width: width, height: 225)
    }
}

extension UserProfileViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if segmentedControl.selectedIndex == 0 {
            let event = posts[indexPath.item]
            let vc = EventDetailViewController(delegate: self, eventSelected: event)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if segmentedControl.selectedIndex == 1 {
            let event = favoritedEvents[indexPath.item]
            let vc = EventDetailViewController(delegate: self, eventSelected: event)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension UserProfileViewController: EventDetailProtocol {
    func reloadEvents() {
        userCollectionView.reloadData()
    }
}

extension UserProfileViewController: FavoriteProtocol {
    
    func favoritePressed(cell: EventCollectionViewCell) {
        if segmentedControl.selectedIndex == 0 {
            let indexPath = userCollectionView.indexPath(for: cell)
            let eventPressed: Event = posts[indexPath!.item]
            eventPressed.isFavorite.toggle()
            userLiked()
            addToFirebase()
            userCollectionView.reloadData()
        }
        else if segmentedControl.selectedIndex == 1 {
            let indexPath = userCollectionView.indexPath(for: cell)
            let eventPressed: Event = favoritedEvents[indexPath!.item]
            eventPressed.isFavorite.toggle()
            userLiked()
            userUnliked()
            addToFirebase()
            userCollectionView.reloadData()
        }
    }
    
    func userLiked() {
        if segmentedControl.selectedIndex == 0 {
            for event in posts {
                if event.isFavorite && !User.likedEvents.contains(event){
                    User.likedEvents.append(event)
                }
            }
        }
        else if segmentedControl.selectedIndex == 1 {
            for event in favoritedEvents {
                if event.isFavorite && !User.likedEvents.contains(event) {
                    User.likedEvents.append(event)
                }
            }
        }
    }
    
    func userUnliked() {
        var tempArray: [Event] = []
        for event in User.likedEvents {
            if event.isFavorite {
                tempArray.append(event)
            }
        }
        User.likedEvents = []
        User.likedEvents = tempArray
        tempArray = []
    }
    
    func addToFirebase() {
           self.ref.child("Users").child(User.name!).child("Liked").removeValue()
           for event in User.likedEvents {
               self.ref.child("Users").child(User.name!).child("Liked").childByAutoId().setValue(["eventName": event.eventName, "eventDate": event.eventDate, "eventStartTime": event.eventStartTime, "eventEndTime": event.eventEndTime, "eventLocation": event.eventLocation, "eventLocationDetailed": event.eventLocationDetailed, "eventDescription": event.eventDescription, "eventTags": event.eventTags, "eventImageUrl": event.eventImageUrl, "isFavorite": event.isFavorite])
           }
       }
}
