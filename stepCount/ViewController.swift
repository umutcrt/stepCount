//
//  ViewController.swift
//  stepCount
//
//  Created by Umut Cörüt on 7.05.2022.
//

import UIKit
import CoreMotion


private let activityManager = CMMotionActivityManager()
private let pedometer = CMPedometer()

class ViewController: UIViewController {
    
    
    @IBOutlet weak var stepCountLabel: UILabel!
    @IBOutlet weak var activityStatus: UILabel!
    @IBOutlet weak var progressStep: UIView!
    @IBOutlet weak var progressStepCount: NSLayoutConstraint!
    
    
    var stepCounter = 0
    var totalStepCounter = 0
    var dataCount = 0
    let targetAmount = 10000
    
    func updateStepLevel(amount: Double) {
        let screenHeight = Double(view.frame.size.height) / 2
        let ratio = amount / Double(targetAmount)
        let calculatedHeight = screenHeight * ratio
        
        progressStepCount.constant = CGFloat(calculatedHeight)
        
        UIViewPropertyAnimator.init(duration: 0.5, dampingRatio: 0.75) {
            self.view.layoutIfNeeded()
        }.startAnimation()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataCount = UserDefaults.standard.value(forKey: "stepcount") as? Int ?? 0
        stepCountLabel.text = "\(dataCount)"
        updateStepLevel(amount: Double(dataCount))
        let width = view.frame.size.width
        let height = view.frame.size.height
        stepCountLabel.frame = CGRect(x: width * 0.20, y: height * 0.70, width: width * 0.60, height: height * 0.20)
        
        
        activityManager.startActivityUpdates(to: OperationQueue.main) { (activity: CMMotionActivity?) in
            guard let activity = activity else { return }
            DispatchQueue.main.async {
                if activity.stationary {
                    self.activityStatus.text = "Stationary"
                    print("Stationary")
                } else if activity.walking {
                    self.activityStatus.text = "Walking"
                    print("Walking")
                } else if activity.running {
                    self.activityStatus.text = "Running"
                    print("Running")
                } else if activity.automotive {
                    self.activityStatus.text = "Traveling by vehicle"
                    print("Traveling by vehicle")
                }
            }
        }
        if CMPedometer.isStepCountingAvailable() {
            pedometer.startUpdates(from: Date()) { pedometerData, error in
                guard let pedometerData = pedometerData, error == nil else { return }
                DispatchQueue.main.async {
                    self.stepCounter = pedometerData.numberOfSteps.intValue
                    self.totalStepCounter = self.dataCount + self.stepCounter
                    self.stepCountLabel.text = "\(self.totalStepCounter)"
                    self.updateStepLevel(amount: Double(self.totalStepCounter))
                    
                    UserDefaults.standard.setValue(self.totalStepCounter, forKey: "stepcount")
                }
            }
        }
    }
}


