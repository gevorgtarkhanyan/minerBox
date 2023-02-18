//
//  SingleAccountView.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 24.09.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import WidgetKit
import SwiftUI
import Localize_Swift



struct SingleAccountView: View {
    
    var entry: SingleAccountProvider.Entry
    
    
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
                            .font(.system(size: entry.widgetSize.width / 10))
                            .environment(\.locale, .init(identifier: UserDefaults(suiteName: "group.com.witplex.MinerBox")?.string(forKey: "appLanguage") ?? "en"))
                            .frame(width: entry.widgetSize.width, height: entry.widgetSize.width / 2)
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
                            .font(.system(size: entry.widgetSize.width / 10))
                            .environment(\.locale, .init(identifier: UserDefaults(suiteName: "group.com.witplex.MinerBox")?.string(forKey: "appLanguage") ?? "en"))
                            .frame(width: entry.widgetSize.width, height: entry.widgetSize.width / 2)
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
        } else if entry.noSelectedAccount  {
            
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
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 5, content: {
                        
                        HStack(spacing: 10) {
                            IconView(entry: entry)
                                .frame(width: entry.widgetSize.width / 5, height: entry.widgetSize.width / 5)
                            VStack(alignment: .leading,spacing: 17) {
                                Text(entry.poolAccountName ?? "")
                                    .font(.system(size: entry.widgetSize.width / 10)).bold()
                                    .frame(width: entry.widgetSize.width * 0.60, height: 0, alignment: .leading)
                                    .foregroundColor(Color(red: 30/255, green: 152/255, blue: 155/255))
                                Text("\(entry.poolTypeAndSubType)")
                                    .foregroundColor(entry.darkMode ? .white : .black).bold()
                                    .frame(width: entry.widgetSize.width * 0.60, height: 0, alignment: .leading)
                                    .font(.system(size: entry.widgetSize.width / 10))
                                    .scaledToFit()
                                    .minimumScaleFactor(0.7)
                            }
                            .padding(.trailing)
                        }
                        
                        Divider().background(Color(red: 30/255, green: 152/255, blue: 155/255))
                            .frame(width: entry.widgetSize.width * 0.87, height: 10, alignment: .center)
                            .padding(.top,0)
                        
                    })
                    .offset(x:10,y:10)
                    
                    VStack(alignment: .leading,spacing: 6, content: {
                        
                        HStack(alignment: .center, spacing: 10) {
                            Image("hashrate_alert")
                                .resizable()
                                .frame(width: entry.widgetSize.width / 9, height: entry.widgetSize.width / 9, alignment: .center)
                                .cornerRadius(5)
                            Text(entry.currentHashrate)
                                .font(.custom("", size: entry.widgetSize.width / 11))
                                .foregroundColor(entry.darkMode ? .white : .black).bold()
                                .scaledToFit()
                                .minimumScaleFactor(0.8)
                        }
                        HStack(alignment: .center, spacing: 10) {
                            Image("worker_alert")
                                .resizable()
                                .frame(width: entry.widgetSize.width / 9, height: entry.widgetSize.width / 9, alignment: .center)
                                .cornerRadius(5)
                            if entry.workersCount != nil {
                                Text(entry.workersCount!.getFormatedString())
                                    .font(.custom("", size: entry.widgetSize.width / 11))
                                    .foregroundColor(entry.darkMode ? .white : .black).bold()
                            }
                        }
                        if entry.balance != nil {
                            HStack(alignment: .center, spacing: 10) {
                                Image("income")
                                    .resizable()
                                    .frame(width: entry.widgetSize.width / 9, height: entry.widgetSize.width / 9, alignment: .center)
                                    .cornerRadius(5)
                                HStack(alignment: .center, spacing: 1) {
                                    Text(entry.balance!.value)
                                        .font(.custom("", size: entry.widgetSize.width / 11))
                                        .foregroundColor(entry.darkMode ? .white : .black).bold()
                                        .frame(width: entry.widgetSize.width * 0.5 , alignment: .leading)
                                        .lineLimit(1)
                                        .scaledToFit()
                                        .minimumScaleFactor(0.8)
                                    Text(entry.balance!.type)
                                        .font(.custom("", size: entry.widgetSize.width / 11))
                                        .foregroundColor(entry.darkMode ? .white : .black).bold()
                                        .frame(width: entry.widgetSize.width * 0.2 , alignment: .leading)
                                        .lineLimit(1)
                                        .scaledToFit()
                                        .minimumScaleFactor(0.6)
                                }
                            }
                        }
                    })
                    .offset(x:10)
                }
                .widgetURL(URL(string:entry.poolId == "" ? "minerbox://localhost/accounts" : "minerbox://localhost/accounts,\(entry.poolId)"))
                ZStack(alignment: .center) {
                    Image("timeHorizontal")
                        .resizable()
                        .frame(width:  45, height: entry.widgetSize.width / 9.4, alignment: .center)
                    Text(entry.date, style: .time)
                        .lineLimit(1)
                        .font(.system(size: 8))
                        .foregroundColor(.white)
                }
                .frame(width:entry.widgetSize.width, height: entry.widgetSize.width, alignment: .trailing)
                .offset(x: 0,y: -(entry.widgetSize.width / 11) )
            } 
        }
    }
}

struct SingleAccount_Widget_Previews: PreviewProvider {
    static var previews: some View {
        SingleAccountView(entry:  SingleAccountEntry(date: Date(), poolIcon: "", poolId: "", poolAccountName: "", poolTypeAndSubType: "", workersCount: 0, currentHashrate: "", darkMode: true, balance: Balance(value: "", type: ""), configuration: SingleAccountConfigurationIntent(), isLogin: true, widgetSize: CGSize(width: 0, height: 0)))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
