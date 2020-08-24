//
//  TabBarController.swift
//  Eventful
//
//  Created by Amy Chin Siu Huang on 5/9/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBar.isTranslucent = false
        let tabBarAppearance = UITabBar.appearance()
        tabBarAppearance.tintColor = UIColor(red: 0.2784, green: 0.6392, blue: 1, alpha: 1.0)
        let fontAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]
        UITabBarItem.appearance().setTitleTextAttributes(fontAttributes, for: .normal)

        let eventVC = UINavigationController(rootViewController: EventsViewController())
        eventVC.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "eventtabicon"), selectedImage: UIImage(named: "eventtabicon"))
        eventVC.tabBarItem.imageInsets = UIEdgeInsets.init(top: 5,left: 0,bottom: -5,right: 0)
        
        let userVC = UINavigationController(rootViewController: UserProfileViewController())
        userVC.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "profiletabicon"), selectedImage: UIImage(named: "profiletabicon"))
        userVC.tabBarItem.imageInsets = UIEdgeInsets.init(top: 5,left: 0,bottom: -5,right: 0)
        
        let tabBars = [eventVC, userVC]
        
        viewControllers = tabBars

    }
    

}
