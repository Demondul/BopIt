//
//  ViewController.swift
//  CoreMotionDemo
//
//  Created by Eli Byers on 7/7/17.
//  Copyright © 2017 Eli Byers. All rights reserved.
//

import UIKit
import CoreMotion
import AVFoundation

class ViewController: UIViewController {
    
    var t1: Timer?=nil
    var t2: Timer?=nil
    var t3: Timer?=nil
    var t4: Timer?=nil
    var t5: Timer?=nil
    var passedMotion=true
    
    
    var motionManager = CMMotionManager()
    let opQueue = OperationQueue()
    
    var audioPlayer: AVAudioPlayer!
    var successNoise: AVAudioPlayer!
    var failNoise: AVAudioPlayer!
    var backgroundPlayer: AVAudioPlayer!
    
    var num = 6
    var image_count = 0
    
    var sounds = ["curl_it", "shake_it", "flip_it", "flick_it", "swipe_it", "tap_it"]
    
    var images = ["curl", "shake", "flip","flick", "swipe", "tap", "main"]

    var curl_activated = false
    var shake_activated = false
    var flip_activated = false
    var flick_activated = false
    var swipe_activated = false
    var tap_activated = false
    var test_passed = false
    var activation_counter = 4.0
    var buttonPushed=false
    var swiped=false
    
    @IBOutlet weak var image_outlet: UIImageView!
    @IBOutlet weak var move_label: UILabel!
    @IBOutlet weak var tap_button_label: UIButton!
    @IBOutlet weak var slider_label: UISlider!
    @IBOutlet weak var slider_swipe_label: UILabel!
    @IBAction func tap_button(_ sender: UIButton) {
//        print("button pressed")
        buttonPushed=true
        test_passed = true
        
//        print("**********",test_passed)
        tap_activated = false
    }
    @IBAction func slider(_ sender: UISlider) {
        if sender.value == 100 {
//            print("100 reached")
            swiped=true
            test_passed = true
//            print("**********",test_passed)
            swipe_activated = false
        }
    }
    
    func playSoundWith(fileName: String, fileExtension: String) -> Void {
        let audioSourceURL: URL!
        audioSourceURL = Bundle.main.url(forResource: fileName, withExtension: fileExtension)
        
        if audioSourceURL == nil {
//            print("Requested song not here")
        } else {
            do {
                audioPlayer = try AVAudioPlayer.init(contentsOf: audioSourceURL!)
                
                audioPlayer.prepareToPlay()
                audioPlayer.play()
            } catch {
                print(error)
            }
        }
    }
    func playSoundWithLoop(fileName: String, fileExtension: String) -> Void {
        let audioSourceURL: URL!
        audioSourceURL = Bundle.main.url(forResource: fileName, withExtension: fileExtension)
        
        if audioSourceURL == nil {
//            print("Requested song not here")
        } else {
            do {
                backgroundPlayer = try AVAudioPlayer.init(contentsOf: audioSourceURL!)
                
                backgroundPlayer.prepareToPlay()
                backgroundPlayer.play()
            } catch {
                print(error)
            }
        }
    }
        func showImage() -> Void {
            let img = images[num]
            if num < 4 || num == 6{
                image_outlet.isHidden = false
                if let filePath = Bundle.main.path(forResource: "\(img)\(image_count)", ofType: "jpg"), let image = UIImage(contentsOfFile: filePath) {
                    image_outlet.contentMode = .scaleAspectFit
                    image_outlet.image = image
                }
                tap_button_label.isHidden = true
                slider_label.isHidden = true
                slider_swipe_label.isHidden = true
                swipe_activated = false
                tap_activated = false
                
            } else {
                if num == 4{
                    slider_label.isHidden = false
                    slider_swipe_label.isHidden = false
                    image_outlet.isHidden = true
                    tap_button_label.isHidden = true
                    slider_label.value = 0
                    if test_passed == false{
                        swipe_activated = true
                    }
                    tap_activated = false
                }
                if num == 5{
                    tap_button_label.isHidden = false
                    image_outlet.isHidden = true
                    slider_label.isHidden = true
                    slider_swipe_label.isHidden = true
                    if test_passed == false{
                        tap_activated = true
                    }
                    swipe_activated = false

                }
                
            }
            image_count += 1
            if image_count >= 6{
                image_count = 0
            }

        }
    
