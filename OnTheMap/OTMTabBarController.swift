//
//  CustomTabBarController.swift
//  OnTheMap
//
//  Created by Marcel Oliveira Alves on 8/26/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//

import UIKit

class OTMTabBarController: UITabBarController {
	
	override func viewDidLoad() {
		
		/* Adding the right bar buttons to the navigation bar */
		let refreshBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: nil)
		let pinBarButtonItem = UIBarButtonItem(image: UIImage(named: "pin"), style: .Plain, target: self, action: nil)
		self.navigationItem.setRightBarButtonItems([refreshBarButtonItem, pinBarButtonItem], animated: true)
	}
}