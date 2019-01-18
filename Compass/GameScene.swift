//
//  GameScene.swift
//  Compass
//
//  Created by Arkadii Berezkin on 15/01/2019.
//  Copyright © 2019 Arkadii Berezkin. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreLocation
import CoreMotion
import Firebase

extension CLLocationDirection {
    var toRadians: CGFloat { return CGFloat(self * .pi / 180) }
}

let sides = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]

func getSide(dir: CLLocationDirection) -> String {
    return sides[Int((dir + 22.5) / 45.0) & 7]
}
class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    var locationManager: CLLocationManager = {
        $0.requestWhenInUseAuthorization()
        $0.startUpdatingHeading()
        $0.startUpdatingLocation()
        return $0
    }(CLLocationManager())
    var motionManager = CMMotionManager()
    private var cmps: SKSpriteNode?
    private var crs_1: SKSpriteNode?
    private var crs_2: SKSpriteNode?
    private var isVideoPlayed: Bool = false
    private var gyroTimer : Timer? = nil
    private var analyticInterval: Timer? = nil
    
    override func didMove(to view: SKView) {
        cmps = childNode(withName: "cmps") as? SKSpriteNode
        crs_1 = childNode(withName: "crs_1") as? SKSpriteNode
        crs_2 = childNode(withName: "crs_2") as? SKSpriteNode
        motionManager.startAccelerometerUpdates()
        motionManager.startDeviceMotionUpdates()
        FirebaseApp.configure()
        
        analyticInterval = Timer(fire: Date(), interval: 1.0,
                                 repeats: true, block: { (timer) in
                                    if let headingData = self.locationManager.heading {
                                        let cpsDir = headingData.trueHeading
                                        Analytics.logEvent("log_dir", parameters: [
                                            "name": "cardinalHeading" as NSObject,
                                            "ull_text": getSide(dir: cpsDir) as NSObject
                                            
                                        ])
                                        print("log_dir_analytics")
                                    }
                                    
        })
        RunLoop.current.add(analyticInterval!, forMode: RunLoop.Mode.default)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            if (!isVideoPlayed && (crs_1?.contains(location))!) {
                print("Did touch")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showLevelAd"), object: nil)
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        #if targetEnvironment(simulator)
        
        #else
        if let heading = locationManager.heading {
            let radians = heading.trueHeading.toRadians
            cmps?.zRotation = radians
        }
        if (isVideoPlayed) {
            if let motionData = motionManager.deviceMotion {
                crs_2?.position.x = CGFloat(motionData.gravity.x * 300)
                crs_2?.position.y = CGFloat(motionData.gravity.y * 300)
            }
        }
        #endif
    }
    
    
    public func playVideo() {
        isVideoPlayed = true
        crs_1?.zPosition = 2
        crs_2?.zPosition = 2
    }
}
