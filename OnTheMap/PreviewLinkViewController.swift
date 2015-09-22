//
//  PreviewLinkViewController.swift
//  OnTheMap
//
//  Created by Marcel Oliveira Alves on 9/21/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//
//  This class is responsible for showing the website that the user wants to preview in the InformationPostViewController
//  It uses a UIWebView for this purpose and is dismissed with a navigation button called "Dismiss"

import UIKit

class PreviewLinkViewController: UIViewController {
	
	// MARK: - Outlets
	
	@IBOutlet weak var webView: UIWebView!
	
	// MARK: - Class variables
	
	var urlRequest: NSURLRequest!
	
	// MARK: - Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationItem.title = "Preview Link"
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Dismiss", style: .Plain, target: self, action: "dismissPreviewLinkView")
	}
	
	override func viewWillAppear(animated: Bool) {
		
		super.viewWillAppear(animated)
	
		if urlRequest != nil {
			self.webView.loadRequest(urlRequest!)
		}
	}
	
	// MARK: - Actions
	
	func dismissPreviewLinkView() {
		self.dismissViewControllerAnimated(true, completion: nil)
	}
}