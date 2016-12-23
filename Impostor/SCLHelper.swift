//
//  SCLHelper.swift
//  Impostor
//
//  Created by Full Decent on 10/17/16.
//  Copyright © 2016 William Entriken. All rights reserved.
//

import Foundation
import SCLAlertView

let impostorAppearance = SCLAlertView.SCLAppearance(
    kDefaultShadowOpacity: 0.25,
    kCircleTopPosition: 0.0,
    kCircleBackgroundTopPosition: 0.0,
    kCircleHeight: 20.0,
    kCircleIconHeight: 20.0,
    kTitleTop: 20.0,
    kTitleHeight: 20.0,
    kWindowWidth: 300,
    kWindowHeight: 500,
    kTextHeight: 20.0,
    kTextFieldHeight: 10.0,
    kTextViewdHeight: 10.0,
    kButtonHeight: 15.0,
    kTitleFont: UIFont(name: "Chalkboard SE", size: 20.0)!,
    kTextFont: UIFont(name: "Chalkboard SE", size: 16.0)!,
    kButtonFont: UIFont(name: "Chalkboard SE", size: 16.0)!,
    showCloseButton: false,
    showCircularIcon: true,
    shouldAutoDismiss: true,
    contentViewCornerRadius: 10.0,
    fieldCornerRadius: 8.0,
    buttonCornerRadius: 8.0,
    hideWhenBackgroundViewIsTapped: true,
    contentViewColor: UIColor.black,
    contentViewBorderColor: UIColor.black,
    titleColor: UIColor.white
)
