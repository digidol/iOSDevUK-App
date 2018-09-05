//
//  InclusivityViewController.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 14/08/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//

import UIKit

class InclusivityViewController: UIViewController {

    @IBOutlet weak var headerImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headerImageView.backgroundColor = UIColor.iOSDevUKDarkBlue()
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            headerImageView.contentMode = .scaleAspectFit
        }
        else if UIDevice.current.userInterfaceIdiom == .phone {
            headerImageView.contentMode = .scaleAspectFill
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
