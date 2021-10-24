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
    
    enum SettingsStorageKeyName {
        static let filterVal = "filterVal"
        static let instituteID = "instituteID"
        static let instituteName = "instituteName"
        static let groupID = "groupID"
        static let groupName = "groupName"
        static let teacherID = "teacherID"
        static let teacherName = "teacherName"
    }
    
    static let shared = GroupsAndTeacherStorage()
    
    public var institute: SettingsModel? {
        didSet {
            self.groupNumber = nil
        }
    }
    
    init() {
        readAll()
    }
    
    public var groupNumber: SettingsModel?
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
    
    public func isReady() -> Bool {
        return (fillter == .groups && groupNumber != nil && institute != nil) || (fillter == .teachers && teachersName != nil)
    }
    
    public func doneAction() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(fillter == .groups ? 0 : 1, forKey: SettingsStorageKeyName.filterVal)
        userDefaults.set(institute?.ID, forKey: SettingsStorageKeyName.instituteID)
        userDefaults.set(institute?.title, forKey: SettingsStorageKeyName.instituteName)
        userDefaults.set(groupNumber?.ID, forKey: SettingsStorageKeyName.groupID)
        userDefaults.set(groupNumber?.title, forKey: SettingsStorageKeyName.groupName)
        userDefaults.set(teachersName?.ID, forKey: SettingsStorageKeyName.teacherID)
        userDefaults.set(teachersName?.title, forKey: SettingsStorageKeyName.teacherName)
    }
    
    private func readAll() {
        let userDefaults = UserDefaults.standard
        let instituteID = userDefaults.integer(forKey: SettingsStorageKeyName.instituteID)
        let instituteName = userDefaults.string(forKey: SettingsStorageKeyName.instituteName)
        if instituteName != nil {
            self.institute = SettingsModel(ID: instituteID, title: instituteName!)
        }
        
        let groupID = userDefaults.integer(forKey: SettingsStorageKeyName.groupID)
        let groupName = userDefaults.string(forKey: SettingsStorageKeyName.groupName)
        if groupName != nil {
            self.groupNumber = SettingsModel(ID: groupID, title: groupName!)
        }
        
        let teacherID = userDefaults.integer(forKey: SettingsStorageKeyName.teacherID)
        let teacherName = userDefaults.string(forKey: SettingsStorageKeyName.teacherName)
        if teacherName != nil {
            self.teachersName = SettingsModel(ID: teacherID, title: teacherName!)
        }
        self.fillter = userDefaults.integer(forKey: SettingsStorageKeyName.filterVal) == 0 ? .groups : .teachers
    }
}
