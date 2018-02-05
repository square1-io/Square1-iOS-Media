//
//  AudioStreamer.swift
//  Square1Media
//
//  Created by Roberto Pastor Ortiz on 2/2/18.
//  Copyright © 2018 Square1. All rights reserved.
//

import Foundation
import AVFoundation
import Square1Tools

internal let AnotherPlayerDidStartPlaying = "AnotherPlayerDidStartPlaying"

class AudioStreamer: NSObject {
  
  // MARK: Properties
  private var player: AVPlayer
  private var reachability: Reachability = Reachability(url: "www.google.com")
  private(set) var audioUrl: URL
  public var isBufferEmpty: Bool = false
  public weak var delegate: AudioStreamerDelegate?
  
  public var isPlaying: Bool {
    return self.player.rate != 0
  }
  
  public var durationInSeconds: Float64 {
    guard let item = player.currentItem else { return 0 }
    return CMTimeGetSeconds(item.asset.duration)
  }
  
  public var currentTimeInSeconds: Float64 {
    guard let item = player.currentItem else { return 0 }
    return CMTimeGetSeconds(item.currentTime())
  }
  
  public var status: AVPlayerStatus {
    return player.status
  }
  
  public var itemStatus: AVPlayerItemStatus? {
    return player.currentItem?.status
  }
  
  // MARK: Lifecycle & Setup
  init(url: URL) {
    audioUrl = url
    player = AVPlayer(url: audioUrl)
    
    super.init()
    setupPlayer()
    setupNotifications()
    setupKVO()
    setupReachability()
  }
  
  private func setupPlayer() {
    player.actionAtItemEnd = .pause
    if #available(iOS 10.0, *) {
      player.automaticallyWaitsToMinimizeStalling = false
    }
    player.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 1), queue: DispatchQueue.main) { [weak self] _ in
      self!.updateBufferState()
    }
  }
  
  private func setupKVO() {
    player.addObserver(self, forKeyPath: "status", options: .new, context: nil)
    player.addObserver(self, forKeyPath: "rate", options: .new, context: nil)
    player.currentItem?.addObserver(self, forKeyPath: "rate", options: .new, context: nil)
  }
  
  private func setupNotifications() {
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(itemDidFinishPlaying(notification:)),
                                           name: .AVPlayerItemDidPlayToEndTime,
                                           object: player.currentItem)
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(itemDidFailToPlayToEndTime(notification:)),
                                           name: .AVPlayerItemFailedToPlayToEndTime,
                                           object: player.currentItem)
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(itemDidFinishPlaying(notification:)),
                                           name: .AVPlayerItemPlaybackStalled,
                                           object: player.currentItem)
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(itemDidFinishPlaying(notification:)),
                                           name: NSNotification.Name(rawValue: AnotherPlayerDidStartPlaying),
                                           object: player.currentItem)
  }
  
  private func setupReachability() {
    reachability.networkReachabilityChangedBlock = { [weak self] networkStatus in

      if networkStatus == .notReachable &&
         self!.player.status == .readyToPlay &&
         self!.player.currentItem?.isPlaybackBufferEmpty == true {
        self!.player.pause()
      } else if self?.isPlaying == true {
        self!.player.pause()
      }
    }
    
    reachability.start()
  }
  
  deinit {
    player.removeObserver(self, forKeyPath: "status")
    player.removeObserver(self, forKeyPath: "rate")
    player.currentItem?.removeObserver(self, forKeyPath: "status")
    
    NotificationCenter.default.removeObserver(self)
    player.pause()
  }
  
  // MARK: Public
  public func play() {
    player.play()
  }
  
  public func pause() {
    player.pause()
  }
  
  public func seek(to seconds:Float64, completion: ((Bool) -> ())? = nil) {
    player.seek(to: CMTimeMakeWithSeconds(seconds, Int32(NSEC_PER_SEC))) { (finished) in
      completion?(finished)
    }
  }
  
  // MARK: Private
  private func updateBufferState() {
    if self.player.currentItem?.isPlaybackBufferEmpty == true && !isBufferEmpty {
      isBufferEmpty = true
      delegate?.playerItemBufferEmpty()
    } else if isBufferEmpty {
      isBufferEmpty = false
      delegate?.playerItemBufferReady()
    }
  }
  
  // MARK: Handle Notifications
  @objc private func itemDidFinishPlaying(notification: Notification) {
    player.pause()
    let origin = CMTimeMakeWithSeconds(0, 1)
    player.seek(to: origin)
    delegate?.playerDidReachEnd()
  }
  
  @objc private func itemDidFailToPlayToEndTime(notification: Notification) {
    player.pause()
    let error = self.player.currentItem?.error as NSError?
    delegate?.playerItemFailedToPlayEndTime(withError: error)
  }
  
  @objc private func itemDidStall(notification: Notification) {
    player.pause()
    delegate?.playerItemPlaybackStalled()
  }
  
  @objc private func anotherPlayerDidStartPlaying(notification: Notification) {
    guard let streamer = notification.object as? AudioStreamer else { return }
    if streamer == self {
      player.pause()
    }
  }
  
  // MARK: KVO
  override func observeValue(forKeyPath keyPath: String?,
                             of object: Any?,
                             change: [NSKeyValueChangeKey : Any]?,
                             context: UnsafeMutableRawPointer?) {
    if let streamer = object as? AudioStreamer,
       streamer == self,
       let keyPath = keyPath,
       keyPath == "status" {
      
      if player.status == .failed {
        player.pause()
        let error = self.player.error as NSError?
        delegate?.playerDidFail(withError: error)
      } else if player.status == .readyToPlay {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: AnotherPlayerDidStartPlaying), object: self)
        delegate?.playerReadyToPlay()
        if !self.isPlaying {
          player.play()
        }
      }
    }
    
    if let item = object as? AVPlayerItem,
      item == player.currentItem,
      let keyPath = keyPath,
      keyPath == "status" {
      
      if item.status == .readyToPlay {
        delegate?.playerItemReadyToPlay()
      } else if item.status == .failed {
        let error = self.player.currentItem?.error as NSError?
        delegate?.playerDidFail(withError: error)
      }
    }
    
    if let streamer = object as? AudioStreamer,
      streamer == self,
      let keyPath = keyPath,
      keyPath == "rate" {
      delegate?.playerRateChanged(isPlaying: isPlaying)
    }
  }
}
