//
//  Common.swift
//  Demo
//
//  Created by My MAC on 16/08/17.
//  Copyright © 2017 None. All rights reserved.
//

import Foundation
import UIKit


class Common: NSObject {
    
    static let sharedCommon = Common()
    
    
    func showAlertWithMessageOnVC(title : String, msgstr : String, viewController : UIViewController){
        let alertController: UIAlertController = UIAlertController.init(title: title, message: msgstr, preferredStyle: UIAlertControllerStyle.alert)
        let okAction : UIAlertAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.cancel) { (okAction : UIAlertAction) in
            
        }
        alertController.addAction(okAction)
        viewController.present(alertController, animated: true, completion: nil)
        
    }

}

