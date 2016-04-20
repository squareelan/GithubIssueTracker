//
//  UIViewControllerExtension.swift
//  SearchMeRepos
//
//  Created by Yongjun Yoo on 4/19/16.
//  Copyright © 2016 Yongjun Yoo. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func startNetworkActivityIndicator(activityIndicator activityIndicator: UIActivityIndicatorView, userInteractionEnabled: Bool) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        activityIndicator.startAnimating()
        self.view.userInteractionEnabled = userInteractionEnabled
    }

    func stoptNetworkActivityIndicator(activityIndicator activityIndicator: UIActivityIndicatorView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        activityIndicator.stopAnimating()

        if !self.view.userInteractionEnabled {
            self.view.userInteractionEnabled = true // always enable UserInteraction
        }
    }
}
