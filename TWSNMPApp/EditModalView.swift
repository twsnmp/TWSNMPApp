//
//  EditModalView.swift
//  TWSNMPApp
//
//  Created by twsnmp on 2020/10/04.
//

import SwiftUI

struct EditModalView: View {
  @Binding var isPresented: Bool
  var dataStore: TwsnmpDataStore
  var id: String
  @State var title:String = "新しいTWSNMP"
  @State var name: String = ""
  @State var url: String = ""
  @State var user: String = ""
  @State var password: String = ""
  
  var body: some View {
    NavigationView {
      VStack(alignment: .center) {
        Text(title).font(.title)
        VStack(spacing: 24) {
          TextField("名前", text: $name)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .frame(maxWidth: 280)
            .autocapitalization(.none)
            .accessibility(identifier: "nameTextField")
          TextField("URL", text: $url)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .frame(maxWidth: 280)
            .autocapitalization(.none)
            .accessibility(identifier: "urlTextField")
          TextField("ユーザーID", text: $user)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .frame(maxWidth: 280)
            .autocapitalization(.none)
            .accessibility(identifier: "userTextField")
          SecureField("パスワード", text: $password)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .frame(maxWidth: 280)
            .accessibility(identifier: "passwordSecureField")
        }
        .frame(height: 250)
        HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
          Button(action: {
            self.isPresented.toggle()
            if self.id != ""  {
              if var t = dataStore.find(id:id) {
                t.name = self.name
                t.url = self.url
                t.user = self.user
                t.password = self.password
                self.dataStore.update(id: id, twsnmp:t)
              }
              return
            }
            self.dataStore.add(twsnmp: Twsnmp(name: self.name, url:self.url,user:self.user,password:self.password))
          },
          label: {
            Text("保存")
              .fontWeight(.medium)
              .frame(minWidth: 120)
              .foregroundColor(.white)
              .padding(10)
              .background(Color.accentColor)
              .cornerRadius(8)
          })
          .accessibility(identifier: "saveBtn")
          Button(action: {
            self.isPresented.toggle()
          },
          label: {
            Text("取消")
              .fontWeight(.medium)
              .frame(minWidth: 120)
              .foregroundColor(.black)
              .padding(10)
              .background(Color.gray)
              .cornerRadius(8)
          })
        })
        Spacer()
      }
    }.onAppear{
      if let t = dataStore.find(id:id) {
        self.name = t.name
        self.url = t.url
        self.user = t.user
        self.password = t.password
        self.title = t.name + "の編集"
      }
    }
  }
  
}

struct EditModalView_Previews: PreviewProvider {
  @State static var showingModal = false
  @State static var calcelModal = true
  static var  d = TwsnmpDataStore()
  static var previews: some View {
    EditModalView(isPresented: $showingModal, dataStore:d,id: "")
  }
}
