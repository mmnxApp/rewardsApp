//
//  HomePageViewController.swift
//  Rewardsapp
//
//  Created by mayank s on 5/07/18.
//  Copyright © 2018 MS. All rights reserved.
//

import UIKit

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
        print("Signoutbutton presed");
    }
    
    @IBAction func LoadMemberProfilebuttonTapped(_ sender: Any) {
        print("LoadMemberbuttonpressed");
    }
    

}
