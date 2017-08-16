//
//  GalleryController.swift
//  Demo
//
//  Created by Vinay Nation on 14/08/17.
//  Copyright © 2017 None. All rights reserved.
//

import UIKit
import OAuthSwift
import Alamofire
import AlamofireImage
import KRPullLoader

class GalleryController: BaseViewController,KRPullLoadViewDelegate {
    
    //var oauthswift: OAuth1Swift!
    var handler: OAuthSwiftRequestHandle!
    var photos = [Photo]()
    var page:Int = 1
    
    var currentPage = Int(1)
    var totalPages = Int(1)
    var refreshView: KRPullLoadView?
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var segment: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showIndicator()
        setupCollectionFlowLayout()
        refreshView = KRPullLoadView()
        refreshView?.delegate = self
        photoCollectionView.addPullLoadableView(refreshView!, type: .loadMore)
        get500pxPhotos{}
    }
    
    
    
    func pullLoadView(_ pullLoadView: KRPullLoadView, didChangeState state: KRPullLoaderState, viewType type: KRPullLoaderType) {
        if type == .loadMore {
            switch state {
            case let .loading(completionHandler):
                showIndicator()
                get500pxPhotos {
                    completionHandler()
                    
                    if Int(self.currentPage)==Int(self.totalPages) {
                        if let rv = self.refreshView {
                            self.photoCollectionView.removePullLoadableView(rv)
                        }
                    }
                }
            default: break
            }
            return
        }
    }
    
    
    func setupCollectionFlowLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5)
        layout.itemSize = CGSize(width: self.view.frame.size.width/2 - 10, height: self.view.frame.size.width/2 - 10) //CGSize(width: 133, height: 168)
        photoCollectionView.collectionViewLayout = layout
        photoCollectionView.reloadData()
    }
    
    
    
    func get500pxPhotos(completion: @escaping ()->Swift.Void) {
        
        let url = Constant.px500ApiBase+"photos?feature=popular&page="+"\((Int(self.currentPage) ?? 0)+1)"
        handler = oauthswift.client.get(url,
                                        success: { response in
                                            
                                            do {
                                                
                                                let httpResponse = response.response
                                                print(httpResponse)
                                                if let x = response.string {
                                                    print(x)
                                                }
                                                
                                                if let jsonObject = try response.jsonObject(options: .allowFragments) as? [String: AnyObject]
                                                {
                                                    print("jsonObject \(jsonObject)")
                                                    
                                                    if let photosArray = jsonObject["photos"] as? NSArray , photosArray.count > 0 {
                                                        
                                                        self.currentPage = (jsonObject["current_page"] as? Int) ?? 1
                                                        self.totalPages = (jsonObject["total_pages"] as? Int) ?? 1
                                                        
                                                        if self.photos.count>0 {
                                                            let phs = Photo.parsePhotoDetails(dicData: photosArray)
                                                            var ips = [IndexPath]()
                                                            for i in self.photos.count..<(self.photos.count+phs.count) {
                                                                ips.append(IndexPath(item: i, section: 0))
                                                            }
                                                            
                                                            self.photos.append(contentsOf: phs)
                                                            
                                                            self.photoCollectionView.insertItems(at: ips)
                                                        }
                                                        else {
                                                            self.photos =  Photo.parsePhotoDetails(dicData: photosArray)
                                                            self.photoCollectionView.reloadData()
                                                        }
                                                        
                                                        
                                                      
                                                        
                                                    }else{
                                                        
                                                    }
                                                    
                                                    
                                                    self.hideIndicator()
                                                }
                                                
                                            }
                                            catch {
                                                
                                            }
                                            completion()
                                            
        },
                                        failure: { error in
                                            print(error)
                                            self.hideIndicator()
        })
        
        
        
        
        
    }
  
    
    
    
    
    
    
    // MARK: - IBActions
    
    @IBAction func segmentControllerAction(_ sender: UISegmentedControl) {
         photoCollectionView.reloadData()
    }
    
    
}

extension GalleryController : UICollectionViewDataSource,UICollectionViewDelegate {
    
    //MARK: - Collection View
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let _photo = photos[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PhotoCell
        cell.photoView.af_setImage(withURL: URL(string: _photo.image_url)!)
        cell.profileImg.af_setImage(withURL: URL(string: _photo.userPic!)!)
        cell.userName.text = _photo.name
        return cell
    }
    
    
    func collectionView(_ collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout,sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize{
        
        return  (segment.selectedSegmentIndex == 0) ? CGSize(width: self.view.frame.size.width/2 - 10, height: self.view.frame.size.width/2 - 10) :  CGSize(width: collectionView.frame.size.width - 10, height: 200)
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "detail") as! PhotoDetailVC
        vc.oauthswift = self.oauthswift
        vc.photo = photos[indexPath.item]
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }

    
}






