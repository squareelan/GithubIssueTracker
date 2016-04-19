//
//  ViewController.swift
//  SearchMeRepos
//
//  Created by Ian on 4/18/16.
//  Copyright © 2016 Yongjun Yoo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
	}
	
	override func viewWillAppear(animated: Bool) {
		self.navigationController?.navigationBar.hidden = true
	}
}

