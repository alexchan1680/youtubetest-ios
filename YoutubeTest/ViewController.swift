//
//  ViewController.swift
//  YoutubeTest
//
//  Created by Alex on 10/3/2016.
//

import UIKit

class ViewController: UIViewController {
    
    let authManager = YoutubeAuthManager(clientID: kYoutubeAPIClientID, authKeyChainName: kYoutubeAuthKeyChain)
    var uploadManager:YoutubeUploadManager?
    var service:GTLServiceYouTube?{
        didSet {
            if let service = self.service{
                uploadManager = YoutubeUploadManager(service: service)
                updateUIWithLoginState(true)
            } else {
                uploadManager = nil
                updateUIWithLoginState(false)
            }
        }
    }
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if let service = authManager.authorizedService {
            self.service = service
        } else {
            updateUIWithLoginState(false)
        }
    }
    
    func updateUIWithLoginState(loggedIn:Bool){
        if loggedIn{
            userNameLabel.text = service?.authorizer.userEmail
            
            loginButton.setTitle("Sign Out", forState: [.Normal])
        } else {
            userNameLabel.text = "Please Sign In"
            loginButton.setTitle("Sign In", forState: [.Normal])
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginClicked(sender: AnyObject) {
        if let _ = service {
            //Log Out.
            authManager.logOut()
            
            //clear service & upload manager
            service = nil
        } else {
            // present view controller
            let authVC = authManager.authViewControllerWithCompletionHandler{ (authVC, service, error) -> Void in
                authVC.dismissViewControllerAnimated(true){ [weak self] in
                    guard let _self = self else {
                        return
                    }
                    if let _ = error {
                        let alertVC = UIAlertController(title: nil, message: "Failed To Sign In", preferredStyle: .Alert).then{
                            $0.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                        }
                        
                        _self.presentViewController(alertVC, animated: true, completion: nil)
                    }
                    _self.service = service
                }
            }
            presentViewController(authVC, animated: true, completion: nil)
        }
    }
}

