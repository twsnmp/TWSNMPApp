//
//  MainView.swift
//  TWSNMPApp
//
//  Created by twsnmp on 2020/10/04.
//

import SwiftUI

struct MainView: View {
  @State private var showingModal = false
  @ObservedObject var dataStore = TwsnmpDataStore()
  @State private var editMode = EditMode.inactive
  @State var selectedID = ""
  var body: some View {
    NavigationView {
      List {
        ForEach(self.dataStore.twsnmps) { twsnmp in
          TwsnmpRow(twsnmp: twsnmp)
            .contextMenu(ContextMenu(menuItems: {
              Button(action: {
                self.selectedID = twsnmp.id.uuidString
                self.showingModal.toggle()
              }) {
                Text("編集")
                Image(systemName: "pencil")
              }
            }))
            .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
              if twsnmp.changed {
                self.dataStore.clearChanged(id:twsnmp.id.uuidString)
              }
            })
        }
        .onDelete(perform: onDelete)
        .onMove(perform: onMove)
      }
      .navigationTitle("TWSNMP")
      .navigationBarItems(leading: EditButton(), trailing: addButton)
      .environment(\.editMode, $editMode)
    }
    .sheet(isPresented: $showingModal) {
      EditModalView(isPresented: self.$showingModal,dataStore: self.dataStore ,id: self.selectedID )
    }
  }
  private func onDelete(at offsets: IndexSet) {
    if let first = offsets.first {
      dataStore.delete(at: first)
    }
  }
  private var addButton: some View {
    switch editMode {
    case .inactive:
      return AnyView(
        Button(action: onAdd) { Image(systemName: "plus") }
          .accessibility(identifier: "addBtn")
      )
    default:
      return AnyView(EmptyView())
    }
  }
  
  private func onAdd() {
    self.selectedID = ""
    self.showingModal.toggle()
  }
  
  private func onMove(source: IndexSet, destination: Int) {
    dataStore.twsnmps.move(fromOffsets: source, toOffset: destination)
  }
}

struct TwsnmpRow: View {
  var twsnmp: Twsnmp
  var body: some View {
    HStack(spacing: 5) {
      changedImage
      stateImage.font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
      NavigationLink(self.twsnmp.name, destination: MapInfoView(twsnmp:self.twsnmp))
    }
  }
  private var stateImage: some View {
    switch twsnmp.status {
    case "normal":
      return AnyView(Image(systemName: "checkmark.circle.fill").foregroundColor(.green))
    case "high":
      return AnyView(Image(systemName: "xmark.circle.fill").foregroundColor(.red))
    case "low":
      return AnyView(Image(systemName: "circle.fill").foregroundColor(.orange))
    case "warn":
      return AnyView(Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.yellow))
    case "repair":
      return AnyView(Image(systemName: "arrow.uturn.backward.circle.fill").foregroundColor(.blue))
    case "url":
      return AnyView(Image(systemName: "paperplane").foregroundColor(.blue))
    case "user":
      return AnyView(Image(systemName: "person").foregroundColor(.blue))
    case "info":
      return AnyView(Image(systemName: "info.circle").foregroundColor(.blue))
    default:
      return AnyView(Image(systemName: "questionmark.circle.fill").foregroundColor(.gray))
    }
  }
  private var changedImage:some View {
    if twsnmp.changed {
      return AnyView(Image(systemName: "exclamationmark.arrow.triangle.2.circlepath")
                      .foregroundColor(.red).font(.body).padding(2))
    }
    return AnyView(Image(systemName: "checkmark")
                    .foregroundColor(.blue).font(.body).padding(2))
  }
}


struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    MainView()
  }
}
