//
//  ViewController.swift
//  RFP
//
//  Created by Mark Aron Szulyovszky on 11/01/2016.
//  Copyright © 2016 Mark Aron Szulyovszky. All rights reserved.
//

import UIKit

class ImperativeViewController: UIViewController, UIGestureRecognizerDelegate {

  var panPresent = false
  var pinchPresent = false
  var gestureTimer: NSTimer?
  var secondsLeft = 3
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let pan = UIPanGestureRecognizer(target: self, action: "handlePan:")
    pan.delegate = self
    view.addGestureRecognizer(pan)
    let pinch = UIPinchGestureRecognizer(target: self, action: "handlePinch:")
    pinch.delegate = self
    view.addGestureRecognizer(pinch)
  }
  

  func handlePan(panGesture: UIPanGestureRecognizer) {
    if panGesture.state == .Began && self.panPresent == false {
      self.panPresent = true
      self.checkIfBothGesturesPresent()
    } else if panGesture.state == .Ended {
      self.panPresent = false
      self.stopTimerIfNeeded()
    }
  }
  
  func handlePinch(pinchGesture: UIPinchGestureRecognizer) {
    if pinchGesture.state == .Began && self.pinchPresent == false {
      self.pinchPresent = true
      self.checkIfBothGesturesPresent()
    } else if pinchGesture.state == .Ended {
      self.pinchPresent = false
      self.stopTimerIfNeeded()
    }
  }
  
  func checkIfBothGesturesPresent() {
    if self.pinchPresent == true && self.panPresent == true && self.gestureTimer == nil {
      self.secondsLeft = 3
      self.gestureTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "tick:", userInfo: nil, repeats: true)
      print("started")
    }
  }
  
  func stopTimerIfNeeded() {
    if let gestureTimer = gestureTimer {
      gestureTimer.invalidate()
      self.gestureTimer = nil
      print("completed")
    }
  }
  
  func tick(timer: NSTimer) {
    if self.secondsLeft <= 0 {
      self.stopTimerIfNeeded()
      return
    }
    self.secondsLeft--
    print("tick")
  }
  
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
    
}