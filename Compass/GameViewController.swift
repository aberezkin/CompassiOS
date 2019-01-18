//
//  GameViewController.swift
//  Compass
//
//  Created by Arkadii Berezkin on 15/01/2019.
//  Copyright © 2019 Arkadii Berezkin. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import GoogleMobileAds

class GameViewController: UIViewController {
    var gScene: GameScene?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                gScene = scene as? GameScene
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
            
            GADMobileAds.configure(withApplicationID: "ca-app-pub-7939230570061599~9431206077")
            let request = GADRequest()
            request.testDevices = [ "cc32503ab4a18683230abd1c582e0cac" ];
            GADRewardBasedVideoAd.sharedInstance().load(request, withAdUnitID: "ca-app-pub-3940256099942544/1712485313")

        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillLayoutSubviews() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.startViddeoAd), name: NSNotification.Name(rawValue: "showLevelAd"), object: nil)
    }
    
    @objc func startViddeoAd() {
        print(GADRewardBasedVideoAd.sharedInstance().isReady == true)

        if (GADRewardBasedVideoAd.sharedInstance().isReady == true) {
            GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: self)
            if (gScene != nil) {
                gScene?.playVideo()
                print("playing video")
            }
        }
        
    }
}
