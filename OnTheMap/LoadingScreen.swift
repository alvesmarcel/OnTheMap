//
//  LoadingScreen.swift
//  OnTheMap
//
//  Created by Marcel Oliveira Alves on 9/6/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//
//  This class represents a view that simulates a loading screen
//  It works mixing a black screen subview with alpha set in 0.5 and an activity indicator view
//  The subviews are added or removed in the function setActive()

import UIKit

class LoadingScreen {
	
	var superview: UIView!
	var activityIndicatorView: UIActivityIndicatorView!
	var blackScreenView: UIView!
	
	init(view: UIView) {
		
		/* Initialize the "superview" (it is a reference for the UIView passed) */
		superview = view
		
		/* Initialize black screen view */
		blackScreenView = UIView(frame: view.frame)
		blackScreenView.backgroundColor = UIColor.blackColor()
		blackScreenView.alpha = 0.5
		
		/* Initialize activity indicator view */
		activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
		activityIndicatorView.hidesWhenStopped = true
		
		/* Puts the activity indicator view in the center */
		let xOrigin = view.center.x - activityIndicatorView.frame.width / 2
		let yOrigin = view.center.y - activityIndicatorView.frame.height / 2
		let origin = CGPoint(x: xOrigin, y: yOrigin)
		activityIndicatorView.frame = CGRect(origin: origin, size: activityIndicatorView.frame.size)
		activityIndicatorView.startAnimating()
	}
	
	/* Sets the loading screen active or not */
	func setActive(active: Bool) {
		dispatch_async(dispatch_get_main_queue()) {
			if active {
				self.superview.addSubview(self.blackScreenView)
				self.superview.addSubview(self.activityIndicatorView)
			} else {
				self.activityIndicatorView.removeFromSuperview()
				self.blackScreenView.removeFromSuperview()
			}
		}
	}
}