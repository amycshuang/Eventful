//
//  SignInViewController.swift
//  Eventful
//
//  Created by Amy Chin Siu Huang on 5/12/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import SnapKit

class SignInViewController: UIViewController {

    var appNameLabel: UILabel!
    var signInButton: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        self.navigationController?.view.backgroundColor = .clear
        self.navigationController?.navigationBar.tintColor = .clear
        self.navigationController?.isNavigationBarHidden = true
        
        appNameLabel = UILabel()
        appNameLabel.font = UIFont.boldSystemFont(ofSize: 40)
        appNameLabel.textAlignment = .center
        appNameLabel.text = "Eventful"
        view.addSubview(appNameLabel)

        signInButton = GIDSignInButton()
        signInButton.style = .wide
        signInButton.colorScheme = .light
        view.addSubview(signInButton)
        
        setUpConstraints()
    }
    
    func setUpConstraints() {
        
        appNameLabel.snp.makeConstraints { (make) in
            make.width.equalToSuperview().inset(15)
            make.bottom.equalTo(view.snp.centerY).offset(-125/2)
            make.centerX.equalToSuperview()
        }
        
        signInButton.snp.makeConstraints { (make) in
            make.top.equalTo(appNameLabel.snp.bottom).offset(70)
            make.centerX.equalToSuperview()
        }
    }

}