    func checkMotion(){
        buttonPushed=false
        swiped=false
        print("Calling check motion")
        if self.passedMotion==false{
            self.playResponseNoise(fileName: "laugh", fileExtension: "wav")
            self.chooseFail()
        }
        self.passedMotion=false
        motionManager.deviceMotionUpdateInterval=0.3
        var noisePlayed=false
        
        if num==0{
            var readsCurl: [Double]=[0,0,0,0]
            motionManager.startDeviceMotionUpdates(to: opQueue){
                (data: CMDeviceMotion?, error:Error?) in
                if let mydata=data{
                    readsCurl.remove(at:0)
                    readsCurl.append(self.degrees(mydata.attitude.pitch))
                    for i in 0...3{
                        //Curl
                        if readsCurl[i] <= -50 && readsCurl[i] >= -90{
                            for j in i...3{
                                if readsCurl[j] >= 50 && readsCurl[j] <= 90{
                                    print("You are curling!")
                                    self.passedMotion=true
                                    if noisePlayed==false{
                                        self.playSuccess()
                                    }
                                    noisePlayed=true
//                                    self.restartTimers()
                                    break;
                                }
                            }
                        }
                    }
                }
            }
        }
        else if num==1{
            var readsShake: [Double]=[0,0,0,0]
            motionManager.startDeviceMotionUpdates(to: opQueue){
                (data: CMDeviceMotion?, error:Error?) in
                
                if let mydata=data{
                    readsShake.remove(at:0)
                    readsShake.append(mydata.userAcceleration.x)
                    var shaken=true
                    for i in 0...3{
                        if readsShake[i] <= 0.3 && readsShake[i] >= -0.3{
                            shaken=false
                            break
                        }
                    }
                    if shaken==true{
                        print("You are shaking")
//                        self.restartTimers()
                        self.passedMotion=true
                        if noisePlayed==false{
                            self.playSuccess()
                        }
                        noisePlayed=true
                    }
                }
            }
        }
        else if num==2{
            var readsFlip: [Double]=[0,0,0,0]
            motionManager.startDeviceMotionUpdates(to: opQueue){
                (data: CMDeviceMotion?, error:Error?) in
                
                if let mydata=data{
                    readsFlip.remove(at:0)
                    readsFlip.append(self.degrees(mydata.attitude.roll))
                     for i in 0...3{
                        if readsFlip[i] >= -15 && readsFlip[i] <= 15{
                            for j in i...3{
                                if ((readsFlip[j] <= -165 && readsFlip[j] >= -180) || (readsFlip[j] >= 165 && readsFlip[j] <= 180)){
                                    print("You are flipping")
                                    self.passedMotion=true
                                    if noisePlayed==false{
                                        self.playSuccess()
                                    }
                                    noisePlayed=true
//                                    self.restartTimers()
                                    break;
                                }
                            }
                        }
                    }
                }
            }
        }
        
        else if num==3{
            var readsFlick: [Double]=[0,0,0,0]
            motionManager.startDeviceMotionUpdates(to: opQueue){
                (data: CMDeviceMotion?, error:Error?) in
                if let mydata=data{
                    readsFlick.remove(at:0)
                    readsFlick.append(self.degrees(mydata.attitude.pitch))
                    for i in 0...2{
                        if readsFlick[i] >= -30  && readsFlick[i] < 20{
                            for j in i...2{
                                if readsFlick[j] >= 40  && readsFlick[j] <= 80 {
                                    print("You are Flicking!")
                                    self.passedMotion=true
                                    if noisePlayed==false{
                                        self.playSuccess()
                                    }
                                    noisePlayed=true
                                    
//                                    self.restartTimers()
                                    break
                                }
                            }
                        }
                    }
                }
            }
            
        }
        else if num==4{
            motionManager.startDeviceMotionUpdates(to: opQueue){
                (data: CMDeviceMotion?, error:Error?) in
                if self.swiped==true{
                    print("Swiped")
                    self.passedMotion=true
                    if noisePlayed==false{
                        self.playSuccess()
                    }
                    noisePlayed=true
//                    self.restartTimers()
                }
            }
        }
        else if num==5{
            motionManager.startDeviceMotionUpdates(to: opQueue){
                (data: CMDeviceMotion?, error:Error?) in
                if self.buttonPushed==true{
                    print("Button pushed")
                    self.passedMotion=true
                    if noisePlayed==false{
                        self.playSuccess()
                    }
                    noisePlayed=true
//                    self.restartTimers()
                }
            }
        }
    }
    
