//
//  ViewController.swift
//  testreconnection
//
//  Created by Roberto Perez Cubero on 04/04/16.
//  Copyright © 2016 tokbox. All rights reserved.
//

import UIKit
import OpenTok

class ViewController: UIViewController {
    let kApiKey = ""
    let kSessionId = ""
    let kToken = ""
    
    let reachability = Reachability(hostName: "www.tokbox.com")
    var session : OTSession?
    var publisher: OTPublisher?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.reachabilityChanged(_:)), name: kReachabilityChangedNotification, object: reachability)
        reachability.startNotifier()
    }
    
    func createSessionAndConnect() {
        session = OTSession(apiKey: kApiKey, sessionId: kSessionId, delegate: self)
        session!.connectWithToken(kToken, error: nil)
    }
    
    func reachabilityChanged(n: NSNotification) {
        print("Reachability Changed")
        
        print("Current status: \(reachability.currentReachabilityStatus())")
        switch reachability.currentReachabilityStatus() {
        case ReachableViaWiFi:
            fallthrough
        case ReachableViaWWAN:
            createSessionAndConnect()
        case NotReachable:
            session?.disconnect(nil)
        default:
            print("Unknown network status")
        }
    }
}

extension ViewController: OTSessionDelegate {
    func sessionDidConnect(session: OTSession!) {
        print("Session Connected")
        
        if publisher == nil {
            publisher = OTPublisher(delegate: self)
        }
        session.publish(publisher, error: nil)
    }
    
    func sessionDidDisconnect(session: OTSession!) {
        print("Session Disconnected")
        
        createSessionAndConnect()
    }
    
    func session(session: OTSession!, didFailWithError error: OTError!) {
        print("Session failed with error: \(error)")
    }
    
    func session(session: OTSession!, streamCreated stream: OTStream!) { }
    
    func session(session: OTSession!, streamDestroyed stream: OTStream!) { }
}

extension ViewController: OTPublisherDelegate {
    func publisher(publisher: OTPublisherKit!, streamCreated stream: OTStream!) {
        print("Stream created")
        
        self.publisher?.view.frame = CGRect(x: 0, y: 0, width: 320, height: 240)
        self.view.addSubview(self.publisher!.view)
    }
    
    func publisher(publisher: OTPublisherKit!, streamDestroyed stream: OTStream!) {
        print("Stream destroyed")
        
        session?.disconnect(nil)
    }
    
    func publisher(publisher: OTPublisherKit!, didFailWithError error: OTError!) { }
}

