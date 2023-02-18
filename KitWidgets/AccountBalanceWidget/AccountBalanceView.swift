//
//  AccountBalanceView.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 22.10.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import WidgetKit
import SwiftUI
import Localize_Swift



struct AccountBalanceView: View {
    
    var entry: AccountBalanceProvider.Entry
    
    
    var body: some View {
        if !(entry.isLogin ?? true) {
            
            ZStack {
                if entry.darkMode {
                    
                    Color(red: 58/255, green: 58/255, blue: 60/255)
                        .overlay(
                            RoundedRectangle(cornerRadius: 23)
                                .stroke(Color(red: 30/255, green: 152/255, blue: 155/255), lineWidth: 3)
                        )
                    Text("login_login")
                        .foregroundColor(.white).bold()
                        .padding()
                        .environment(\.locale, .init(identifier: UserDefaults(suiteName: "group.com.witplex.MinerBox")?.string(forKey: "appLanguage") ?? "en"))
                } else {
                    Color(red: 244/255, green: 244/255, blue: 244/255)
                        .overlay(
                            RoundedRectangle(cornerRadius: 23)
                                .stroke(Color(red: 30/255, green: 152/255, blue: 155/255), lineWidth: 3)
                        )
                    Text("login_login")
                        .foregroundColor(.black).bold()
                        .padding()
                        .environment(\.locale, .init(identifier: UserDefaults(suiteName: "group.com.witplex.MinerBox")?.string(forKey: "appLanguage") ?? "en"))
                }
            }
            .widgetURL(URL(string:"minerbox://localhost/login")!)
        } else if !(entry.isSubscribted ?? true)  {
            
            ZStack(alignment:.center) {
                if entry.darkMode {
                    
                    Color(red: 58/255, green: 58/255, blue: 60/255)
                        .overlay(
                            RoundedRectangle(cornerRadius: 23)
                                .stroke(Color(red: 30/255, green: 152/255, blue: 155/255), lineWidth: 3)
                        )
                    VStack(alignment: .center, content: {
                        Text("need_subscription")
                            .foregroundColor(.white).bold()
                            .font(.system(size: entry.widgetSize.height / 10))
                            .environment(\.locale, .init(identifier: UserDefaults(suiteName: "group.com.witplex.MinerBox")?.string(forKey: "appLanguage") ?? "en"))
                            .frame(width: entry.widgetSize.height, height: entry.widgetSize.height / 2)
                            .allowsTightening(true)
                            .lineLimit(2)
                            .scaledToFit()
                            .minimumScaleFactor(0.5)
                            .multilineTextAlignment(.center)
                        Image("SubscribeDark")
                            .resizable()
                            .frame(width: 40, height: 40, alignment: .center)
                            .cornerRadius(5)
                    })
                } else {
                    Color(red: 244/255, green: 244/255, blue: 244/255)
                        .overlay(
                            RoundedRectangle(cornerRadius: 23)
                                .stroke(Color(red: 30/255, green: 152/255, blue: 155/255), lineWidth: 3)
                        )
                    VStack(alignment: .center, content: {
                        Text("need_subscription")
                            .foregroundColor(.black).bold()
                            .font(.system(size: entry.widgetSize.height / 10))
                            .environment(\.locale, .init(identifier: UserDefaults(suiteName: "group.com.witplex.MinerBox")?.string(forKey: "appLanguage") ?? "en"))
                            .frame(width: entry.widgetSize.height, height: entry.widgetSize.height / 2)
                            .allowsTightening(true)
                            .lineLimit(2)
                            .scaledToFit()
                            .minimumScaleFactor(0.5)
                            .multilineTextAlignment(.center)
                        Image("SubscribeLigth")
                            .resizable()
                            .frame(width: 40, height: 40, alignment: .center)
                            .cornerRadius(5)
                    })
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
                    .font(.system(size: 11))
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
            ZStack(alignment:.leading) {
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
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 10, content: {
                        
                        HStack(spacing: 10) {
                            IconView(entry: entry)
                                .frame(width: 33, height: 33)
                            VStack(alignment: .leading,spacing: 14) {
                                Text(entry.poolAccountName ?? "")
                                    .font(.system(size: entry.widgetSize.height / 10)).bold()
                                    .frame(width: entry.widgetSize.width * 0.7, height: 6, alignment: .leading)
                                    .foregroundColor(Color(red: 30/255, green: 152/255, blue: 155/255))
                                Text("\(entry.poolTypeAndSubType)")
                                    .foregroundColor(entry.darkMode ? .white : .black).bold()
                                    .frame(width:  entry.widgetSize.width * 0.7, height: 6, alignment: .leading)
                                    .font(.system(size:  entry.widgetSize.height / 10))
                                    .scaledToFit()
                                    .minimumScaleFactor(0.7)
                            }
                            .padding(.trailing)
                        }
                    })
                    .offset(x:10,y:2)
                    
                    VStack(alignment: .leading,spacing: 1, content: {
                        
                        HStack(alignment: .center, spacing: 10) {
                            Image("hashrate_alert")
                                .resizable()
                                .frame(width:  18, height: 18, alignment: .center)
                                .cornerRadius(5)
                            Text(entry.currentHashrate)
                                .font(.custom("", size:  entry.widgetSize.height / 15))
                                .foregroundColor(entry.darkMode ? .white : .black).bold()
                                .scaledToFit()
                                .minimumScaleFactor(0.8)
                        }
                        Divider().background(Color(red: 30/255, green: 152/255, blue: 155/255))
                            .frame(width: entry.widgetSize.width * 0.96 - 10, height: 5, alignment: .center)
                            .padding(.top,0)
                        HStack(alignment: .center, spacing: 10) {
                            Image("worker_alert")
                                .resizable()
                                .frame(width: 18, height: 18, alignment: .center)
                                .cornerRadius(5)
                            if entry.workersCount != nil {
                                Text(entry.workersCount!.getFormatedString())
                                    .font(.custom("", size: entry.widgetSize.height / 15))
                                    .foregroundColor(entry.darkMode ? .white : .black).bold()
                            }
                        }
                        if entry.balances != nil {
                            
                            Divider().background(Color(red: 30/255, green: 152/255, blue: 155/255))
                                .frame(width: entry.widgetSize.width * 0.96 - 10, height: 5, alignment: .center)
                                .padding(.top,0)
                            HStack(alignment: .top, spacing: 10) {
                                Image("income")
                                    .resizable()
                                    .frame(width: 18, height: 18, alignment: .center)
                                    .cornerRadius(5)
                                
                                HStack(alignment: .top, spacing: 10) {
                                    VStack(alignment: .center, spacing: 3) {
                                        ForEach(0..<3) { index in
                                            if entry.balances!.count > index {
                                                HStack(alignment: .top, spacing: 2) {
                                                    Text(entry.balances![index].value)
                                                        .font(.custom("", size:  entry.widgetSize.height / 15))
                                                        .foregroundColor( entry.darkMode ? .white : .black).bold()
                                                        .frame(width: entry.widgetSize.width / 4 , alignment: .leading)
                                                        .lineLimit(1)
                                                        .scaledToFit()
                                                        .minimumScaleFactor(0.8)
                                                    Text(entry.balances![index].type)
                                                        .font(.custom("", size: entry.widgetSize.height / 15))
                                                        .foregroundColor(entry.darkMode ? .white : .black).bold()
                                                        .frame(width:entry.widgetSize.width / 7 , alignment: .leading)
                                                        .lineLimit(1)
                                                        .scaledToFit()
                                                        .minimumScaleFactor(0.6)
                                                }
                                            }
                                        }
                                    }
                                    VStack(alignment: .center, spacing: 3) {
                                        ForEach(3..<6) { index in
                                            if entry.balances!.count > index {
                                                HStack(alignment: .top, spacing: 2) {
                                                    Text(entry.balances![index].value)
                                                        .font(.custom("", size:  entry.widgetSize.height / 15))
                                                        .foregroundColor( entry.darkMode ? .white : .black).bold()
                                                        .frame(width: entry.widgetSize.width / 4 , alignment: .leading)
                                                        .lineLimit(1)
                                                        .scaledToFit()
                                                        .minimumScaleFactor(0.8)
                                                    Text(entry.balances![index].type)
                                                        .font(.custom("", size: entry.widgetSize.height / 15))
                                                        .foregroundColor(entry.darkMode ? .white : .black).bold()
                                                        .frame(width:entry.widgetSize.width / 7 , alignment: .leading)
                                                        .lineLimit(1)
                                                        .scaledToFit()
                                                        .minimumScaleFactor(0.6)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    })
                    .offset(x:10)
                }
                .widgetURL(URL(string:entry.poolId == "" ? "minerbox://localhost/accounts" : "minerbox://localhost/accounts,\(entry.poolId)"))
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
                .offset(x: entry.widgetSize.width * 0.7,y: -(entry.widgetSize.height * 0.45))
            }
        }
    }
}

struct AccountBalance_Widget_Previews: PreviewProvider {
    static var previews: some View {
        AccountBalanceView(entry:  SingleAccountEntry(date: Date(), poolIcon: "", poolId: "", poolAccountName: "", poolTypeAndSubType: "", workersCount: 0, currentHashrate: "", darkMode: true, balance: Balance(value: "", type: ""), configurationForBalance: AccountBalanceConfigurationIntent(), isLogin: true, widgetSize: CGSize(width: 0, height: 0)))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

