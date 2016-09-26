//
//  ViewController.swift
//  Arduino_Servo
//
//  Created by Owen L Brown on 9/24/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  @IBOutlet weak var imgBluetoothStatus: UIImageView!
  @IBOutlet weak var positionSlider: UISlider!
  @IBOutlet weak var StatusRespond: UILabel!
    
    
  var timerTXDelay: Timer?
 
  var allowTX = true
  var lastPosition: UInt8 = 255
  var ksts = 0
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
    
    // Rotate slider to vertical position
    let superView = self.positionSlider.superview
    positionSlider.removeFromSuperview()
    positionSlider.removeConstraints(self.view.constraints)
    positionSlider.translatesAutoresizingMaskIntoConstraints = true
    positionSlider.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2))
    positionSlider.frame = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 150.0)
    superView?.addSubview(self.positionSlider)
    positionSlider.autoresizingMask = [UIViewAutoresizing.flexibleLeftMargin, UIViewAutoresizing.flexibleRightMargin]
    positionSlider.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
    
    // Set thumb image on slider
    positionSlider.setThumbImage(UIImage(named: "Oval"), for: UIControlState())
    
    // Watch Bluetooth connection
    NotificationCenter.default.addObserver(self, selector: #selector(ViewController.connectionChanged(_:)), name: NSNotification.Name(rawValue: BLEServiceChangedStatusNotification), object: nil)
    
    // Start the Bluetooth discovery process
    btDiscoverySharedInstance
	
    }
  
  deinit {
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: BLEServiceChangedStatusNotification), object: nil)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    self.stopTimerTXDelay()
  }
  
  @IBAction func positionSliderChanged(_ sender: UISlider) {
    if sender.value >= 75 {
        sender.setValue(180, animated: true)
        self.sendPosition(UInt8(sender.value))
        if let bleService = btDiscoverySharedInstance.bleService {
            StatusRespond.text = bleService.writePosition2(">KTEgg1#")
            ksts = 1
        }
    
    
    }else if ksts == 1{
     sender.setValue(0, animated: true)
     if let bleService = btDiscoverySharedInstance.bleService {
        StatusRespond.text = bleService.writePosition2(">KTEgg0#")
        ksts = 0
            }
        }
    }

  func connectionChanged(_ notification: Notification) {
    // Connection status changed. Indicate on GUI.
    let userInfo = (notification as NSNotification).userInfo as! [String: Bool]
//    print("user info: \(userInfo)")
    DispatchQueue.main.async(execute: {
      // Set image based on connection status
      if let isConnected: Bool = userInfo["isConnected"] {
        if isConnected {
          self.imgBluetoothStatus.image = UIImage(named: "Bluetooth_Connected")
            // Send current slider position
        self.sendPosition(UInt8(self.positionSlider.value))
        } else {
          self.imgBluetoothStatus.image = UIImage(named: "Bluetooth_Disconnected")
        }
      }
    });
  }
  
  func sendPosition(_ position: UInt8) {
    // Valid position range: 0 to 180
    
    if !self.allowTX {
      return
    }
    
    // Validate value
    if position == lastPosition {
      return
    }
    else if ((position < 0) || (position > 180)) {
      return
    }
    
    // Send position to BLE Shield (if service exists and is connected)
    if let bleService = btDiscoverySharedInstance.bleService {
      bleService.writePosition(position)
      lastPosition = position;
      
      // Start delay timer
      self.allowTX = false
      if timerTXDelay == nil {
        timerTXDelay = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(ViewController.timerTXDelayElapsed), userInfo: nil, repeats: false)
      }
    }
  }
  
    @IBOutlet weak var comandEx: UITextField!
  
    @IBAction func NWSwitch(_ sender: UISwitch) {
        
        if sender.isOn {
//            sender.setValue(180, animated: true)
//            self.sendPosition(UInt8(sender.value))
            if let bleService = btDiscoverySharedInstance.bleService {
                StatusRespond.text = bleService.writePosition2(">KTEgg1#")
                ksts = 1
            }
            
            
        }else if ksts == 1{
//            func sender.setOff(0, animated: true)
            if let bleService = btDiscoverySharedInstance.bleService {
                StatusRespond.text = bleService.writePosition2(">KTEgg0#")
                ksts = 0
            }
        }

        
    }

    
    @IBAction func sendCMD(_ sender: AnyObject) {
        
        let dtt: String = String(comandEx.text!)
        if let bleService = btDiscoverySharedInstance.bleService {
            StatusRespond.text = bleService.writePosition2(dtt)
            print("input:\(dtt)")
        }
    }
    
  func timerTXDelayElapsed() {
    self.allowTX = true
    self.stopTimerTXDelay()
    
    // Send current slider position
    self.sendPosition(UInt8(self.positionSlider.value))
  }
  
  func stopTimerTXDelay() {
    if self.timerTXDelay == nil {
      return
    }
    
    timerTXDelay?.invalidate()
    self.timerTXDelay = nil
  }
  
}

