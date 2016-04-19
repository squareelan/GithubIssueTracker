//
//  AuthenticateViewController.swift
//  SearchMeRepos
//
//  Created by Ian on 4/18/16.
//  Copyright © 2016 Yongjun Yoo. All rights reserved.
//

import UIKit

private let segueIdentifier = "authenticateSegue"

class AuthenticateViewController: UIViewController {
	
	@IBOutlet private(set) var activityIndicator: UIActivityIndicatorView!
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.navigationBar.hidden = true
	}
	
	@IBAction private func authenticate(button: UIButton) {
		// if token is available move on to next view
		if GithubAPIManager.sharedInstance.hasOAuthToken {
			// don't try again if we have one already.
			self.performSegueWithIdentifier(segueIdentifier, sender: nil)
		} else {
			// since authentication is done at Safari, not blocking the view. (allowing multiple try)
            startNetworkActivityIndicator(activityIndicator: self.activityIndicator, userInteractionEnabled: true)
            GithubAPIManager.sharedInstance.doOAuthLogin("repo") { (success, error) in
                self.stoptNetworkActivityIndicator(activityIndicator: self.activityIndicator)
				if !success {
					// present static error message
					let alert = UIAlertController(title: "Error", message: "Unfortunately authentication failed", preferredStyle: .Alert)
					let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
					
					alert.addAction(action)
					self.presentViewController(alert, animated: true, completion: nil)
				} else {
					// move on to the next page if successful.
					self.performSegueWithIdentifier(segueIdentifier, sender: nil)
				}
			}
		}
	}
}

