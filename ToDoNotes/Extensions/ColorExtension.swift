//
//  ColorExtension.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/1/25.
//

import SwiftUI

extension Color {
    enum BackColors {
        static let backElevated = Color("BackElevated")
        static let backiOSPrimary = Color("BackiOSPrimary")
        static let backPrimary = Color("BackPrimary")
        static let backSecondary = Color("BackSecondary")
        static let backDefault = Color("BackDefault")
        static let backSheet = Color("BackSheet")
        static let backFormCell = Color("BackFormCell")
    }
    
    enum ButtonColors {
        static let onboarding = Color("OnboardingButton")
        static let appleLogin = Color("AppleLoginButton")
        static let remove = Color ("RemoveButton")
    }
    
    enum LabelColors {
        static let labelDisable = Color("LabelDisable")
        static let labelDetails = Color("LabelDetails")
        static let labelPrimary = Color("LabelPrimary")
        static let labelSecondary = Color("LabelSecondary")
        static let labelTertiary = Color("LabelTertiary")
        static let labelReversed = Color("LabelReversed")
        static let labelBlack = Color("LabelBlack")
        static let labelGreyLight = Color("LabelGreyLight")
        static let labelGreyDark = Color("LabelGreyDark")
        
        enum Special {
            static let labelFilterUnselected = Color("LabelFilterUnselected")
            static let labelSearchBarCancel = Color("LabelSearchBarCancel")
        }
    }
    
    enum SupportColors {
        static let supportNavBar = Color("SupportNavBar")
        static let supportOverlay = Color("SupportOverlay")
        static let supportSegmented = Color("SupportSegmented")
        static let supportTextField = Color("SupportTextField")
        static let backListRow = Color("SupportListRow")
        static let supportButton = Color("SupportButton")
        static let supportToggle = Color("SupportToggle")
        static let supportPopup = Color("SupportPopup")
        static let supportParamRow = Color("SupportParamRow")
    }
    
    enum FolderColors {
        static let all = Color("FolderAll")
        static let reminders = Color("FolderReminders")
        static let tasks = Color("FolderTasks")
        static let lists = Color("FolderLists")
        static let noDate = Color("FolderNoDate")
    }
    
    enum ShadowColors {
        static let navBar = Color("ShadowNavBarColor")
        static let popup = Color("ShadowPopupColor")
        static let taskSection = Color("ShadowTaskSectionColor")
    }
    
    enum SwipeColors {
        static let important = Color("SwipeActionImportant")
        static let pin = Color("SwipeActionPin")
        static let remove = Color("SwipeActionDelete")
        static let restore = Color("SwipeActionRestore")
    }
}


extension UIColor {
    enum ShadowColors {
        static let navBar = UIColor(named: "ShadowNavBarColor")
    }
    
    enum TabBar {
        static let background = UIColor(named: "SupportNavBar")
    }
}
