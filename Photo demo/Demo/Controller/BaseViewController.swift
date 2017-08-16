//
//  BaseViewController.swift
//  Demo
//
//  Created by Vinay Nation on 15/08/17.
//  Copyright © 2017 None. All rights reserved.
//

import UIKit
import OAuthSwift

class BaseViewController: UIViewController {
    
    var photo:Photo!
    var oauthswift: OAuth1Swift!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func showIndicator(){
        
        BBProgressIndicator.show()
    }
    
    
    func hideIndicator(){
        
        BBProgressIndicator.hide()
    }
    

    
    func  buttoncustomisation(btn: UIButton){
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 3.0
        btn.layer.borderWidth = 2.0
        btn.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        
    }
    
    
}
