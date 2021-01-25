//
//  Haptics.swift
//  Arithma
//
//  Created by Chen Zerui on 22/6/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import UIKit

func selectionFeedback() {
    UISelectionFeedbackGenerator().selectionChanged()
}

func warningFeedback() {
    UINotificationFeedbackGenerator().notificationOccurred(.warning)
}
