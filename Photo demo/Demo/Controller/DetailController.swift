//
//  DetailController.swift
//  Demo
//
//  Created by Soumen Bhuin on 15/08/17.
//  Copyright © 2017 None. All rights reserved.
//

import UIKit
import OAuthSwift
import Alamofire
import AlamofireImage

class DetailController: UIViewController {

    var oauthswift: OAuth1Swift!
    var handler: OAuthSwiftRequestHandle!
    var photo: Photo!
    
    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.af_setImage(withURL: URL(string: photo.image_url)!)
        
        
        getPhotoDetails()
    }
    
    
    
   
    
    func getPhotoDetails() {
        let url = Constant.px500ApiBase+"photos/\(photo.photoId!)?tags"
        let _ = oauthswift.client.get(url,
                                        success: { response in
                                            
                                            do {
                                                
                                                if let x = response.string {
                                                  //  print(x)
                                                }
                                                
                                                if let jsonObject = try response.jsonObject(options: .allowFragments) as? Dictionary<String, AnyObject> {
                                                    
                                                    let photoDetails : NSDictionary = jsonObject["photo"] as! NSDictionary
                                                    let imgUrl = photoDetails["image_url"] as? String ?? ""
                                                    self.imageView.af_setImage(withURL: URL(string:imgUrl )!)

                                                    print("==========>\(photoDetails)")
                                                }
                                                
                                            }
                                            catch {
                                                
                                            }
                                            
                                            
        },
                                        failure: { error in
                                            print(error)
        })
    }

}



extension DetailController : UITableViewDataSource,UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
}

