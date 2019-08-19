//
//  AboutAppViewController.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 13/08/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//

import UIKit
import MessageUI

class AboutAppViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let buildDateTime = formatter.date(from: String(Bundle.main.buildVersionNumber.prefix(10)))
        
        formatter.dateFormat = "MMMM yyyy"
        versionLabel.text = "Version: \(Bundle.main.releaseVersionNumber) • \(formatter.string(from: buildDateTime!))"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func emailDevelopers(_ sender: AnyObject) {
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["nst@aber.ac.uk"])
            mail.setSubject("iOSDevUK App")
            
            present(mail, animated: true)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        controller.dismiss(animated: true)
    }
    
    @IBAction func showTwitter(_ sender: AnyObject) {
        UIApplication.shared.open(URL(string: "https://twitter.com/digidol")!, options: [:], completionHandler: nil)
    }

}
