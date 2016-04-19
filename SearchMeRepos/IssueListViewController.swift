//
//  IssueListViewController.swift
//  SearchMeRepos
//
//  Created by Ian on 4/19/16.
//  Copyright © 2016 Yongjun Yoo. All rights reserved.
//

import UIKit

private let cellIdentifier = "issueCell"

class IssueListViewController: UIViewController {

	var repo: GithubRepo?
	var issueList: [GithubIssue]?
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.navigationBar.hidden = false
		title = repo?.name
	}
}

extension IssueListViewController: UITableViewDataSource {
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return issueList?.count ?? 0
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
		
		guard let unwarpedCell = cell else {
			// better to return empty cell than crash
			print("Error: UITableViewCell identifier mismatch.")
			return UITableViewCell()
		}
		
		unwarpedCell.textLabel?.text = issueList?[indexPath.row].title
		return unwarpedCell
	}
}
