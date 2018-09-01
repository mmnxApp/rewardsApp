//
//  RegisterUserViewController.swift
//  Rewardsapp
//
//  Created by mayank s on 5/07/18.
//  Copyright © 2018 MS. All rights reserved.
//

import UIKit

class RegisterUserViewController: UIViewController {

    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    @IBOutlet weak var userRepeatTextField: UITextField!
    @IBOutlet weak var userFirstname: UITextField!
    @IBOutlet weak var userLastname: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func SignUpButtonTapped(_ sender: Any) {
        
        
        print("Signup button Tapped");
        
        ///check validity of entered data
        //Raead values of the text fields
        let userName =  userNameTextField.text
        let userEmail = userEmailTextField.text
        let userPassword = userPasswordTextField.text
        let userRepeatpassword = userRepeatTextField.text
        let userFirstname = userRepeatTextField.text
        let userLastname = userRepeatTextField.text
        
        //check if any required fields are empty
        if (userName?.isEmpty)! ||
            (userEmail?.isEmpty)! ||
            (userPassword?.isEmpty)! ||
            (userRepeatpassword?.isEmpty)! ||
            (userFirstname?.isEmpty)! ||
            (userLastname?.isEmpty)!
            
        {
            //Display Alert message and return
            displayMessage(userMessage: "All fields are required to fill in")
            return
        }
        if(userPassword!.characters.count < 8){
            //Display Alert Message
            displayMessage(userMessage: "Password must be 8 characters long")
            return
        }
        
        else if((userPassword != userRepeatpassword))
        {
            //Display Alert message
            displayMessage(userMessage: "Passwords dont match! please check")
            return
        }
        //Create activity indicator look at Examples in swift in UI indicators for more
        let myActivityIndicator =
            UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        
        //Position activity indicator at the centerof view
        myActivityIndicator.center = view.center
        
        //if needed, you can prevent Activity indictot from  hiding when
        // stop animation is called
        myActivityIndicator.hidesWhenStopped = false
        
        //Start Activity indicator will stop when i get a valid request from the HTTP server
        myActivityIndicator.startAnimating()
        
        view.addSubview(myActivityIndicator)
        
        //Send HTTP Request to Register user
        guard let myURL = URL(string: "https://vhyrzfixva.execute-api.ap-southeast-2.amazonaws.com/development/post-user-signup")else {return}
        
        var request = URLRequest(url: myURL);
        request.httpMethod = "POST"//Compose a request
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let postString = ["user_name":userName!,"user_password":userPassword!,"user_email":userEmail!,"first_name":userFirstname!,"last_name":userLastname!] as [String:Any]
        
        
        
        do{
            
            let httpbody = try JSONSerialization.data(withJSONObject: postString, options: [])
            request.httpBody = httpbody
            print(request)
        }catch let error{
            print(error.localizedDescription)
            displayMessage(userMessage: "Something went wrong...Cant talk to Database")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            self.removeActivityIndicator(activityIndicator: myActivityIndicator)
            if (error != nil)
            {
                self.displayMessage(userMessage: "Could not successfully perform this request.Please try again later")
                print("error=\(String(describing:error))")
                return
            }
            
            
            do{
                let json = try JSONSerialization.jsonObject(with: data!,options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary
                
                if let parseJSON = json{
                    print(json)
                    
                    //Now we can access valuee of fields inside the database
                    let userRegistered = parseJSON["newUserRegisteredFlag"] as? String
                    if (userRegistered == "0"){
                        let InvalidEmail = parseJSON["userEmailAlreadyExistsErrFlag"] as? String
                        let InvalidUsername = parseJSON["userNameAlreadyExistsErrFlag"] as? String
                        if(InvalidUsername == "1"){
                            self.displayMessage(userMessage: "UserName Already taken choose another username ")
                            return
                        }
                        if(InvalidEmail == "1"){
                            self.displayMessage(userMessage: "Email id already used before try logging in instead")
                            return
                        }
                    }
                    
                    DispatchQueue.main.async {
                        let homePage =
                            self.storyboard?.instantiateViewController(withIdentifier: "HomePageViewController")as! HomePageViewController
                        
                        let appDelegate = UIApplication.shared.delegate
                        appDelegate?.window??.rootViewController = homePage
                    }
                }
            }catch{
                self.removeActivityIndicator(activityIndicator: myActivityIndicator)
                //display an alert dialog
                self.displayMessage(userMessage: "Could not sucessfully perform this request. please try again later")
                print(error)
            }
            
        }
        
        task.resume()
    }
    
    
    func removeActivityIndicator(activityIndicator:UIActivityIndicatorView)
    {
        DispatchQueue.main.async {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
        }
    }
    
    @IBAction func CancelButtonTapped(_ sender: Any) {
        print("Cancelbutton pressed");
        self.dismiss(animated: true, completion: nil);
    }
    
    func displayMessage(userMessage:String) ->Void{
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Alert", message: userMessage, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default)
            {
                (action:UIAlertAction!) in
                //Code in this block will trigger when OK button tapped
                print("OK button Tapped")
                DispatchQueue.main.async {
                    alertController.dismiss(animated: true, completion: nil)
                }
            }
            alertController.addAction(OKAction)
            self.present(alertController,animated: true,completion: nil)
        }
    }

}
