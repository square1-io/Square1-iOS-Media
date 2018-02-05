//
//  Reachability.swift
//  Square1Tools
//
//  Created by Roberto Pastor Ortiz on 2/2/18.
//  Copyright © 2018 Square1. All rights reserved.
//

import Foundation
import SystemConfiguration

public enum NetworkStatus {
  case notReachable
  case reachableWiFi
  case reachableWWAN
}

func callback(target: SCNetworkReachability, flags: SCNetworkReachabilityFlags, info: UnsafeMutableRawPointer?) {
  guard let info = info else { return }
  let reachibility = Unmanaged<Reachability>.fromOpaque(info).takeUnretainedValue()
  reachibility.reachabilityChanged(flags: flags)
}


/// An implementation of the Apple Reachability to track the network connectivity
public class Reachability {
  
  // MARK: Properties
  private let networkReachability: SCNetworkReachability
  private let reachabilitySerialQueue = DispatchQueue(label: "io.square1.ios.tools.reachability")
  private var networkStatus: NetworkStatus = .notReachable
  
  public var networkReachabilityChangedBlock: ((NetworkStatus) -> ())? = nil
  
  public var reachabilityStatus: NetworkStatus {
    var flags = SCNetworkReachabilityFlags()
    if SCNetworkReachabilityGetFlags(networkReachability, &flags) {
      return networkStatus(forFlags: flags.rawValue)
    }
    return .notReachable
  }
  
  // MARK: Setup
  public static func reachability(withUrl url: String) -> Reachability {
    return Reachability(url: url)
  }
  
  public convenience init(url: String) {
    guard let networkReachability = SCNetworkReachabilityCreateWithName(nil, url) else {
      fatalError("You must specify a host name")
    }
    self.init(networkReachability: networkReachability)
  }
  
  required public init(networkReachability: SCNetworkReachability) {
    self.networkReachability = networkReachability
  }

  
  // MARK: Public
  @discardableResult
  public func start() -> Bool{
    var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
    context.info = UnsafeMutableRawPointer(Unmanaged<Reachability>.passUnretained(self).toOpaque())
    
    if SCNetworkReachabilitySetCallback(networkReachability, callback, &context) {
      if SCNetworkReachabilitySetDispatchQueue(networkReachability, reachabilitySerialQueue) {
        return true
      } else {
        SCNetworkReachabilitySetCallback(networkReachability, nil, nil)
      }
    }

    return false
  }
  
  public func stop() {
    SCNetworkReachabilitySetCallback(networkReachability, nil, nil)
    SCNetworkReachabilitySetDispatchQueue(networkReachability, nil)
  }
  

  // MARK: Private
  fileprivate func reachabilityChanged(flags: SCNetworkReachabilityFlags) {
    let reachabilityStatus = self.reachabilityStatus
    
    if networkStatus != reachabilityStatus {
      networkStatus = reachabilityStatus
      networkReachabilityChangedBlock?(reachabilityStatus)
    }
  }
  
  fileprivate func networkStatus(forFlags flags: SCNetworkConnectionFlags) -> NetworkStatus {
    if (flags & UInt32(kSCNetworkFlagsReachable)) == 0 {
      return .notReachable
    }
    
    var result: NetworkStatus = .notReachable
    
    if (flags & UInt32(kSCNetworkFlagsConnectionRequired)) == 0 {
      result  = .reachableWiFi
    }
    
    if (flags & SCNetworkReachabilityFlags.connectionOnDemand.rawValue) != 0 ||
       (flags & SCNetworkReachabilityFlags.connectionOnTraffic.rawValue) != 0 {
      
      if flags & UInt32(kSCNetworkFlagsInterventionRequired) == 0 {
        result = .reachableWiFi
      }
    }
    
    if (flags & SCNetworkReachabilityFlags.isWWAN.rawValue) == SCNetworkReachabilityFlags.isWWAN.rawValue {
      result = .reachableWWAN
    }
    
    return result
  }
}
