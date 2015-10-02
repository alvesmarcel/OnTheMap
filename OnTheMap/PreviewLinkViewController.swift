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

class PreviewLinkViewController: UIViewController, UIWebViewDelegate {
	
	// MARK: - Outlets
	
	@IBOutlet weak var webView: UIWebView!
	
	// MARK: - Class variables
	
	var urlRequest: NSURLRequest!
	var loadingScreen: LoadingScreen!
	
	// MARK: - Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationItem.title = "Preview Link"
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Dismiss", style: .Plain, target: self, action: "dismissPreviewLinkView")
		
		/* Loading screen initialization */
		loadingScreen = LoadingScreen(view: self.view)
		
		webView.delegate = self
	}
	
	override func viewWillAppear(animated: Bool) {
		
		super.viewWillAppear(animated)
	
		/* Activates loading screen */
		loadingScreen.setActive(true)
		
		if urlRequest != nil {
			self.webView.loadRequest(urlRequest!)
		}
	}
	
	// MARK: - UIWebViewDelegate
	
	func webViewDidFinishLoad(webView: UIWebView) {
		
		/* Deactivates loading screen */
		loadingScreen.setActive(false)
	}
	
	// MARK: - Actions
	
	func dismissPreviewLinkView() {
		self.dismissViewControllerAnimated(true, completion: nil)
	}
}