//
//  GroupsAndTeacherStorage.swift
//  PolyNavi
//
//  Created by Никита Фролов  on 17.10.2021.
//

import Foundation

enum TimetableFillter {
    case groups
    case teachers
}

class GroupsAndTeacherStorage {
    
    static let shared = GroupsAndTeacherStorage()
    
    public var institute: SettingsModel? {
        didSet {
            self.groupNumber = nil
        }
    }
    
    public var groupNumber: SettingsModel? = nil
    public var teachersName: SettingsModel? = nil
    public var fillter: TimetableFillter = .groups
    
    public func getInstituteStringWithStatus() -> String {
        return institute?.title ?? L10n.Settings.statusOfInstitute
    }
    
    public func getGroupStringWithStatus() -> String {
        return groupNumber?.title ?? L10n.Settings.statusOfGroup
    }
    
    public func getTeacherStringWithStatus() -> String {
        return teachersName?.title ?? L10n.Settings.statusOfInstitute
    }
}
