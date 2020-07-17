//
//  ContentView.swift
//  tabViewNabView
//
//  Created by Francisco Misael Landero Ychante on 16/07/20.
//  Copyright © 2020 Francisco Misael Landero Ychante. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    // MARK: -  Detectar el tamaño de la pantalla
    @Environment(\.horizontalSizeClass) var sizeClass
    
    // MARK: -  Configuraciones del usuario
    @EnvironmentObject var settings : GlobalSettings
    
   
    var body: some View {
        Group{
            // MARK: -  Mostrar navegacion con pestañas en iPhone
                           if self.sizeClass == .compact
                           {
                               NavigationViewForiPhone(activeView: settings.getActiveSelection())
                           }
                           else
                           {
                               NavigationViewForiPad(currentView: settings.getActiveSelection())
                           }
        }
    }
}



struct NavigationViewForiPad: View {
    
    // MARK: - Configuraciones del Usuario
    @EnvironmentObject var settings : GlobalSettings
     
    @State var currentView: SectionSelected
    
    var body: some View {
        NavigationView{
            HomeView(activeView: settings.getActiveSelection())
            
            .navigationViewStyle(DoubleColumnNavigationViewStyle())
            
        }
    }
}

struct HomeView: View{
    // MARK: - Configuraciones del Usuario
    @EnvironmentObject var settings : GlobalSettings
    @State var activeView : SectionSelected?
    
    var body: some View {
        ZStack {
            List {
                // MARK: - Menu de secciones
                Section(header:
                    Text("Menu")
                        .font(.title)
                        .bold()
                        .foregroundColor(.secondary)){
                // MARK: - Maps view menu
                NavigationLink(destination:
                        MapView()
                        .navigationBarTitle("Maps"),
                    tag: .maps,
                    selection: self.$activeView) {
                        HStack{
                            Image(systemName: "map")
                            Text("Maps")
                        }
                     }
                // MARK: - List view menu
                NavigationLink(destination:
                    ListView(isShowingDetailView: self.settings.getDetailViewisActive()),
                         tag: .schedule,
                         selection: self.$activeView) {
                             HStack{
                                 Image(systemName: "list.bullet")
                                 Text("List")
                             }
                          }
                // MARK: - Reports view menu
                NavigationLink(destination:
                        Reports(),
                               tag: .reports,
                               selection: self.$activeView) {
                                   HStack{
                                    Image(systemName: "chart.pie")
                                    Text("Reportes")
                                   }
                                }
                // MARK: - Reports view menu
                NavigationLink(destination:
                        Settings(),
                                tag: .settings,
                                selection: self.$activeView) {
                                    HStack{
                                        Image(systemName: "gear")
                                        Text("Settings")
                                    }
                                }
                            
                }
                .padding()
            }
            .listStyle(GroupedListStyle())
            .environment(\.horizontalSizeClass, .regular)
            .navigationBarTitle(Text("Inicio"))
        }
    }
}

struct NavigationViewForiPhone: View {
    // MARK: - Configuraciones del Usuario
    @EnvironmentObject var settings : GlobalSettings
    @State var activeView : SectionSelected
    
    var body: some View {
            TabView(selection: $activeView.onChange(changeActiveView) ){
                NavigationView{
                    MapView()
                    .navigationBarTitle("Map")
                    .onAppear{
                        self.changeActiveView(SectionSelected.maps)
                    }
                }
                .tabItem {
                            Image(systemName: "map.fill")
                            Text("Maps")
                }.tag(SectionSelected.maps)
                NavigationView{
                    ListView(isShowingDetailView: self.settings.getDetailViewisActive())
                    .onAppear{
                        self.changeActiveView(SectionSelected.schedule)
                    }
                }
                .tabItem {
                            Image(systemName: "list.bullet")
                            Text("List")
                }.tag(SectionSelected.schedule)
               
                Reports()
                    .onAppear{
                        self.changeActiveView(SectionSelected.reports)
                    }
                .tabItem {
                            Image(systemName: "chart.pie")
                            Text("Reports")
                            .layoutPriority(1)
                }.tag(SectionSelected.reports)
                
                Settings()
                    .onAppear{
                        self.changeActiveView(SectionSelected.settings)
                    }
                .tabItem {
                            Image(systemName: "gear")
                            Text("Settings")
                            .layoutPriority(1)
                }.tag(SectionSelected.settings)
               
                
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                self.changeActiveView(self.activeView)
            }
    }
    func changeActiveView(_ tag: SectionSelected ){
        self.settings.changeActiveSection(tag)
    }
}

struct ListView: View {
    // MARK: - Configuraciones del Usuario
    @EnvironmentObject var settings : GlobalSettings
    @State var isShowingDetailView = false
    
    var body: some View {
        Group{
            List(){
                if self.isShowingDetailView {
                    NavigationLink(destination:
                    DetailView(people:self.getPeople()), isActive: self.$isShowingDetailView) { EmptyView() }
                }
                
                ForEach(self.settings.userSetings.users, id: \.id){ people in
                    NavigationLink(destination:
                    DetailView(people: people)){
                        Text(people.name)
                    }
                    
                }
                
            }
        }

                .navigationBarTitle("List View")
                .navigationBarItems(trailing:
                HStack{
                    Button("New"){
                        let newPerson = People(name: "Name\(Int.random(in: 1..<100))", lastName: "LastName\(Int.random(in: 1..<100))")
                        self.settings.userSetings.users.append(newPerson)
                        
                    }
                    }
                )
            
    }
    
    func getPeople() -> People {
           let id = self.settings.getLastPeopleOpenID()
        let people = self.settings.userSetings.users.filter({ $0.id == id }).first
           return  people!
       }
}

struct Reports: View {
    var body: some View {
            Text("Reports")
            .navigationBarTitle("Reports")
   
    }
}

struct Settings: View {
    var body: some View {
            Text("Settings")
            .navigationBarTitle("Settings")

    }
}

struct DetailView: View {
    // MARK: - Configuraciones del Usuario
    @EnvironmentObject var settings : GlobalSettings
    var people : People
    var body: some View {
        VStack{
            Text(people.name)
            Text(people.lastName)
        }
        .navigationBarTitle(people.name)
        .onAppear{
                self.settings.changeDetailViewisActive(true)
            print("Ahora detail view is \(self.people.name)")
                self.settings.changeLastPeopleOpenID(self.people.id)
        }
        .onDisappear{
            //self.settings.changeDetailViewisActive(false)
        }
    }
}

extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        return Binding(
            get: { self.wrappedValue },
            set: { selection in
                self.wrappedValue = selection
                handler(selection)
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
