//
//  ViewController.swift
//  ADDN
//
//  Created by 黄 康平 on 4/20/17.
//  Copyright © 2017 黄 康平. All rights reserved.
//

import UIKit
import Alamofire
import SwiftGifOrigin

var username = "guest"
var age = 25
var gender = "Male"
var duration = 2.0
var weight = 65.0
var height = 175.0
var loadstatus = true
var personimage = #imageLiteral(resourceName: "default_profile")
var bmi = weight/(height/100)/(height/100)
let brightgrey = UIColor(red: 230.0/255, green: 230.0/255, blue: 230.0/255, alpha: 1)

extension UIImageView {
    
    func setRounded() {
        self.layer.masksToBounds = false
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.cornerRadius = self.frame.height/2
        self.clipsToBounds = true
    }
}

class ViewController: UIViewController, FBSDKLoginButtonDelegate {
    let loginButton: FBSDKLoginButton = {
        let button = FBSDKLoginButton()
        return button
    }()

    @IBOutlet weak var signup: UITextField!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var profileimage: UIImageView!
    @IBOutlet weak var reportoutput: UIButton!
    @IBOutlet weak var editprofile: UIButton!
    @IBOutlet weak var editlabel: UILabel!
    @IBOutlet weak var reportlabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(loginButton)
        signup.frame = CGRect(x: 0, y: 0.4*view.frame.height-30, width:view.frame.width, height: 30)
        loginButton.frame = CGRect(x: 0, y: 0.4*view.frame.height, width: view.frame.width, height: 50)
        logoutButton.frame = CGRect(x: view.frame.width-51, y: 25, width: 46, height: 30)
        logoutButton.layer.cornerRadius = 5
        logoutButton.addTarget(self, action: #selector(ViewController.buttonClicked(_:)), for: .touchUpInside)
        reportoutput.isHidden = true
        reportlabel.isHidden = true
        reportoutput.frame = CGRect(x: 0.375*view.frame.width, y: 0.65*view.frame.height, width: 0.25*view.frame.width, height: 0.25*view.frame.width)
        editprofile.isHidden = true
        editlabel.isHidden = true
        editprofile.frame = CGRect(x: 0.375*view.frame.width, y: 0.45*view.frame.height, width: 0.25*view.frame.width, height: 0.25*view.frame.width)
        editlabel.center.x = editprofile.center.x
        editlabel.center.y = editprofile.center.y+0.5*editprofile.frame.height
        reportlabel.center.x = reportoutput.center.x
        reportlabel.center.y = reportoutput.center.y+0.59*reportoutput.frame.height
        logoutButton.addTarget(self, action: #selector(ViewController.buttonClicked(_:)), for: .touchUpInside)
        loginButton.delegate = self
        profileimage.frame = CGRect(x: 0.3*view.frame.width, y: 70, width: 0.4*view.frame.width, height: 0.4*view.frame.width)
        profileimage.setRounded()
        if (FBSDKAccessToken.current() != nil && loadstatus == true){
            profileimage.loadGif(name: "1")
            fetchprofile()
            self.loginButton.isHidden = true
            self.logoutButton.isHidden = false
        }
        else if (FBSDKAccessToken.current() != nil && loadstatus == false){
            self.loginButton.isHidden = true
            self.logoutButton.isHidden = false
            self.profileimage.image = personimage
            self.signup.text = "Hi, "+username
            self.reportoutput.isHidden = false
            self.reportlabel.isHidden = false
            self.editprofile.isHidden = false
            self.editlabel.isHidden = false
        }
        else {
            self.loginButton.isHidden = false
            self.logoutButton.isHidden = true
            
        }
        
        Alamofire.request("http://localhost:3000/cities?select=name").responseJSON { response in
            if let JSON = response.result.value {
               print("JSON: \(JSON)")
            }
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print(age)
        print(height)
    }
    
    func buttonClicked(_ sender: AnyObject?) {
        if sender === logoutButton {
            print("starting logout")
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            profileimage.image = #imageLiteral(resourceName: "default_profile")
            signup.text = "SIGN UP"
            self.logoutButton.isHidden = true
            self.loginButton.isHidden = false
            self.reportoutput.isHidden = true
            self.reportlabel.isHidden = true
            self.editprofile.isHidden = true
            self.editlabel.isHidden = true
        }
        if sender === reportoutput {
            performSegue(withIdentifier: "reportseque", sender: self)
        }
        if sender === editprofile {
            performSegue(withIdentifier: "profileseque", sender: self)
        }
    }

    
    func fetchprofile() {
        print("fetch profile")
        let graphRequest:FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"first_name, gender, email, picture.type(large)"])
        graphRequest.start(completionHandler: {(connection, result, error) -> Void in
            if ((error) != nil)
            {
                print("Error: \(error)")
            }
            else
            {
                do {
                    loadstatus = false
                    let data:[String:AnyObject] = result as! [String : AnyObject]
                    let firstname = data["first_name"]!
                    let gender = data["gender"]!
                    let urlData = data["picture"]?.value(forKey: "data") as! [String : AnyObject]
                    let url = urlData["url"]!
                    print(firstname)
                    username = firstname as! String
                    self.signup.text = "Hi, "+username
                    print(gender)
                    print(url)
                    let PictureURL = URL(string: url as! String)!
                    
                    // Creating a session object with the default configuration.
                    // You can read more about it here https://developer.apple.com/reference/foundation/urlsessionconfiguration
                    let session = URLSession(configuration: .default)
                    
                    // Define a download task. The download task will download the contents of the URL as a Data object and then you can do what you wish with that data.
                    let downloadPicTask = session.dataTask(with: PictureURL) { (data, response, error) in
                        // The download has finished.
                        if let e = error {
                            print("Error downloading profile picture: \(e)")
                        } else {
                            // No errors found.
                            // It would be weird if we didn't have a response, so check for that too.
                            if let res = response as? HTTPURLResponse {
                                print("Downloaded profile picture with response code \(res.statusCode)")
                                if let imageData = data {
                                    // Finally convert that Data into an image and do what you wish with it.
                                    let image = UIImage(data: imageData)
                                    // Do something with your image.
                                    personimage = image!
                                    self.profileimage.image = image
                                    self.reportoutput.isHidden = false
                                    self.reportlabel.isHidden = false
                                    self.editprofile.isHidden = false
                                    self.editlabel.isHidden = false
                                } else {
                                    print("Couldn't get image: Image is nil")
                                }
                            } else {
                                print("Couldn't get response code for some reason")
                            }
                        }
                    }
                    
                    downloadPicTask.resume()
                }
            }
        })
    }

    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if (FBSDKAccessToken.current() != nil) {
            self.logoutButton.isHidden = false
            self.loginButton.isHidden = true
            profileimage.loadGif(name: "1")
        }
        print("completed login")
        fetchprofile()
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
