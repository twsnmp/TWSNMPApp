//
//  NodeListView.swift
//  TWSNMPApp
//
//  Created by twsnmp on 2020/10/04.
//

import SwiftUI

struct MapInfoView: View {
  var twsnmp : Twsnmp
  @State private var isShowHigh: Bool = false
  @State private var isShowLow: Bool = false
  @State private var isShowWarn: Bool = false
  @State private var isShowRepair: Bool = false
  var body: some View {
    List {
      MapInfoRow(icon:"info",name:"名前",value:twsnmp.name)
      MapInfoRow(icon:"url",name:"URL",value:twsnmp.url)
      MapInfoRow(icon:"info",name:"DB サイズ",value:twsnmp.mapStatus.DBSizeStr)
      MapInfoRow(icon:twsnmp.status,name:"MAP状態",value:stateName)
      MapInfoRow(icon:"normal",name:"正常",value:String(twsnmp.mapStatus.Normal))
      MapInfoRow(icon:"high",name:"重度",value:String(twsnmp.mapStatus.High))
        .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
          self.isShowHigh = true
        })
        .contentShape(Rectangle())
        .alert(isPresented: $isShowHigh){
          Alert(
            title: Text("重度の管理対象"),
            message: Text("\n"+self.twsnmp.highNodes),
            dismissButton: .default(Text("閉じる"))
          )
        }
      MapInfoRow(icon:"low",name:"軽度",value:String(twsnmp.mapStatus.Low))
        .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
          self.isShowLow = true
        })
        .contentShape(Rectangle())
        .alert(isPresented: $isShowLow){
          Alert(
            title: Text("軽度の管理対象"),
            message: Text("\n"+self.twsnmp.lowNodes),
            dismissButton: .default(Text("閉じる"))
          )
        }
      MapInfoRow(icon:"warn",name:"注意",value:String(twsnmp.mapStatus.Warn))
        .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
          self.isShowWarn = true
        })
        .contentShape(Rectangle())
        .alert(isPresented: $isShowWarn){
          Alert(
            title: Text("注意の管理対象"),
            message: Text("\n"+self.twsnmp.warnNodes),
            dismissButton: .default(Text("閉じる"))
          )
        }
      MapInfoRow(icon:"repair",name:"復帰",value:String(twsnmp.mapStatus.Repair))
        .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
          self.isShowRepair = true
        })
        .contentShape(Rectangle())
        .alert(isPresented: $isShowRepair){
          Alert(
            title: Text("復帰した管理対象"),
            message: Text("\n"+self.twsnmp.repairNodes),
            dismissButton: .default(Text("閉じる"))
          )
        }
      MapInfoRow(icon:"unkown",name:"不明",value:String(twsnmp.mapStatus.Unknown))
    }
    .navigationBarTitle("\(twsnmp.name)",
                        displayMode: .inline)
  }
  private var stateName: String {
    switch twsnmp.status {
    case "normal":
      return "正常"
    case "high":
      return "重度"
    case "low":
      return "軽度"
    case "warn":
      return "注意"
    case "repair":
      return "復帰"
    default:
      return "不明"
    }
  }
}

struct MapInfoRow: View {
  let icon: String
  let name: String
  let value: String
  var body: some View {
    HStack {
      mapInfoImage.font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
      Text(self.name)
      Spacer()
      Text(self.value).font(.body)
    }
    .padding(5)
  }
  private var mapInfoImage: some View {
    switch icon {
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
}

struct MapInfoView_Previews: PreviewProvider {
  @State static var twsnmp = Twsnmp(name:"a",url:"https://10.30.10.1:9182",user:"a",password:"a")
  static var previews: some View {
    MapInfoView(twsnmp: twsnmp)
  }
}
