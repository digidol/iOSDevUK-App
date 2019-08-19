//
//  LocationViewController.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 09/08/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//

import UIKit
import SafariServices

class LocationViewController: UIViewController, SFSafariViewControllerDelegate {

    var location: IDULocation? {
        didSet {
            initialiseLocation()
        }
    }
    
    @IBOutlet weak var headerImageView: UIImageView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var notes: UILabel!
    
    @IBOutlet weak var webLinkButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialiseLocation()
        
        if let image = UIImage(named: "LocationBackground") {
            headerImageView.backgroundColor = UIColor(patternImage: image)
        }
        else {
            headerImageView.backgroundColor = UIColor.iOSDevUKDarkBlue()
        }
    }

    func initialiseLocation() {
        if let location = location,
           let imageView = imageView {
            
            imageView.displayImage(named: location.recordName, withDefault: "LocationPin")
            imageView.addBorderWithCorner()
            
            name.text = location.name
            notes.text = location.note
            
            webLinkButton.isHidden = location.webLink == nil
            
            if !webLinkButton.isHidden {
                webLinkButton.setTitle("View \(location.webLink?.name ?? "More Information")", for: .normal)
            }
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showLink(_ sender: AnyObject) {
        if let url = location?.webLink?.url {
            let webViewController = SFSafariViewController(url: url)
            webViewController.delegate = self
            self.present(webViewController, animated: true, completion: nil)
        }
        
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }

}
