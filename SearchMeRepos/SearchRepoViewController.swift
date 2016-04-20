//
//  SearchRepoViewController.swift
//  SearchMeRepos
//
//  Created by Ian on 4/18/16.
//  Copyright © 2016 Yongjun Yoo. All rights reserved.
//

import UIKit

private let segueIdentifier = "repoListSegue"

class SearchRepoViewController: UIViewController {

	@IBOutlet private(set) var activityIndicator: UIActivityIndicatorView!
	@IBOutlet private(set) var userIdTextField: UITextField!
	private var userName: String?
	private var repos: [GithubRepo]?

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.navigationBar.hidden = true
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == segueIdentifier {
			if let destination = segue.destinationViewController as? RepoListViewController {
				destination.repoList = repos
				destination.userName = userName
			}
		}
	}

	@IBAction private func searchRepo(button: UIButton) {
		guard let userName = userName else {
			return
		}

        startNetworkActivityIndicator(activityIndicator: self.activityIndicator, userInteractionEnabled: false)
		GithubAPIManager.sharedInstance.fetchUserRepos(userName) { (result) in
            self.stoptNetworkActivityIndicator(activityIndicator: self.activityIndicator)
			switch result {
			case .Error(let msg, let code):
				switch code {
				case ErrorCase.InvalidToken.rawValue:
					// try to get authorizd again for no token.
					let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .Alert)
					let action = UIAlertAction(title: "OK", style: .Default, handler: { (action) in
						// navigate back to root view controller for fetching a new token
						self.navigationController?.popToRootViewControllerAnimated(true)
					})
					alert.addAction(action)
					self.presentViewController(alert, animated: true, completion: nil)

				default:
					// just show alert with error message.
					let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .Alert)
					let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
					alert.addAction(action)
					self.presentViewController(alert, animated: true, completion: nil)
				}

			case .Success(let repos):
				// save repository list and move to the next view
				self.repos = repos
				self.performSegueWithIdentifier(segueIdentifier, sender: nil)
			}
		}
	}
}

extension SearchRepoViewController: UITextFieldDelegate {
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}

	func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
		// update userName
		if let currentText = textField.text as NSString? {
			userName = currentText.stringByReplacingCharactersInRange(range, withString: string).trim() // trim the string when store it in.
		}
		return true
	}
}

extension String {
	func trim() -> String {
		return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
	}
}
