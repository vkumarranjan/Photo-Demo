//
//  LoginController.swift
//  Demo
//
//  Created by Vinay Nation on 14/08/17.
//  Copyright © 2017 None. All rights reserved.
//

import UIKit
import OAuthSwift

class LoginController: BaseViewController {
    
   // var oauthswift: OAuth1Swift!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    
    @IBAction func loginAction(_ sender: UIButton) {
        self.view.isUserInteractionEnabled = false
        authorize500px()
    }
    
    
    func authorize500px() {
        
        oauthswift = OAuth1Swift(
            consumerKey:    Constant.px500ApiKey,
            consumerSecret: Constant.px500ApiSecret,
            requestTokenUrl: "https://api.500px.com/v1/oauth/request_token",
            authorizeUrl:    "https://api.500px.com/v1/oauth/authorize",
            accessTokenUrl:  "https://api.500px.com/v1/oauth/access_token"
        )
        
        // authorize
        let _ = oauthswift.authorize(
            withCallbackURL: URL(string: "oauth-swift://oauth-callback/5005x")!,
            success: { credential, response, parameters in
                print(credential.oauthToken)
                print(credential.oauthTokenSecret)
                self.view.isUserInteractionEnabled = true
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "gallery") as! GalleryController
                    vc.oauthswift = self.oauthswift
                    self.navigationController?.pushViewController(vc, animated: true)
                
        },
            failure: { error in
                print(error.localizedDescription)
                self.view.isUserInteractionEnabled = true
        }
        )
    }
    
   
    
    
    
    func authorize() {
        
        oauthswift = OAuth1Swift(
            consumerKey:    Constant.flickrApiKey,
            consumerSecret: Constant.flickrApiSecret,
            requestTokenUrl: "https://www.flickr.com/services/oauth/request_token",
            authorizeUrl:    "https://www.flickr.com/services/oauth/authorize",
            accessTokenUrl:  "https://www.flickr.com/services/oauth/access_token"
        )
        
        // authorize
        let _ = oauthswift.authorize(
            withCallbackURL: URL(string: "oauth-swift://oauth-callback/flickr")!,
            success: { credential, response, parameters in
                print(credential.oauthToken)
                print(credential.oauthTokenSecret)
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "gallery") as! GalleryController
                vc.oauthswift = self.oauthswift
                self.navigationController?.pushViewController(vc, animated: true)
                
        },
            failure: { error in
                print(error.localizedDescription)
        }
        )
    }
    
}

