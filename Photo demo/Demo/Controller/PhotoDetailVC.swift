//
//  PhotoDetailVC.swift
//  Demo
//
//  Created by Vinay Nation on 15/08/17.
//  Copyright © 2017 None. All rights reserved.
//

import UIKit
import OAuthSwift
import Alamofire
import AlamofireImage


class PhotoDetailVC: BaseViewController {

    //var photo: Photo!
    //var oauthswift: OAuth1Swift!
    var handler: OAuthSwiftRequestHandle!
    var photoDetails = NSDictionary()
    
    
    @IBOutlet weak var showOnMapButton: UIButton!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var userProfileImg: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var voteButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupButtons()
        imgView.af_setImage(withURL:  URL(string: photo.image_url )!)
        userProfileImg.af_setImage(withURL: URL(string: photo.userPic!)!)
        userName.text = photo.userName
        showIndicator()
        getPhotoDetails()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    func getPhotoDetails() {
        let url = Constant.px500ApiBase+"photos/\(photo.photoId!)?tags=1"
        let _ = oauthswift.client.get(url,
                                      success: { response in
                                        
                                        do {
                                            
                                            if let x = response.string {
                                                print("=====> \(x)")
                                            }
                                            
                                            if let jsonObject = try response.jsonObject(options: .allowFragments) as? Dictionary<String, AnyObject> {
                                                
                                                let photoDetailsObj : NSDictionary = jsonObject["photo"] as! NSDictionary
                                                self.photoDetails = photoDetailsObj
                                                let imgUrl = photoDetailsObj["image_url"] as? String ?? ""
                                                self.imgView.af_setImage(withURL:  URL(string: imgUrl)!)
                                                let isVoted: Bool =  photoDetailsObj["voted"] as! Bool
                                                self.isPhotoLiked(isLiked: isVoted)
                                                print("==========>\(photoDetailsObj)")
                                            }
                                            
                                            self.hideIndicator()
                                            
                                        }
                                        catch {
                                            
                                        }
                                        
                                        
        },
                                      failure: { error in
                                        self.hideIndicator()
                                        print(error)
        })
    }

    
    
    func doLikePhoto() {
        
        let url = Constant.px500ApiBase+"photos/\(photo.photoId!)/vote?vote=1"
        let _ = oauthswift.client.post(url,
                                       success: { response in
                                        
                                        do {
                                            
                                            if let x = response.string {
                                                print(x)
                                            }
                                            
                                            if let jsonObject = try response.jsonObject(options: .allowFragments) as? Dictionary<String, AnyObject> {
                                                print(jsonObject)
                                                self.isPhotoLiked(isLiked: true)
                                                
                                            }
                                            self.hideIndicator()
                                            
                                        }
                                        catch {
                                            
                                        }
                                        
                                        
        },
                                       failure: { error in
                                        self.hideIndicator()
                                        print(error)
        })
    }
    
    
    
    
    // MARK IBActions
    
    @IBAction func buttonTapAction(_ sender: UIButton) {
        
        if sender.tag == 0 {
            showMapView()
        }else{
            showTags()
        }
    }
    
    @IBAction func doLikePhotoAction(_ sender: UIButton) {
        showIndicator()
        doLikePhoto()
    }
    
    
    func isPhotoLiked(isLiked:Bool){
        
        if isLiked {
            self.voteButton.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            self.voteButton.isUserInteractionEnabled = false
        }else{
            self.voteButton.backgroundColor = #colorLiteral(red: 0.4392156899, green: 0.01176470611, blue: 0.1921568662, alpha: 1)
            self.voteButton.isUserInteractionEnabled = true
        }
        
    }
    
    
    
}

extension PhotoDetailVC {
    
    
    
    func showTags(){
        
        
        if  let tags = photoDetails["tags"] as? [String] {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PhotoMap") as! PhotoMapViewController
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .crossDissolve
            vc.viewType = ViewType.Table
            vc.tags =  tags//photoDetails["tags"] as! [String]
            self.navigationController?.present(vc, animated: false, completion: nil)
        }else{
            Common.sharedCommon.showAlertWithMessageOnVC(title: "Demo", msgstr: "No Tags", viewController: self)

        }
        
        
    }
    
    func showMapView(){
        
        if let lat = photo.latitude, lat > 0 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PhotoMap") as! PhotoMapViewController
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .crossDissolve
            vc.viewType = ViewType.Map
            vc.lat = Double(photo.latitude!)
            vc.long = Double(photo.longitude!)
            self.navigationController?.present(vc, animated: false, completion: nil)
        }else{
            
            Common.sharedCommon.showAlertWithMessageOnVC(title: "Demo", msgstr: "Location not available", viewController: self)
            print("Location not Avialable")
        }
        
    }
    
    func setupButtons(){
        self.buttoncustomisation(btn: showOnMapButton)
        self.buttoncustomisation(btn: tagButton)
        self.buttoncustomisation(btn: voteButton)
    }
    
}


