//
//  extensions.swift
//  SearchMeRepos
//
//  Created by Yongjun Yoo on 4/19/16.
//  Copyright © 2016 Yongjun Yoo. All rights reserved.
//

import Foundation
import UIKit

protocol Identifiable {
    static var identifier: String { get }
}

extension Identifiable where Self: UIViewController {
    static var identifier: String {
        return String(self)
    }
}

extension UIViewController: Identifiable {}
