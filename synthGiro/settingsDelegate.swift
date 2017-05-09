//
//  settingsDelegate.swift
//  synthGiro
//
//  Created by Noah Neumark on 4/27/17.
//  Copyright © 2017 Noah Neumark. All rights reserved.
//

import Foundation

protocol settingsDelegate : class {
    func waveform(indexval: Double)
    func delaytime(timeval: Double)
}
