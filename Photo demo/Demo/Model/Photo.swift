//
//  Photo.swift
//  Demo
//
//  Created by Vinay Nation on 15/08/17.
//  Copyright © 2017 None. All rights reserved.
//

import Foundation


class Photo {
    
    let image_url: String
    var cameraName : String?
    var comments_count : Int?
    var favorites_count: Int?
    var photo_description : String?
    var latitude: Float?
    var longitude: Float?
    var name : String?
    var username: String?
    var height: Int?
    var width: Int?
    var photoId: String?
    var userPic: String?
    var userName: String?
    
    
    
    
    
    init(imageUrl: String) {
        
        self.image_url = imageUrl
        
    }
    
    
    
    class  func parsePhotoDetails(dicData: NSArray) -> [Photo] {
        
        
        
        let photos = dicData.map { (item)  -> Photo in
            let _item = item as! NSDictionary
            let imgUrl = _item["image_url"] as? String ?? ""
            
            let _photo = Photo(imageUrl: imgUrl)
            _photo.photoId = String(_item["id"] as! Int)
            _photo.cameraName = _item["camera"] as? String ?? ""
            _photo.photo_description = _item["description"] as? String ?? ""
            _photo.name = _item["name"] as? String ?? ""
            _photo.username = _item["username"] as? String ?? ""
            _photo.latitude = _item["latitude"] as? Float
            _photo.longitude = _item["longitude"] as? Float
            _photo.height = _item["height"] as? Int ?? 50
            _photo.width = _item["width"] as? Int ?? 50
            _photo.favorites_count = _item["favorites_count"] as? Int ?? 0
            
             let _userInfo = (_item.value(forKey: "user") as! NSDictionary)
            
            _photo.userPic = _userInfo["userpic_https_url"] as? String ?? ""
            
             _photo.userPic = _photo.userPic?.replacingOccurrences(of: "1.jpg?2", with: "3.jpg?2")
                        
            _photo.userName = _userInfo["fullname"] as? String  ?? ""
            
            return  _photo
        }
        
        return photos
        
    }
    
    
    
    
}





