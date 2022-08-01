//
//  SpeakerNameAndProfileDetailsTableViewCell.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 17/08/2016.
//  Copyright © 2016 Aberystwyth University. All rights reserved.
//

import UIKit

class SpeakerNameAndProfileDetailsTableViewCell: UITableViewCell {

    var alertHandler: IDUAlertHandler?
    
    /** The name of the speaker, shown as a Title. */
    @IBOutlet weak var speakerName: UILabel!
    
    /**
     
     */
    @IBOutlet weak var twitterButton: UIButton!
    
    /**
  
     */
    @IBOutlet weak var linkedInButton: UIButton!
    
    var speaker: IDUSpeaker? {
        didSet {
            setSpeakerInfo()
        }
    }
    
    /**
 
     */
    fileprivate func setSpeakerInfo() {
        
        if let name = speaker?.name {
            speakerName.text = name
        }
        
        if let twitterId = speaker?.twitterId {
            
            if twitterId.count == 0 {
                twitterButton.isHidden = true
            }
            else {
               twitterButton.setTitle("Twitter @\(twitterId)", for: UIControl.State())
               twitterButton.isHidden = false
            }
        }
        else {
            twitterButton.isHidden = true
        }
        
        linkedInButton.isHidden = (speaker?.linkedIn == nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func goToTwitter(_ sender: AnyObject) {
        if let twitterId = speaker?.twitterId {
            UIApplication.shared.open(URL(string: "https://twitter.com/\(twitterId)")!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        }
    }
    
    @IBAction func goToLinkedIn(_ sender: AnyObject) {
        
        if let linkedIn = speaker?.linkedIn {
            
            var url: URL?
            
            if let urlFromString = URL(string: linkedIn) {
                if urlFromString.scheme == nil {
                    if let httpsUrl = URL(string: "https://\(linkedIn)") {
                        url = httpsUrl
                    }
                }
                else {
                    url = urlFromString
                }
            }
            
            if let urlToOpen = url {
                UIApplication.shared.open(urlToOpen, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            }
            else {
                if let handler = alertHandler {
                    handler.presentAlert(title: "URL Problem", message: "Sorry, but there is a problem with the URL that prevents us showing the Linked In page. Please let @iOSDevUK or @digidol know.")
                }
            }
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
