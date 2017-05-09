//
//  ViewController.swift
//  synthGiro
//
//  Created by Noah Neumark on 4/27/17.
//  Copyright © 2017 Noah Neumark. All rights reserved.
//

import UIKit
import AudioKit
import CoreMotion

class ViewController: UIViewController, AKKeyboardDelegate, AKMIDIListener, settingsDelegate {
    
    var motionManager: CMMotionManager?
    
    var oscillator : AKMorphingOscillatorBank!
    
    var filter : AKMoogLadder!
    
    var delay : AKDelay!
    
    
    var midi = AKMIDI()
    
    func waveform(indexval: Double) {
        oscillator.index = indexval
    }
    
    func delaytime(timeval: Double) {
        delay.time = timeval
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! settingsViewController
        vc.delegate = self
        vc.sliderPosition = oscillator.index
        vc.dTimevalue = delay.time
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       oscillator = AKMorphingOscillatorBank(waveformArray: [AKTable(.sine), AKTable(.sawtooth), AKTable(.square), AKTable(.triangle)])
        
        filter = AKMoogLadder(oscillator)
        filter.cutoffFrequency = 300 // Hz
        filter.resonance = 0.6
        
        delay = AKDelay(filter)
        delay.dryWetMix = 0
        delay.time = 0.3
        
        AudioKit.output = delay
        AudioKit.start()
        Audiobus.start()
        
        setupUI()
        
        midi.openInput()
        midi.addListener(self)
        
        let keyboardView = AKKeyboardView()
        keyboardView.delegate = self
        
        //Mark - motion Manager :::::::::::::::::::::::::::::::::::
        
        motionManager = CMMotionManager()
        
        if let manager = motionManager {
            print("We have a motion manager")
            detectMotion(manager: manager)
        } else {
            print("No manager")
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupUI() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let adsrView = AKADSRView { att, dec, sus, rel in
            self.oscillator.attackDuration = att
            self.oscillator.decayDuration = dec
            self.oscillator.sustainLevel = sus
            self.oscillator.releaseDuration = rel
        }
        
        stackView.addArrangedSubview(adsrView)
        let keyboardView = AKKeyboardView()
        keyboardView.polyphonicMode = true
        keyboardView.delegate = self
        
        stackView.addArrangedSubview(keyboardView)
        
        view.addSubview(stackView)
        
        stackView.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: view.frame.height).isActive = true
        
        stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }

    
    func noteOn(note: MIDINoteNumber) {
        oscillator.play(noteNumber: note, velocity: 80)
        print("note received")
    }
    
    func noteOff(note: MIDINoteNumber) {
        oscillator.stop(noteNumber: note)
    }
    
    func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        oscillator.play(noteNumber: noteNumber, velocity: 80)
        print("note received")
    }
    
    func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        oscillator.stop(noteNumber: noteNumber)
    }
    
    
    // Helper Functions ::::::::::::::::::::::::::::::::::::::::::
    func detectMotion(manager: CMMotionManager) {
        
        if !manager.isDeviceMotionAvailable {
            // This will print if running on simulator
            print("We cannot detect device motion using the simulator")
        }
        else {
            // This will print if running on iPhone
            print("We can detect device motion")
            
            // Make a custom queue in order to stay off the main queue
            let myq = OperationQueue()
            
            // Customize the update interval (seconds)
            manager.deviceMotionUpdateInterval = 0.01
            
            
            // Now we can start our updates, send it to our custom queue, and define a completion handler
            manager.startDeviceMotionUpdates(to: myq, withHandler: { (motionData: CMDeviceMotion?, error: Error?) in
                
                if let data = motionData {
                    
                    // We access motion data via the "attitude" property
                    let attitude = data.attitude
                    print("pitch: \(attitude.pitch) ----- roll: \(attitude.roll) ----- yaw: \(attitude.yaw)")
                    self.filter.cutoffFrequency = (attitude.pitch * 4000) + 300
                    let drywetpos = abs(attitude.yaw)/3.4
                    if drywetpos > 0.1 {
                        self.delay.dryWetMix = drywetpos
                    } else {
                        self.delay.dryWetMix = 0
                    }
                }
                
            })
            
        }
    }

    

}

