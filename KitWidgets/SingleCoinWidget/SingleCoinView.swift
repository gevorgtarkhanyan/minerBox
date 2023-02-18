//
//  SingleCoinView.swift
//  KindWidgetsExtension
//
//  Created by Vazgen Hovakimyan on 30.08.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import WidgetKit
import SwiftUI
import Localize_Swift



struct SingleCoinView: View {
    
    var entry: SingleCoinProvider.Entry
    
    
    var body: some View {
        
        if !entry.isLogin! {
            
            ZStack {
                if entry.darkMode! {
                    
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
        } else  if entry.noSelectedCoin  {
            
            ZStack(alignment:.center) {
                if entry.darkMode! {
                    
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
                    .foregroundColor(entry.darkMode! ? .white : .black).bold()
                    .font(.system(size: 11))
                    .environment(\.locale, .init(identifier: UserDefaults(suiteName: "group.com.witplex.MinerBox")?.string(forKey: "appLanguage") ?? "en"))
                    .allowsTightening(true)
                    .lineLimit(2)
                    .scaledToFit()
                    .minimumScaleFactor(0.5)
                    .multilineTextAlignment(.center)
            }
            .widgetURL(URL(string:"minerbox://localhost")!)
        } else  {
            ZStack {
                if entry.darkMode! {
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
                VStack(alignment: .center,spacing: 5) {
                    VStack(alignment: .center,spacing: 6)  {
                        if entry.icon != "" {
                            let icon  = Constants.HttpUrlWithoutApi + "images/coins/" + entry.icon
                            Image(uiImage: icon.getImageWithURL())
                                .resizable()
                                .frame(width: 50, height: 50, alignment: .center)
                                .cornerRadius(10)
                        }
                        if entry.darkMode! {
                            Text(entry.name).font(.custom("", size: 15))
                                .foregroundColor(.white).bold()
                            Divider().background(Color(red: 30/255, green: 152/255, blue: 155/255))
                                .frame(width: entry.widgetSize.width * 0.85, height: 2, alignment: .center)
                                .padding(.top,0)
                            
                            Text(entry.marketPriceUSD)
                                .font(.title3)
                                .foregroundColor(.white)
                                .scaledToFit()
                                .minimumScaleFactor(0.8)
                        } else {
                            Text(entry.name).font(.custom("", size: 15))
                                .foregroundColor(.black)
                            Divider().background(Color(red: 30/255, green: 152/255, blue: 155/255))
                                .frame(width: entry.widgetSize.width * 0.85, height: 2, alignment: .center)
                                .padding(.top,0)
                            Text(entry.marketPriceUSD)
                                .font(.title3)
                                .foregroundColor(.black)
                        }
                    }
                    HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 12) {
                        
                        if entry.change1h < 0 {
                            Text(entry.change1h.removeZerosFromEnd() + "%")
                                .font(.custom("", size: 10))
                                .foregroundColor(.red)
                        } else {
                            Text(entry.change1h.removeZerosFromEnd() + "%")
                                .font(.custom("", size: 10))
                                .foregroundColor(.green)
                        }
                        if entry.change24h < 0 {
                            Text(entry.change24h.removeZerosFromEnd() + "%")
                                .font(.custom("", size: 10))
                                .foregroundColor(.red)
                        } else {
                            Text(entry.change24h.removeZerosFromEnd() + "%")
                                .font(.custom("", size: 10))
                                .foregroundColor(.green)
                        }
                        if entry.change7d < 0 {
                            Text(entry.change7d.removeZerosFromEnd() + "%")
                                .font(.custom("", size: 10))
                                .foregroundColor(.red)
                        } else {
                            Text(entry.change7d.removeZerosFromEnd() + "%")
                                .font(.custom("", size: 10))
                                .foregroundColor(.green)
                        }
                    }
                }
                ZStack {
                    Image("timeVertical")
                        .resizable()
                        .frame(width:  40, height: 20, alignment: .center)
                    Text(entry.date, style: .time)
                        .lineLimit(1)
                        .font(.system(size: 7))
                        .foregroundColor(.white)
                }
                .frame(width: entry.widgetSize.width, height: entry.widgetSize.width, alignment: .leading)
                .offset(x: entry.widgetSize.width * 0.65,y: -(entry.widgetSize.width * 0.44))
            }
            .widgetURL(URL(string:entry.id == "" ? "minerbox://localhost/coinprice,bitcoin" : "minerbox://localhost/coinprice,\(entry.id)"))
        }
    }
}

struct SingleCoinWidget_Previews: PreviewProvider {
    static var previews: some View {
        SingleCoinView(entry: SingleCoinWidgetEntry(date: Date(), icon: "", id: "", marketPriceUSD: "0", name: "", change1h: 0, change24h: 0, change7d: 0, darkMode: true, configuration: SingleCoinConfigurationIntent(), widgetSize: CGSize(width: 0, height: 0)))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
