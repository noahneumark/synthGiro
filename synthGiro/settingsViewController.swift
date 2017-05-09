//
//  settingsViewController.swift
//  synthGiro
//
//  Created by Noah Neumark on 4/27/17.
//  Copyright © 2017 Noah Neumark. All rights reserved.
//

import UIKit

class settingsViewController: UIViewController {
    
    var delegate : settingsDelegate?
    var sliderPosition : Double?
    var dTimevalue : Double?

    @IBOutlet weak var delayTimeOutlet: UISlider!
    @IBOutlet weak var waveformOutlet: UISlider!

    @IBAction func waveformSlider(_ sender: UISlider) {
        delegate?.waveform(indexval: Double(sender.value))
    }
    @IBAction func delayTimeSlider(_ sender: UISlider) {
        delegate?.delaytime(timeval: Double(sender.value))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        waveformOutlet.value = Float(sliderPosition!)
        delayTimeOutlet.value = Float(dTimevalue!)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
