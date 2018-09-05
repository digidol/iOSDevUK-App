//
//  AttendeeInfoTableViewController.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 17/08/2016.
//  Copyright © 2016 Aberystwyth University. All rights reserved.
//

import UIKit
import SafariServices

class AttendeeInfoTableViewController: ExpandedTextCellTableViewController, SFSafariViewControllerDelegate {

    let cellIdentifiers = ["tickets", "joining", "accommodation", "parking"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellIdentifiers.count + 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row < cellIdentifiers.count {
            return tableView.dequeueReusableCell(withIdentifier: cellIdentifiers[indexPath.row], for: indexPath)
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "note", for: indexPath)
        
        if indexPath.row == 4 {
            if let noteCell = cell as? ExpandingTextLabelTableViewCell {
                noteCell.contentText = "Twitter: please tweet with #iosdevuk, and we'll be tweeting official info as @iosdevuk."
            }
        }
        
        if indexPath.row == 5 {
            if let noteCell = cell as? ExpandingTextLabelTableViewCell {
                noteCell.contentText = "There are five minute talks on Wednesday morning and on Thursday morning - one set will be about exciting new features from WWDC, and the other for general talks. If you would like to do five minutes on a topic, please volunteer and we'll add you to the list."
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //UIApplication.shared.openURL(URL(string: "http://users.aber.ac.uk/nst/iosdevuk/jump.php?to=\(cellIdentifiers[indexPath.row])")!)
        if let url = URL(string: "http://users.aber.ac.uk/nst/iosdevuk/jump.php?to=\(cellIdentifiers[indexPath.row])") {
            let safariViewController = SFSafariViewController(url: url)
            safariViewController.delegate = self
            self.present(safariViewController, animated: true, completion: nil)
            
        }
        
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }

}