    func playFailNoise(fileName:String, fileExtension:String)->Void{
        let audioSourceURL: URL!
        audioSourceURL = Bundle.main.url(forResource: fileName, withExtension: fileExtension)
        
        if audioSourceURL == nil {
            //            print("Requested song not here")
        } else {
            do {
                failNoise = try AVAudioPlayer.init(contentsOf: audioSourceURL!)
                
                failNoise.prepareToPlay()
                failNoise.play()
            } catch {
                print(error)
            }
        }
    }
    
    func playResponseNoise(fileName: String, fileExtension: String) -> Void {
        let audioSourceURL: URL!
        audioSourceURL = Bundle.main.url(forResource: fileName, withExtension: fileExtension)
        
        if audioSourceURL == nil {
            //            print("Requested song not here")
        } else {
            do {
                successNoise = try AVAudioPlayer.init(contentsOf: audioSourceURL!)
                
                successNoise.prepareToPlay()
                successNoise.play()
            } catch {
                print(error)
            }
        }
    }
    
    func chooseFail(){
        let failNum=Int(arc4random_uniform(2))
        if failNum==0{
            self.playFailNoise(fileName: "suck", fileExtension: "m4a")
        }
        else{
            self.playFailNoise(fileName: "game", fileExtension: "m4a")
        }
    }
    
    func playSuccess(){
        let successNum=Int(arc4random_uniform(3))
        if successNum==0{
            self.playResponseNoise(fileName: "awesome_loud", fileExtension: "m4a")
        }
        else if successNum==1{
            self.playResponseNoise(fileName: "great_loud", fileExtension: "m4a")
        }
        else{
            self.playResponseNoise(fileName: "party_loud", fileExtension: "m4a")
        }
    }
    
    func restartTimers(){
        if passedMotion==false{
            return
        }
        passedMotion=false
        print("Restarting timers")
        t1!.invalidate()
        t2!.invalidate()
        t3!.invalidate()
        t4!.invalidate()
        t5!.invalidate()
        
        t1 = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
        t2 = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(play_sound), userInfo: nil, repeats: true)
        t3 = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(loop_sound), userInfo: nil, repeats: true)
        t4 = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(showImage), userInfo: nil, repeats: true)
        t5 = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(checkMotion), userInfo: nil, repeats: true)
    }
    
    @objc func play_sound(){
        num = Int(arc4random_uniform(6))
        print("Checking for \(images[num])")
        let sound_to_play = sounds[num]
        playSoundWith(fileName: sound_to_play, fileExtension: "m4a")
        move_label.text = "\(images[num]) it!"
        
    }
    
    @objc func loop_sound(){
        playSoundWithLoop(fileName: "loop", fileExtension: "wav")
    }
    
    @objc func  countDown(){
        if activation_counter == 0 && test_passed == false{
//            print("failed&&&&&&&&&")
            activation_counter = 4.0
            test_passed = false
        }
        else if activation_counter == 0 && test_passed == true{
//            print("*********passed")
            activation_counter = 4.0
            test_passed = false
        }
        activation_counter -= 0.25
//        print(activation_counter)
//        print(test_passed)
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        playSoundWith(fileName: "building", fileExtension: "wav")
        
        if motionManager.isDeviceMotionAvailable {
            print("We can detect device motion")
//            startReadingMotionData()
        }
        else {
            print("We cannot detect device motion")
            return
        }
        
        tap_button_label.isHidden = true
        slider_label.isHidden = true
        slider_swipe_label.isHidden = true
        
        t1 = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
        t2 = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(play_sound), userInfo: nil, repeats: true)
        t3 = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(loop_sound), userInfo: nil, repeats: true)
        t4 = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(showImage), userInfo: nil, repeats: true)
        t5 = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(checkMotion), userInfo: nil, repeats: true)

    }
    
    func startReadingMotionData() {
        // set read speed
        motionManager.deviceMotionUpdateInterval = 1
        // start reading
        motionManager.startDeviceMotionUpdates(to: opQueue) {
            (data: CMDeviceMotion?, error: Error?) in
            
//            if let mydata = data {
//                print("mydata", mydata.gravity)
//                print("pitch raw", mydata.attitude.pitch)
//                print("pitch", self.degrees(mydata.attitude.pitch))
//            }
        }
    }
    
    func degrees(_ radians: Double) -> Double {
        return 180/Double.pi * radians
    }

}

