//
//  BackEnd.swift
//  TWSNMPApp
//
//  Created by twsnmp on 2020/10/04.
//

import Foundation
import Alamofire

struct Twsnmp: Identifiable{
  var id = UUID()     // ユニークなIDを自動で設定
  var name: String
  var url : String
  var user : String
  var password : String
  var status = "unknown"
  var highNodes = ""
  var lowNodes = ""
  var warnNodes = ""
  var repairNodes = ""
  var count = 0
  var nextPolling = Date().addingTimeInterval(5)
  var mapStatus = TwsnmpMapStatus()
  init(name:String,url:String,user:String,password:String){
    self.name = name
    self.url = url
    self.user = user
    self.password = password
  }
}

struct  TwsnmpMapStatus :Codable {
  var High:Int = 0
  var Low: Int = 0
  var Warn:Int = 0
  var Normal:Int = 0
  var Repair:Int = 0
  var Unknown: Int = 0
  var State:String = ""
  var DBSize:Int64 = 0
  var DBSizeStr:String = ""
}

struct TwsnmpNode :Codable {
  var Name:String
  var Descr:String
  var State:String
}

struct TwsnmpMapData :Codable {
  var Nodes:  Dictionary<String,TwsnmpNode>
}

final class TwsnmpDataStore: ObservableObject  {
  @Published  var twsnmps :[Twsnmp] = [Twsnmp]()
  var sesstion = Session()
  init(){
    do {
      self.pollingScheduler()
      let uDef = UserDefaults.standard
      // 保存したJSONの文字列を読み出す
      let json = uDef.string(forKey: "twsnmps")
      if json == nil {
        return
      }
      //TWSNMPの登録情報に変換する
      let decoder = JSONDecoder()
      let loadData = try decoder.decode([[String:String]].self, from: json!.data(using: .utf8)!)
      for  ent in loadData  {
        let name = ent["name"] ?? ""
        let url = ent["url"] ?? ""
        let user = ent["user"] ?? ""
        let password = ent["password"] ?? ""
        if name == "" || url == "" || user == "" {
          continue
        }
        twsnmps.append(Twsnmp(name:name,url:url,user:user,password:password))
      }
    } catch (let error){
      debugPrint(error)
      return
    }
  }
  // リストを保存する
  func save() {
    do {
      var saveData = [[String:String]]()
      for twsnmp in twsnmps {
        saveData.append(["name":twsnmp.name,"url":twsnmp.url,"user":twsnmp.user,"password":twsnmp.password])
      }
      // JSONの文字列に変換する
      let encoder = JSONEncoder()
      encoder.outputFormatting = .prettyPrinted
      let data = try encoder.encode(saveData)
      let json = String(data: data, encoding: .utf8)!
      print(json)
      // JSONの文字列を保存する
      let uDef = UserDefaults.standard
      uDef.set(json, forKey: "twsnmps")
      print("saved")
    } catch {
      return
    }
  }
  // 追加
  func add(twsnmp:Twsnmp){
    twsnmps.append(twsnmp)
    self.save()
  }
  func find(id:String) -> Twsnmp? {
    if id  == "" {
      return nil
    }
    for  t in self.twsnmps {
      if t.id.uuidString == id {
        return t
      }
    }
    return nil
  }
  // 更新
  func update(id:String,twsnmp:Twsnmp,save:Bool = true) {
    if id  == "" {
      return
    }
    for  (i,_) in self.twsnmps.enumerated() {
      if self.twsnmps[i].id.uuidString == id {
        self.twsnmps[i] = twsnmp
        if save {
          self.save()
        }
        return
      }
    }
  }
  // 削除
  func delete(at:Int){
    self.twsnmps.remove(at: at)
    self.save()
  }
  func pollingScheduler() {
    self.polling()
    Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { timer in
      self.polling()
    }
  }
  func polling() {
      for  var t in self.twsnmps {
        let now = Date()
        if t.nextPolling < now {
          t.nextPolling = now.addingTimeInterval(60)
          self.update(id: t.id.uuidString, twsnmp:t,save:false)
          self.getMapStatus(id: t.id.uuidString, completion: { r in
            if r {
              self.getMapData(id: t.id.uuidString, completion: {r in
                if !r {
                  t.repairNodes = "TWSNMPから取得できませんでした。"
                  t.highNodes = t.repairNodes
                  t.lowNodes = t.repairNodes
                  t.warnNodes = t.repairNodes
                  self.update(id: t.id.uuidString, twsnmp:t,save:false)
                }
              })
            } else {
              t.status = "unknown"
              self.update(id: t.id.uuidString, twsnmp:t,save:false)
            }
          })
        }
      }
  }
  func getMapStatus(id:String,completion: @escaping (Bool) -> Void) {
    guard var twsnmp = self.find(id:id) else {
      completion(false)
      return
    }
    let configuration = URLSessionConfiguration.af.default
    let headers: HTTPHeaders = [.authorization(username: twsnmp.user, password: twsnmp.password)]
    let url = URL(string: twsnmp.url)
    guard let host = url?.host else {
      twsnmp.status = "unkown"
      completion(false)
      return
    }
    sesstion = Session(configuration: configuration, serverTrustManager: ServerTrustManager(allHostsMustBeEvaluated: false, evaluators: [host: DisabledTrustEvaluator()]))
    sesstion.request(twsnmp.url+"/api/mapstatus",headers: headers)
      .responseJSON { response in
        debugPrint(response)
        switch response.result {
        case .success:
          guard let r = response.response else {
            completion(false)
            return
          }
          if r.statusCode != 200 {
            debugPrint(r.statusCode)
            completion(false)
            return
          }
          guard let data = response.data else {
            completion(false)
            return
          }
          do {
            twsnmp.mapStatus = try JSONDecoder().decode(TwsnmpMapStatus.self, from: data)
            twsnmp.count += 1
            twsnmp.status = twsnmp.mapStatus.State
            debugPrint(twsnmp.mapStatus)
            self.update(id: twsnmp.id.uuidString, twsnmp: twsnmp)
            completion(true)
          } catch (let error) {
            debugPrint(error)
            completion(false)
          }
        case .failure(let error):
          debugPrint(error)
          completion(false)
        }
      }
  }
  func getMapData(id:String,completion: @escaping (Bool) -> Void) {
    guard var twsnmp = self.find(id:id) else {
      completion(false)
      return
    }
    let configuration = URLSessionConfiguration.af.default
    let headers: HTTPHeaders = [.authorization(username: twsnmp.user, password: twsnmp.password)]
    let url = URL(string: twsnmp.url)
    guard let host = url?.host else {
      twsnmp.status = "unkown"
      completion(false)
      return
    }
    sesstion = Session(configuration: configuration, serverTrustManager: ServerTrustManager(allHostsMustBeEvaluated: false, evaluators: [host: DisabledTrustEvaluator()]))
    sesstion.request(twsnmp.url+"/api/mapdata",headers: headers)
      .responseJSON { response in
        debugPrint(response)
        switch response.result {
        case .success:
          guard let r = response.response else {
            completion(false)
            return
          }
          if r.statusCode != 200 {
            debugPrint(r.statusCode)
            completion(false)
            return
          }
          guard let data = response.data else {
            completion(false)
            return
          }
          do {
            let md = try JSONDecoder().decode(TwsnmpMapData.self, from: data)
            twsnmp.repairNodes = ""
            twsnmp.highNodes = ""
            twsnmp.lowNodes = ""
            twsnmp.warnNodes = ""
            for (_,n) in md.Nodes{
              switch n.State {
              case "high":
                twsnmp.highNodes += n.Name + "\n"
              case "low":
                twsnmp.lowNodes += n.Name + "\n"
              case "warn":
                twsnmp.warnNodes += n.Name + "\n"
              case "repair":
                twsnmp.repairNodes += n.Name + "\n"
              default:
                continue
              }
            }
            debugPrint(twsnmp.mapStatus)
            self.update(id: twsnmp.id.uuidString, twsnmp: twsnmp,save:false)
            completion(true)
          } catch (let error) {
            debugPrint(error)
            completion(false)
          }
        case .failure(let error):
          debugPrint(error)
          completion(false)
        }
      }
  }
}

