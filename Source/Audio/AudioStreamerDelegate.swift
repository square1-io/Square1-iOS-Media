//
//  AudioStreamerProtocol.swift
//  Square1Media
//
//  Created by Roberto Pastor Ortiz on 2/2/18.
//  Copyright © 2018 Square1. All rights reserved.
//

import Foundation

public protocol AudioStreamerDelegate: class {
  func playerRateChanged(isPlaying: Bool)
  func playerDidReachEnd()
  func playerDidFail(error: NSError?)
  func playerItemDidFail(error: NSError?)
  func playerReadyToPlay()
  func playerItemReadyToPlay()
  func playerItemBufferEmpty()
  func playerItemBufferReady()
  func playerItemFailedToPlayEndTime(error: NSError?)
  func playerItemPlaybackStalled()
}

public extension AudioStreamerDelegate {
  func playerRateChanged(isPlaying: Bool) {}
  func playerDidReachEnd() {}
  func playerDidFail(error: NSError?) {}
  func playerItemDidFail(error: NSError?) {}
  func playerReadyToPlay() {}
  func playerItemReadyToPlay() {}
  func playerItemBufferEmpty() {}
  func playerItemBufferReady() {}
  func playerItemFailedToPlayEndTime(error: NSError?) {}
  func playerItemPlaybackStalled() {}
}
