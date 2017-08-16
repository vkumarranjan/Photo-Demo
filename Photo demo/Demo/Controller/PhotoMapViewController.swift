//
//  PhotoMapViewController.swift
//  Demo
//
//  Created by Vinay Nation on 15/08/17.
//  Copyright © 2017 None. All rights reserved.
//

import UIKit
import MapKit


enum ViewType : Int {
    
    case Map = 0
    case Table
    
}


class PhotoMapViewController: BaseViewController {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var photoMapView: MKMapView!
    
    @IBOutlet weak var tagTableView: UITableView!
    @IBOutlet weak var backView: UIView!
    
    var viewType: ViewType?
    var tags = [String]()
    var lat: Double!
    var long: Double!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        backView.layer.cornerRadius = 5.0
        backView.layer.masksToBounds = true
        buttoncustomisation(btn: closeButton)
        
        
        
        if (viewType == ViewType.Map) {
            backView.isHidden = true
            photoMapView.isHidden = false
            setupMap()
        }else{
            
            photoMapView.isHidden = true
            tagTableView.reloadData()
        }
        


        // Do any additional setup after loading the view.
    }

    func setupMap(){
        photoMapView.mapType = MKMapType.standard
        let location = CLLocationCoordinate2D(latitude: lat,longitude: long)
        
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        photoMapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        photoMapView.addAnnotation(annotation)
    }
    
    @IBAction func closeButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


extension PhotoMapViewController: UITableViewDelegate,UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell  = tableView.dequeueReusableCell(withIdentifier: "tagCell", for: indexPath)
        cell.textLabel?.text = tags[indexPath.row]
        return cell
    }
    
}


