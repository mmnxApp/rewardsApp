//
//  HomePageViewController.swift
//  Rewardsapp
//
//  Created by mayank s on 5/07/18.
//  Copyright © 2018 MS. All rights reserved.
//

import UIKit
import GoogleSignIn
import FBSDKLoginKit

class HomePageViewController: UIViewController {

    @IBOutlet weak var UserNameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func SignoutButtonTapped(_ sender: Any) {
        print("Signoutbutton pressed");
        
        //log out of google and facebook
        GIDSignIn.sharedInstance().signOut()
        FBSDKLoginManager().logOut()
        
        //return to original sign in page
        let signInPage = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        
        let appDelegate = UIApplication.shared.delegate
        appDelegate?.window??.rootViewController = signInPage
        
    }
    
    @IBAction func LoadMemberProfilebuttonTapped(_ sender: Any) {
        print("LoadMemberbuttonpressed");
    }
    

}
