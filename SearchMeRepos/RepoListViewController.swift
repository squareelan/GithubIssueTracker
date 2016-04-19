//
//  RepoListViewController.swift
//  SearchMeRepos
//
//  Created by Ian on 4/19/16.
//  Copyright © 2016 Yongjun Yoo. All rights reserved.
//

import UIKit

private let cellIdentifier = "repoCell"
private let segueIdentifier = "issueListSegue"

class RepoListViewController: UIViewController {
	
	@IBOutlet private(set) var activityIndicator: UIActivityIndicatorView!
	var userName: String?
	var repoList: [GithubRepo]?
	private var issueList: [GithubIssue]?
	private var selectedRepo: GithubRepo?
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		self.title = userName
		navigationController?.navigationBar.hidden = false
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == segueIdentifier {
			let destination = segue.destinationViewController as! IssueListViewController
			destination.repo = selectedRepo
			destination.issueList = issueList
		}
	}
	
	private func fetchIssues(userName: String, repositoryName: String) {
        startNetworkActivityIndicator(activityIndicator: self.activityIndicator, userInteractionEnabled: false)
		GithubAPIManager.sharedInstance.fetchIssues(userName, repositoryName: repositoryName) { (result) in
            self.stoptNetworkActivityIndicator(activityIndicator: self.activityIndicator)
			switch result {
			case .Error(let msg, let code):
				switch code {
				case ErrorCase.InvalidToken.rawValue:
					// navigate back to root view controller for fetching a new token
					let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .Alert)
					let action = UIAlertAction(title: "OK", style: .Default, handler: { (action) in
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
				
			case .Success(let issueList):
				// save repository list and move to the next view
				self.issueList = issueList
				self.performSegueWithIdentifier(segueIdentifier, sender: nil)
			}
		}
	}
}

extension RepoListViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return repoList?.count ?? 0
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
		
		guard let unwarpedCell = cell else {
			// better to return empty cell than crash
			print("Error: UITableViewCell identifier mismatch.")
			let defaultCell = UITableViewCell()
			defaultCell.selectionStyle = .None
			return defaultCell
		}
		
		unwarpedCell.textLabel?.text = repoList?[indexPath.row].name
		return unwarpedCell
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		guard let repo = repoList?[indexPath.row], let repoName = repo.name, let userName = userName else {
			// something bad happened... assumed that username and repo name should be always available.
			let alert = UIAlertController(title: "Error", message: "Can't get issues for this repository.", preferredStyle: .Alert)
			let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
			alert.addAction(action)
			self.presentViewController(alert, animated: true, completion: nil)
			return
		}
		
		self.selectedRepo = repo
		fetchIssues(userName, repositoryName: repoName)
	}
}
