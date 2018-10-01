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
    
    //dictionary of values regarding the user's FB details
    var dictFB : [String : AnyObject]!
    var infoArray = [String]()
    
    
    //the following function runs everytime the view reappears, DOES NOT run on first start up
    override func viewDidAppear(_ animated: Bool) {
        
        
        //print(fbInfo.isEmpty!)
        //the following code checks if the user has already logged into FB or google - if they have, then they get directed to the homepage instead
        if((FBSDKAccessToken.current()) != nil){
            print("**User has already signed into FB**")
            
            //call the getFBUserData function
            getFBUserData {
                
                //the following code runs once complete() is sent
                
                print("**getFBUserData function complete**")
                //print(self.dictFB)
                
                if (self.dictFB != nil)
                {
                    
                    let fbUserEmail = self.dictFB["email"] as! String
                    let fbUserName = self.dictFB["name"] as! String
                    let fbUserID = self.dictFB["id"] as! String
                    print("FB User info stored successfully!")
                    print("**printing FB User info:")
                    print(fbUserEmail)
                    print(fbUserID)
                    print(fbUserName)
                    
                    //send HTTP post
                    
                    //Create activity indicator look at Examples in swift in UI indicators for more
                    let myActivityIndicator =
                        UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
                    
                    //Position activity indicator at the centerof view
                    myActivityIndicator.center = self.view.center
                    
                    //if needed, you can prevent Activity indictot from  hiding when
                    // stop animation is called
                    myActivityIndicator.hidesWhenStopped = false
                    
                    //Start Activity indicator will stop when i get a valid request from the HTTP server
                    myActivityIndicator.startAnimating()
                    
                    self.view.addSubview(myActivityIndicator)
                    
                    //Send HTTP Request to Register user
                    guard let myURL = URL(string: "https://vhyrzfixva.execute-api.ap-southeast-2.amazonaws.com/development/post-user-login")else {return}
                    
                    //guard let myURL = URL(string: "https://postman-echo.com/post")else {return}
                    
                    var request = URLRequest(url: myURL);
                    request.httpMethod = "POST"//Compose a request
                    request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.addValue("application/json", forHTTPHeaderField: "Accept")
                    
                    let postString = ["login_method": 2,"linked_fb_acc": fbUserID]as [String:Any]
                    
                    do{
                        let httpbody = try JSONSerialization.data(withJSONObject: postString, options: [])
                        request.httpBody = httpbody
                        print(request)
                    }catch let error{
                        print(error.localizedDescription)
                        self.displayMessage(userMessage: "Something went wrong...Cant talk to Database")
                        return
                    }
                   
                    let task = URLSession.shared.dataTask(with: request as URLRequest) { (data: Data?, response: URLResponse?, error: Error?) in
                        self.removeActivityIndicator(activityIndicator: myActivityIndicator)
                        
                        //read response
                        let responseString = String(data: data!, encoding: String.Encoding.utf8)
                        print("responseString = \(responseString)")
                        
                        if (error != nil)
                        {
                            self.displayMessage(userMessage: "Could not successfully perform this request.Please try again later")
                            print("error=\(String(describing:error))")
                            return
                        }
                        
                        
                        do{
                            let json = try JSONSerialization.jsonObject(with: data!,options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary
                            
                            /*
                             //print out the response
                             print("printing Json!")
                             print(json)
                             print("Json Printed!")
                             */
                            
                            if let parseJSON = json
                            {
                                //cast the json response as an int (conversions to string always give nil), if loginSuccessFlag isn't part of the response, swift converts it to a nil
                                let loginSuccessFlag = parseJSON["loginSuccessFlag"] as? Int
                                if  loginSuccessFlag == 0 {
                                    print(loginSuccessFlag)
                                    self.displayMessage(userMessage: "Login via Facebook unsuccessful")
                                    return
                                }
                            }
                        }catch{
                            self.removeActivityIndicator(activityIndicator: myActivityIndicator)
                            //display an alert dialog
                            self.displayMessage(userMessage: "Could not sucessfully perform this request. please try again later")
                            print(error)
                        }
                        
                        DispatchQueue.main.async {
                            let homePage =
                                self.storyboard?.instantiateViewController(withIdentifier: "HomePageViewController")as! HomePageViewController
                            
                            let appDelegate = UIApplication.shared.delegate
                            appDelegate?.window??.rootViewController = homePage
                        }
                        
                    }
                    
                    task.resume()
                    
                    
                    
                }
                

                
                /*
                 //change page the user sees
                 let homePage =
                 self.storyboard?.instantiateViewController(withIdentifier: "HomePageViewController")as! HomePageViewController
                 
                 let appDelegate = UIApplication.shared.delegate
                 
                 //set user's homepage to be their profile page instead of sign in
                 appDelegate?.window??.rootViewController = homePage
                 */
            }
        }
        
        
        
        if (GIDSignIn.sharedInstance().hasAuthInKeychain()){
            print("google sign in present")
            let homePage =
                self.storyboard?.instantiateViewController(withIdentifier: "HomePageViewController")as! HomePageViewController
            
            let appDelegate = UIApplication.shared.delegate
            appDelegate?.window??.rootViewController = homePage
        }
        
        
    }
    
    
    //function is fetching the user data
    func getFBUserData(completion: @escaping () -> ()){
        
        if((FBSDKAccessToken.current()) != nil)
        {
            print("**inside getFBUserData function**")
            
            //NOTE: CompletionHandler runs asynchronously as another thread!
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil)
                {
                    self.dictFB = result as! [String : AnyObject]
                    //print(result!)
                    let fbUserEmail = self.dictFB["email"] as! String
                    let fbUserName = self.dictFB["name"] as! String
                    let fbUserID = self.dictFB["id"] as! String
                    
                    print("**completing getFBUserData - printing user info:")
                    print(self.dictFB)
                    
                    //send completion notice for completionHandler, and rest of code can continue
                    completion()
                }
                
                /*//change page
                 let registerViewController = self.storyboard?.instantiateViewController(withIdentifier: "RegisterUserViewController") as! RegisterUserViewController
                 self.present(registerViewController, animated: true);
                 
                 registerViewController.userEmailTextField.text = fbuseremail as! String
                 registerViewController.userFirstname.text = fbusername as! String*/
            })
            
        }
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        // Uncomment to automatically sign in the user.
        GIDSignIn.sharedInstance().signInSilently()
        // TODO(developer) Configure the sign-in button look/feel
        // ...
    }
    
    //a test button to sign users out of FB and Google
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
        //Read values of the text fields
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
        
        
        let postString = ["login_method": 1,"login_id":userName!,"user_password":userPassword!]as [String:Any]
        
        
        do{
            let httpbody = try JSONSerialization.data(withJSONObject: postString, options: [])
            request.httpBody = httpbody
            print(request)
        }catch let error{
            print(error.localizedDescription)
            displayMessage(userMessage: "Something went wrong...Cant talk to Database")
            return
        }
        
        
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data: Data?, response: URLResponse?, error: Error?) in
            self.removeActivityIndicator(activityIndicator: myActivityIndicator)
            
            //read response
            let responseString = String(data: data!, encoding: String.Encoding.utf8)
            print("responseString = \(responseString)")
            
            if (error != nil)
            {
                self.displayMessage(userMessage: "Could not successfully perform this request.Please try again later")
                print("error=\(String(describing:error))")
                return
            }
            
            
            do{
                let json = try JSONSerialization.jsonObject(with: data!,options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary
                
                /*
                 //print out the response
                 print("printing Json!")
                 print(json)
                 print("Json Printed!")
                 */
                
                if let parseJSON = json
                {
                    //cast the json response as an int (conversions to string always give nil), if loginSuccessFlag isn't part of the response, swift converts it to a nil
                    let loginSuccessFlag = parseJSON["loginSuccessFlag"] as? Int
                    if  loginSuccessFlag == 0 {
                        print(loginSuccessFlag)
                        self.displayMessage(userMessage: "Login unsuccessful")
                        return
                    }
                }
            }catch{
                self.removeActivityIndicator(activityIndicator: myActivityIndicator)
                //display an alert dialog
                self.displayMessage(userMessage: "Could not sucessfully perform this request. please try again later")
                print(error)
            }
            
            DispatchQueue.main.async {
                let homePage =
                    self.storyboard?.instantiateViewController(withIdentifier: "HomePageViewController")as! HomePageViewController
                
                let appDelegate = UIApplication.shared.delegate
                appDelegate?.window??.rootViewController = homePage
            }
            
        }
        
        task.resume()
    }
    
    
    
    
    //function to remove activity indicator
    func removeActivityIndicator(activityIndicator:UIActivityIndicatorView)
    {
        DispatchQueue.main.async {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
        }
    }
    
    //function to handle new registrations
    @IBAction func RegisterNewaccountButttonTapped(_ sender: Any) {
        
        let registerViewController = self.storyboard?.instantiateViewController(withIdentifier: "RegisterUserViewController") as!
        RegisterUserViewController
        
        self.present(registerViewController, animated: true);
        
    }
    
    //function to display alerts
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
    
    func httpPost(fbUserID:String) -> Void {
        print("yo mama")
        
        /*
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
         
         
         var request = URLRequest(url: myURL);
         request.httpMethod = "POST"//Compose a request
         request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
         request.addValue("application/json", forHTTPHeaderField: "Content-Type")
         request.addValue("application/json", forHTTPHeaderField: "Accept")
         
         
         let postString = ["login_method": 2,"linked_fb_acc":<FACEBOOK ID HERE>]as [String:Any]
         
         
         do{
         let httpbody = try JSONSerialization.data(withJSONObject: postString, options: [])
         request.httpBody = httpbody
         print(request)
         }catch let error{
         print(error.localizedDescription)
         displayMessage(userMessage: "Something went wrong...Cant talk to Database")
         return
         }
         
         
         
         let task = URLSession.shared.dataTask(with: request as URLRequest) { (data: Data?, response: URLResponse?, error: Error?) in
         self.removeActivityIndicator(activityIndicator: myActivityIndicator)
         
         //read response
         let responseString = String(data: data!, encoding: String.Encoding.utf8)
         print("responseString = \(responseString)")
         
         if (error != nil)
         {
         self.displayMessage(userMessage: "Could not successfully perform this request.Please try again later")
         print("error=\(String(describing:error))")
         return
         }
         
         
         do{
         let json = try JSONSerialization.jsonObject(with: data!,options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary
         
         /*
         //print out the response
         print("printing Json!")
         print(json)
         print("Json Printed!")
         */
         
         if let parseJSON = json
         {
         //cast the json response as an int (conversions to string always give nil), if loginSuccessFlag isn't part of the response, swift converts it to a nil
         let loginSuccessFlag = parseJSON["loginSuccessFlag"] as? Int
         if  loginSuccessFlag == 0 {
         print(loginSuccessFlag)
         self.displayMessage(userMessage: "Login unsuccessful")
         return
         }
         }
         }catch{
         self.removeActivityIndicator(activityIndicator: myActivityIndicator)
         //display an alert dialog
         self.displayMessage(userMessage: "Could not sucessfully perform this request. please try again later")
         print(error)
         }
         
         DispatchQueue.main.async {
         let homePage =
         self.storyboard?.instantiateViewController(withIdentifier: "HomePageViewController")as! HomePageViewController
         
         let appDelegate = UIApplication.shared.delegate
         appDelegate?.window??.rootViewController = homePage
         }
         
         }
         
         task.resume()
         
         
         
         
         
         return*/
    }
    
    
}

