//
//  MultiAccountWidgetView.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 08.10.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import WidgetKit
import SwiftUI
import Localize_Swift

struct IconView : View {
    var account: SingleAccountForMulti?
    var entry: SingleAccountProvider.Entry?
    
    
    var body: some View {
        if account != nil {
            let icon  = Constants.HttpUrlWithoutApi + account!.poolIcon
            Image(uiImage: icon.getImageWithURL())
                .resizable()
                .cornerRadius(5)
                .scaledToFit()
                .minimumScaleFactor(0.5)
        }
        if entry != nil {
            let icon  = Constants.HttpUrlWithoutApi + entry!.poolIcon
            Image(uiImage: icon.getImageWithURL())
                .resizable()
                .cornerRadius(5)
                .scaledToFit()
                .minimumScaleFactor(0.5)
        }
    }
}


struct MultiAccountWidgetView: View {
    
    var entry: MultiAccountProvider.Entry
    
    var body: some View {
        ZStack(alignment:.center) {
            if entry.darkMode {
                
                Color(red: 58/255, green: 58/255, blue: 60/255)
                    .overlay(
                        RoundedRectangle(cornerRadius: 23)
                            .stroke(Color(red: 30/255, green: 152/255, blue: 155/255), lineWidth: 3)
                    )
            } else {
                Color(red: 244/255, green: 244/255, blue: 244/255)
                    .overlay(
                        RoundedRectangle(cornerRadius: 23)
                            .stroke(Color(red: 30/255, green: 152/255, blue: 155/255), lineWidth: 3)
                    )
            }
            
            if !(entry.isLogin) {
                Text("login_login")
                    .foregroundColor(entry.darkMode ? .white : .black).bold()
                    .padding()
                    .environment(\.locale, .init(identifier: UserDefaults(suiteName: "group.com.witplex.MinerBox")?.string(forKey: "appLanguage") ?? "en"))
                    
                    .widgetURL(URL(string:"minerbox://localhost/login")!)
            } else if !(entry.isSubscribted ?? true)  {
                
                ZStack(alignment:.center) {
                    if entry.darkMode {
                        
                        Color(red: 58/255, green: 58/255, blue: 60/255)
                            .overlay(
                                RoundedRectangle(cornerRadius: 23)
                                    .stroke(Color(red: 30/255, green: 152/255, blue: 155/255), lineWidth: 3)
                            )
                        GeometryReader { geo in
                            
                            VStack(alignment: .center, content: {
                                Text("need_subscription")
                                    .foregroundColor(.white).bold()
                                    .font(.system(size: 20))
                                    .environment(\.locale, .init(identifier: UserDefaults(suiteName: "group.com.witplex.MinerBox")?.string(forKey: "appLanguage") ?? "en"))
                                    .frame(width: geo.size.width, height: geo.size.height / 2)
                                    .allowsTightening(true)
                                    .lineLimit(2)
                                    .scaledToFit()
                                    .minimumScaleFactor(0.5)
                                    .multilineTextAlignment(.center)
                                Image("SubscribeDark")
                                    .resizable()
                                    .frame(width: 70, height: 70, alignment: .center)
                                    .cornerRadius(5)
                                
                            })
                        }
                        
                    } else {
                        Color(red: 244/255, green: 244/255, blue: 244/255)
                            .overlay(
                                RoundedRectangle(cornerRadius: 23)
                                    .stroke(Color(red: 30/255, green: 152/255, blue: 155/255), lineWidth: 3)
                            )
                        GeometryReader { geo in
                            
                            VStack(alignment: .center, content: {
                                Text("need_subscription")
                                    .foregroundColor(.black).bold()
                                    .font(.system(size: 20))
                                    .environment(\.locale, .init(identifier: UserDefaults(suiteName: "group.com.witplex.MinerBox")?.string(forKey: "appLanguage") ?? "en"))
                                    .frame(width: geo.size.width, height: geo.size.height / 2)
                                    .allowsTightening(true)
                                    .lineLimit(2)
                                    .scaledToFit()
                                    .minimumScaleFactor(0.5)
                                    .multilineTextAlignment(.center)
                                Image("SubscribeLigth")
                                    .resizable()
                                    .frame(width: 70, height: 70, alignment: .center)
                                    .cornerRadius(5)
                            })
                            
                        }
                        
                    }
                }
                .widgetURL(URL(string:"minerbox://localhost/subscription")!)
            } else if entry.noAccount  {
                
                ZStack(alignment:.center) {
                    if entry.darkMode {
                        
                        Color(red: 58/255, green: 58/255, blue: 60/255)
                            .overlay(
                                RoundedRectangle(cornerRadius: 23)
                                    .stroke(Color(red: 30/255, green: 152/255, blue: 155/255), lineWidth: 3)
                            )
                    } else {
                        Color(red: 244/255, green: 244/255, blue: 244/255)
                            .overlay(
                                RoundedRectangle(cornerRadius: 23)
                                    .stroke(Color(red: 30/255, green: 152/255, blue: 155/255), lineWidth: 3)
                            )
                    }
                    
                    Text("add_pool_account")
                        .foregroundColor(entry.darkMode ? .white : .black).bold()
                        .font(.system(size: 20))
                        .environment(\.locale, .init(identifier: UserDefaults(suiteName: "group.com.witplex.MinerBox")?.string(forKey: "appLanguage") ?? "en"))
                        .allowsTightening(true)
                        .lineLimit(2)
                        .scaledToFit()
                        .minimumScaleFactor(0.5)
                        .multilineTextAlignment(.center)
                    
                }
                .widgetURL(URL(string:"minerbox://localhost/addAccounts")!)
            }  else if entry.noSelectedAccount  {
                
                ZStack(alignment:.center) {
                    if entry.darkMode {
                        
                        Color(red: 58/255, green: 58/255, blue: 60/255)
                            .overlay(
                                RoundedRectangle(cornerRadius: 23)
                                    .stroke(Color(red: 30/255, green: 152/255, blue: 155/255), lineWidth: 3)
                            )
                    } else {
                        Color(red: 244/255, green: 244/255, blue: 244/255)
                            .overlay(
                                RoundedRectangle(cornerRadius: 23)
                                    .stroke(Color(red: 30/255, green: 152/255, blue: 155/255), lineWidth: 3)
                            )
                    }
                    
                    Text("update_widget_settings")
                        .foregroundColor(entry.darkMode ? .white : .black).bold()
                        .font(.system(size: 11))
                        .environment(\.locale, .init(identifier: UserDefaults(suiteName: "group.com.witplex.MinerBox")?.string(forKey: "appLanguage") ?? "en"))
                        .allowsTightening(true)
                        .lineLimit(2)
                        .scaledToFit()
                        .minimumScaleFactor(0.5)
                        .multilineTextAlignment(.center)
                    
                }
            } else {
                ZStack {
                    Image("timeVertical")
                        .resizable()
                        .frame(width:  entry.widgetSize.width / 7, height: entry.widgetSize.width / 14, alignment: .center)
                    Text(entry.date, style: .time)
                              .lineLimit(1)
                              .font(.system(size: entry.widgetSize.width / 38))
                              .foregroundColor(.white)
                }
                .frame(width: entry.widgetSize.width, height: entry.widgetSize.height, alignment: .leading)
                .offset(x: entry.widgetSize.width * 0.8,y: -(entry.widgetSize.height * 0.47))
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(entry.accounts, id: \.self) { ( account: SingleAccountForMulti ) in
                        Link(destination: URL(string:account.poolId == "minerbox://localhost/accounts" ? " " : "minerbox://localhost/accounts,\(account.poolId)")!, label: {
                            VStack(alignment: .leading,spacing: 0) {
                                HStack {
                                    IconView(account: account)
                                        .frame(width: entry.widgetSize.width / 8.8, height: entry.widgetSize.width / 8.8)
                                    VStack(alignment: .center,spacing: 15) {
                                        Text(account.poolAccountName)
                                            .font(.system(size: 16)).bold()
                                            .frame(width: entry.widgetSize.width * 0.25, height: 5, alignment: .leading)
                                            .foregroundColor(Color(red: 30/255, green: 152/255, blue: 155/255))
                                            .scaledToFit()
                                            .minimumScaleFactor(0.8)
                                        Text(account.poolType)
                                            .foregroundColor(entry.darkMode ? .white : .black).bold()
                                            .frame(width: entry.widgetSize.width * 0.25, height: 5, alignment: .leading)
                                            .font(.system(size: 16))
                                            .scaledToFit()
                                            .minimumScaleFactor(0.8)
                                        if account.subType != "" {
                                            Text(account.subType)
                                                .foregroundColor(entry.darkMode ? .white : .black).bold()
                                                .frame(width: entry.widgetSize.width * 0.25, height: 5, alignment: .leading)
                                                .font(.system(size: 14))
                                                .scaledToFit()
                                                .minimumScaleFactor(0.8)
                                        }
                                    }
                                    VStack(alignment: .leading,spacing: 4){
                                        HStack{
                                            Image("hashrate_alert")
                                                .resizable()
                                                .frame(width: entry.widgetSize.width / 16.2, height: entry.widgetSize.width / 16.2)
                                                .cornerRadius(5)
                                            Text(account.currentHashrate)
                                                .font(.system(size: entry.widgetSize.width / 24))
                                                .frame(width: entry.widgetSize.width * 0.40, height: 0, alignment: .leading)
                                                .foregroundColor(entry.darkMode ? .white : .black)
                                                .scaledToFit()
                                        }
                                        HStack{
                                            Image("worker_alert")
                                                .resizable()
                                                .frame(width: entry.widgetSize.width / 16.2, height: entry.widgetSize.width / 16.2)
                                                .cornerRadius(5)
                                            Text(account.workersCount.getFormatedString())
                                                .font(.system(size: entry.widgetSize.width / 24))
                                                .frame(width: entry.widgetSize.width * 0.40, height: 0, alignment: .leading)
                                                .foregroundColor(entry.darkMode ? .white : .black)
                                                .scaledToFit()
                                        }
                                        if account.balance != nil {
                                            HStack{
                                                Image("income")
                                                    .resizable()
                                                    .frame(width: entry.widgetSize.width / 16.2, height: entry.widgetSize.width / 16.2)
                                                    .cornerRadius(5)
                                                Text(account.balance!.value)
                                                    .font(.system(size: entry.widgetSize.width / 24))
                                                    .frame(width: entry.widgetSize.width * 0.28, height: 10, alignment: .leading)
                                                    .foregroundColor(entry.darkMode ? .white : .black)
                                                    .scaledToFit()
                                                    .minimumScaleFactor(0.8)
                                                Text(account.balance!.type)
                                                    .font(.system(size: entry.widgetSize.width / 24))
                                                    .frame(width: entry.widgetSize.width * 0.12, height: 10, alignment: .leading)
                                                    .foregroundColor(entry.darkMode ? .white : .black)
                                                    .scaledToFit()
                                                    .minimumScaleFactor(0.7)
                                            }
                                        }
                                    }
                                }
                                .padding(.init(top: -2, leading: 5, bottom: -2, trailing: 0 ))
                            }
                            if account.numberAccount < entry.accounts.count {
                                Divider().background(Color(red: 30/255, green: 152/255, blue: 155/255))
                                    .frame(width: entry.widgetSize.width * 0.96, height: 10,alignment: .center)
                                    .padding(.init(top: account.balance == nil ? entry.widgetSize.width / 30 : 5, leading: 0, bottom: account.balance == nil ? entry.widgetSize.width / 30 : 5, trailing: 0))
                            }
                        })
                    }
                }
            }
        }
    }
}

struct MultiAccountWidget_Previews: PreviewProvider {
    static var previews: some View {
        MultiCoinView(entry: MultiCoinWidgetEntry(date: Date(), configuration: MultiCoinConfigurationIntent(), widgetSize: CGSize(width: 150, height: 150)))
    }
}

