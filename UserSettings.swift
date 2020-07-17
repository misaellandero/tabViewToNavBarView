//
//  UserSettings.swift
//  tabViewNabView
//
//  Created by Francisco Misael Landero Ychante on 16/07/20.
//  Copyright © 2020 Francisco Misael Landero Ychante. All rights reserved.
//

import SwiftUI

 enum SectionSelected : Int, Codable {
     case  maps, schedule, reports, settings
 }

struct People : Codable {
    var id = UUID()
    var name : String
    var lastName : String
}

class Setting: Identifiable, Codable {
    var id = UUID()
    var showHomeViewOniPhone = false
    var activeSection = SectionSelected.schedule
    var detailViewActive = false
    var lastOpenPeopleID = UUID()
    var users = [People]()
}


class GlobalSettings: ObservableObject {
    @Published var userSetings : Setting
    static let saveKey = "SavedSettings"
    
    init() {
        if let data = UserDefaults.standard.data(forKey: Self.saveKey) {
            if let decoded = try? JSONDecoder().decode(Setting.self, from: data){
                self.userSetings = decoded
                return
            }
        }
        
        self.userSetings = Setting()
    }
    
    func save() {
        if let encoded = try? JSONEncoder().encode(userSetings){
            UserDefaults.standard.set(encoded, forKey: Self.saveKey)
        }
    }
    
    func changeActiveSection(_ section : SectionSelected) {
        objectWillChange.send()
        userSetings.activeSection = section
         save()
    }
    
    func getActiveSelection() -> SectionSelected {
        let selection = userSetings.activeSection
         return selection
    }
    
    func changeDetailViewisActive(_ detailViewActive : Bool) {
        objectWillChange.send()
        userSetings.detailViewActive = detailViewActive
        save()
    }
    
    func getDetailViewisActive() -> Bool {
        let detailViewisActive = userSetings.detailViewActive
        return detailViewisActive
    }
    
   func changeLastPeopleOpenID(_ id : UUID) {
       objectWillChange.send()
       userSetings.lastOpenPeopleID = id
       save()
   }
   
   func getLastPeopleOpenID() -> UUID {
       let lastRevisitOpenID = userSetings.lastOpenPeopleID
       return lastRevisitOpenID
   }
    
  func addPeople(people: People) {
        objectWillChange.send()
        self.userSetings.users.append(people)
        save()
    }
    
}
