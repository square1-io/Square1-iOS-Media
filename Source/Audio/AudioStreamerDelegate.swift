//
//  AudioStreamerProtocol.swift
//  Square1Media
//
//  Created by Roberto Pastor Ortiz on 2/2/18.
//  Copyright © 2018 Square1. All rights reserved.
//

import Foundation

protocol AudioStreamerDelegate: class {
  func playerRateChanged(isPlaying: Bool)
  func playerDidReachEnd()
  func playerDidFail(withError error: NSError?)
  func playerItemDidFail(withError error: NSError?)
  func playerReadyToPlay()
  func playerItemReadyToPlay()
  func playerItemBufferEmpty()
  func playerItemBufferReady()
  func playerItemFailedToPlayEndTime(withError error: NSError?)
  func playerItemPlaybackStalled()
}

extension AudioStreamerDelegate {
  func playerRateChanged(isPlaying: Bool) {}
  func playerDidReachEnd() {}
  func playerDidFail(withError error: NSError?) {}
  func playerItemDidFail(withError error: NSError?) {}
  func playerReadyToPlay() {}
  func playerItemReadyToPlay() {}
  func playerItemBufferEmpty() {}
  func playerItemBufferReady() {}
  func playerItemFailedToPlayEndTime(withError error: NSError?) {}
  func playerItemPlaybackStalled() {}
}
