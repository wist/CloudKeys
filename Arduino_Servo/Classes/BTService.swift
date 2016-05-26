//
//  BTService.swift
//  Arduino_Servo
//
//  Created by Owen L Brown on 10/11/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

import Foundation
import CoreBluetooth

/* Services & Characteristics UUIDs */
//let BLEServiceUUID = CBUUID(string: "1252CDB3-F1E0-4BCC-9734-7B0291D20540")
//let PositionCharUUID = CBUUID(string: "F38A2C23-BC54-40FC-BED0-60EDDA139F47")

let BLEServiceUUID = CBUUID(string: "00035B03-58E6-07DD-021A-08123A000300")
let PositionCharUUID = CBUUID(string: "00035B03-58E6-07DD-021A-08123A000301")

let BLEServiceChangedStatusNotification = "kBLEServiceChangedStatusNotification"

class BTService: NSObject, CBPeripheralDelegate {
  var peripheral: CBPeripheral?
  var positionCharacteristic: CBCharacteristic?
  
  init(initWithPeripheral peripheral: CBPeripheral) {
    super.init()
    
    self.peripheral = peripheral
    self.peripheral?.delegate = self
  }
  
  deinit {
    self.reset()
  }
  
  func startDiscoveringServices() {
    self.peripheral?.discoverServices([BLEServiceUUID])
  }
  
  func reset() {
    if peripheral != nil {
      peripheral = nil
    }
    
    // Deallocating therefore send notification
    self.sendBTServiceNotificationWithIsBluetoothConnected(false)
  }
  
  // Mark: - CBPeripheralDelegate
  
  func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
    let uuidsForBTService: [CBUUID] = [PositionCharUUID]
  //  print("1wrong Periferal ID:\(self.peripheral)")
  //  print("1Periferal\(peripheral)")
    
    if (peripheral != self.peripheral) {
      // Wrong Peripheral
      return
    }
    
    if (error != nil) {
      return
    }
    
    if ((peripheral.services == nil) || (peripheral.services!.count == 0)) {
      // No Services
      return
    }
    
    for service in peripheral.services! {
        print("BLEServ:\(service.UUID)")
      if service.UUID == BLEServiceUUID {
        peripheral.discoverCharacteristics(uuidsForBTService, forService: service)
        }
    }
  }
  
  func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
    print("2wrong Periferal ID:\(self.peripheral)")
    print("2Periferal\(peripheral)")
    if (peripheral != self.peripheral) {
      // Wrong Peripheral
        return
    }
    
    if (error != nil) {
      return
    }
    
    if let characteristics = service.characteristics {
      for characteristic in characteristics {
        print("char:\(characteristic)")
//        print("RSSI:\(peripheral.RSSI)")
        if characteristic.UUID == PositionCharUUID {
          self.positionCharacteristic = (characteristic)
          peripheral.setNotifyValue(true, forCharacteristic: characteristic)
          
          // Send notification that Bluetooth is connected and all required characteristics are discovered
          self.sendBTServiceNotificationWithIsBluetoothConnected(true)
        }
      }
    }
  }
  
  // Mark: - Private

    func writePosition(position: UInt8) {
    print(position)
        // See if characteristic has been discovered before writing to it
//    if let positionCharacteristic = self.positionCharacteristic {
    // Need a mutable var to pass to writeValue function
//    var positionValue = position
//    let data = NSData(bytes: &positionValue, length: sizeof(UInt8))
//    self.peripheral?.writeValue(data, forCharacteristic: positionCharacteristic, type: CBCharacteristicWriteType.WithResponse)
//    }
    }

    func writePosition2(cmd: String!) ->String{
//    let positionValue = ">ZR35+0rE#"
//    let data = NSData(bytes: positionValue, length: 10)
    let data = NSData(bytes: cmd, length: cmd.characters.count)
    self.peripheral?.writeValue(data, forCharacteristic: positionCharacteristic!, type: CBCharacteristicWriteType.WithResponse)
        print("data: \(data)")
        print("value: \(self.positionCharacteristic!.value!)")
        let inputText = self.positionCharacteristic!.value!
        let convertedString = NSString(data: inputText, encoding:NSUTF8StringEncoding)
        print("value2: \(convertedString!)")
        return convertedString! as String
//    return self.positionCharacteristic!.value!
    }
  
  func sendBTServiceNotificationWithIsBluetoothConnected(isBluetoothConnected: Bool) {
    let connectionDetails = ["isConnected": isBluetoothConnected]
    NSNotificationCenter.defaultCenter().postNotificationName(BLEServiceChangedStatusNotification, object: self, userInfo: connectionDetails)
  }
  
}