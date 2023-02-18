//
//  MultiCoinWidgetView.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 28.09.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import WidgetKit
import SwiftUI
import Localize_Swift



struct MultiCoinView: View {
    
    var entry: MultiCoinProvider.Entry
    
    var body: some View {
        
        ZStack {
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
            
            if !entry.isLogin {
                Text("login_login")
                    .foregroundColor(entry.darkMode ? .white : .black).bold()
                    .padding()
                    .environment(\.locale, .init(identifier: UserDefaults(suiteName: "group.com.witplex.MinerBox")?.string(forKey: "appLanguage") ?? "en"))
                
                
                    .widgetURL(URL(string:"minerbox://localhost/login")!)
            } else  if entry.noSelectedCoins  {
                
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
                .widgetURL(URL(string:"minerbox://localhost")!) }
            else {
                ZStack {
                    Image("timeVertical")
                        .resizable()
                        .frame(width:  entry.widgetSize.width / 7, height: entry.widgetSize.width / 14, alignment: .center)
                    Text(entry.date, style: .time)
                        .lineLimit(1)
                        .font(.system(size: entry.widgetSize.width / 38))
                        .foregroundColor(.white)
                        .widgetURL(URL(string:"minerbox://localhost/coinprice")!)
                }
                .frame(width: entry.widgetSize.width, height: entry.widgetSize.height, alignment: .leading)
                .offset(x: entry.widgetSize.width * 0.6,y: -(entry.widgetSize.height * 0.47))
                VStack (alignment: .center, spacing: 2) {
                    ForEach(entry.coins, id: \.self) { ( coin: SingleCoinForMulti ) in
                        Link(destination: URL(string:coin.id == "" ? "minerbox://localhost/coinprice,bitcoin" : "minerbox://localhost/coinprice,\(coin.id)")!, label: {
                            
                            HStack(alignment: .center, spacing: 5) {
                                VStack(alignment: .center,spacing: 5) {
                                    HStack {
                                        if coin.icon != "" {
                                            let icon  = Constants.HttpUrlWithoutApi + "images/coins/" + coin.icon
                                            Image(uiImage: icon.getImageWithURL())
                                                .resizable()
                                                .frame(width: entry.widgetSize.width / 12, height: entry.widgetSize.width / 12)
                                                .cornerRadius(5)
                                        }
                                        LazyVStack(alignment: .leading,spacing: 15) {
                                            Text(coin.name)
                                                .font(.system(size: entry.widgetSize.width / 25)).bold()
                                                .frame(width: entry.widgetSize.width * 0.3, height: 5, alignment: .leading)
                                                .foregroundColor(Color(red: 30/255, green: 152/255, blue: 155/255))
                                                .scaledToFit()
                                                .minimumScaleFactor(0.8)
                                            Text(coin.symbol)
                                                .foregroundColor(entry.darkMode ? .white : .black).bold()
                                                .frame(width: entry.widgetSize.width * 0.3, height: 5, alignment: .leading)
                                                .font(.system(size: entry.widgetSize.width / 25))
                                                .scaledToFit()
                                                .minimumScaleFactor(0.8)
                                        }
                                    }
                                }
                                Spacer(minLength: 0)
                                Text(coin.marketPriceUSD)
                                    .font(.system(size: entry.widgetSize.width / 16))
                                    .frame(width: entry.widgetSize.width * 0.40, height: 0)
                                    .foregroundColor(entry.darkMode ? .white : .black)
                                    .scaledToFit()
                                    .minimumScaleFactor(0.7)
                                HStack(spacing: 0) {
                                    VStack(alignment: .trailing,spacing: entry.widgetSize.width / 20) {
                                        Text("1h")
                                            .font(.system(size: entry.widgetSize.width / 30))
                                            .foregroundColor(entry.darkMode ? .white : .black)
                                            .frame(width: entry.widgetSize.width * 0.08, height: 0, alignment: .trailing)
                                        Text("24h")
                                            .foregroundColor(entry.darkMode ? .white : .black)
                                            .frame(width: entry.widgetSize.width * 0.08, height: 0, alignment: .trailing)
                                            .font(.system(size: entry.widgetSize.width / 30))
                                        Text("1w")
                                            .foregroundColor(entry.darkMode ? .white : .black)
                                            .frame(width: entry.widgetSize.width * 0.08, height: 0, alignment: .trailing)
                                            .font(.system(size: entry.widgetSize.width / 30))
                                    }
                                    VStack(alignment: .trailing,spacing: entry.widgetSize.width / 20) {
                                        
                                        Text(coin.change1h.removeZerosFromEnd() + "%")
                                            .font(.system(size: entry.widgetSize.width / 29)).bold()
                                            .frame(width: entry.widgetSize.width * 0.2, height: 0, alignment: .center)
                                            .foregroundColor( coin.change1h < 0 ? .red : .green)
                                        Text(coin.change24h.removeZerosFromEnd() + "%")
                                            .foregroundColor(coin.change24h < 0 ? .red : .green).bold()
                                            .frame(width: entry.widgetSize.width * 0.2, height: 0, alignment: .center)
                                            .font(.system(size: entry.widgetSize.width / 29))
                                        
                                        Text(coin.change7d.removeZerosFromEnd() + "%")
                                            .foregroundColor(coin.change7d < 0 ? .red : .green).bold()
                                            .frame(width: entry.widgetSize.width * 0.2, height: 0, alignment: .center)
                                            .font(.system(size: entry.widgetSize.width / 29))
                                    }
                                }
                            }
                            .padding(.init(top: 5, leading: 10, bottom: 5, trailing: 0 ))
                            if coin.numberCoin < entry.coins.count {
                                Divider().background(Color(red: 30/255, green: 152/255, blue: 155/255))
                                    .frame(width: entry.widgetSize.width * 0.96, height: 10, alignment: .center)
                                    .padding(.init(top: 5, leading: 0, bottom: 5, trailing: 0))
                            }
                        })
                    }
                }
            }
        }
    }
}

struct MultiCoinWidget_Previews: PreviewProvider {
    static var previews: some View {
        MultiCoinView(entry: MultiCoinWidgetEntry(date: Date(), configuration: MultiCoinConfigurationIntent(), widgetSize: CGSize(width: 150, height: 150)))
    }
}
