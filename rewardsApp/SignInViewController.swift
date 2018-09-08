//
//  SignInViewController.swift
//  Rewardsapp
//
//  Created by mayank s on 5/07/18.
//  Copyright © 2018 MS. All rights reserved.
//

import UIKit
import FacebookLogin
import FBSDKLoginKit
import GoogleSignIn

class SignInViewController: UIViewController, GIDSignInUIDelegate {

    @IBOutlet weak var UserNameTextfield: UITextField!
    @IBOutlet weak var UserPasswordTextField: UITextField!
    
    
    /*
    //function is fetching the user data
    func getFBUserData() {
        if((FBSDKAccessToken.current()) != nil)
        {
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
            if (error == nil)
                {
                self.dict = result as! [String : AnyObject]
                print(result!)
                let fbuseremail = self.dict["email"]
                let fbusername = self.dict["name"]
                print(self.dict)
                
                //change page
                let registerViewController = self.storyboard?.instantiateViewController(withIdentifier: "RegisterUserViewController") as! RegisterUserViewController
                self.present(registerViewController, animated: true);
                    
                registerViewController.userEmailTextField.text = fbuseremail as! String
                registerViewController.userFirstname.text = fbusername as! String
                }
            })
        }
        
    }*/
    
    
    var dict : [String : AnyObject]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        // Uncomment to automatically sign in the user.
        //GIDSignIn.sharedInstance().signInSilently()
        
        // TODO(developer) Configure the sign-in button look/feel
        // ...
        
    }
    
    @IBAction func didTapSignOut(_ sender: Any) {
        
        //log out of google and facebook
        GIDSignIn.sharedInstance().signOut()
        FBSDKLoginManager().logOut()
        displayMessage(userMessage: "Logged out")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
 
    
    @IBAction func SigninbuttonTapped(_ sender: Any) {
        
        print("SigninbuttonTapped");
        //Raead values of the text fields
        let userName =  UserNameTextfield.text
        let userPassword = UserPasswordTextField.text
        
        if ((userName?.isEmpty)!||(userPassword?.isEmpty)!)
        {
            //Display alert message
            print("User name \(String(describing: userName)) or password \(String(describing:userPassword)) is empty")
            displayMessage(userMessage: "One of the required fields is missing")
            
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
       guard let myURL = URL(string: "https://vhyrzfixva.execute-api.ap-southeast-2.amazonaws.com/development/post-user-login")else {return}
        
        //guard let myURL = URL(string: "https://postman-echo.com/post")else {return}
        
        var request = URLRequest(url: myURL);
        request.httpMethod = "POST"//Compose a request
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let postString = ["login_id":userName!,"user_password":userPassword!,"linked_fb_acc":" ","linked_google_acc":" "]as [String:Any]
        //let postString = ["foo1":userName!,"foo2":userPassword!]as [String:AnyObject]
        
        
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
                    let loginsuccesful = parseJSON["loginsucessful"] as? String
                        if (loginsuccesful == "0"){
                            self.displayMessage(userMessage: "Could not successfully login check username/password ")
                            return
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
    
    @IBAction func RegisterNewaccountButttonTapped(_ sender: Any) {
        
        let registerViewController = self.storyboard?.instantiateViewController(withIdentifier: "RegisterUserViewController") as!
        RegisterUserViewController
        
        self.present(registerViewController, animated: true);
        
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
                    self.dismiss(animated: true, completion: nil)
                }
            }
            alertController.addAction(OKAction)
            self.present(alertController,animated: true,completion: nil)
        }
    }
    
    


}

