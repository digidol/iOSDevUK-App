//
//  SpeakerNameAndProfileDetailsTableViewCell.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 17/08/2016.
//  Copyright © 2016 Aberystwyth University. All rights reserved.
//

import UIKit

class SpeakerNameAndProfileDetailsTableViewCell: UITableViewCell {

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
            UIApplication.shared.open(URL(string: "https://www.linkedin.com/in/\(linkedIn)")!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
