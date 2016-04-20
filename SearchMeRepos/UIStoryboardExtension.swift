//
//  File.swift
//  SearchMeRepos
//
//  Created by Yongjun Yoo on 4/19/16.
//  Copyright © 2016 Yongjun Yoo. All rights reserved.
//

import Foundation
import UIKit

extension UIStoryboard {
    convenience init(storyboardName: String, bundle: NSBundle? = nil) {
        self.init(name: storyboardName, bundle: bundle)
    }

    class func storyboard(name: String, bundle: NSBundle? = nil) -> UIStoryboard {
        return UIStoryboard(name: name, bundle: bundle)
    }
}
