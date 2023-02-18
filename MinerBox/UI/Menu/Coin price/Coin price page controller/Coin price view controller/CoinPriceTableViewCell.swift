//
//  CoinPriceTableViewCell.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 6/26/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
import SDWebImage

class CoinPriceTableViewCell: BaseTableViewCell {

    // MARK: - Views
    fileprivate var stackView: UIStackView!

    // Rank
    fileprivate var rankStack: UIStackView!
    fileprivate var logoImageView: UIImageView!
    fileprivate var rankLabel: BaseLabel!

    // Coin
    fileprivate var coinStack: UIStackView!
    fileprivate var coinSymbolLabel: BaseLabel!
    fileprivate var coinNameLabel: BaseLabel!

    // Price
    fileprivate var priceStack: UIStackView!
    fileprivate var priceValueLabel: BaseLabel!
    fileprivate var priceCapitalizationLabel: BaseLabel!

    // Change
    fileprivate var changeStack: UIStackView!
    fileprivate var hourLabel: UILabel!
    fileprivate var dayLabel: UILabel!
    fileprivate var weekLabel: UILabel!

    // MARK: - Properties
    fileprivate var indexPath: IndexPath = .zero
    let rates = UserDefaults.standard.value(forKey: "\(DatabaseManager.shared.currentUser?.id ?? "" )/rates") as? [String:Double]

    // MARK: - Static
    static var height: CGFloat = 60

    override func prepareForReuse() {
        super.prepareForReuse()
        logoImageView.image = nil
    }
}

// MARK: - Startup setup
extension CoinPriceTableViewCell {
    override func startupSetup() {
        super.startupSetup()
        setupUI()
    }
}

// MARK: - Setup UI
extension CoinPriceTableViewCell {
    func setupUI() {
        addStackView()

        addRankStack()
        addCoinStack()
        addPriceStack()
        addChangeStack()


        // Don't call this method if you whant to fill stack equaly
        changeStackSubviewSizes()
    }

    fileprivate func addStackView() {
        stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)

        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually

        stackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        stackView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.9).isActive = true

        if #available(iOS 11.0, *) {
            stackView.widthAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.widthAnchor, multiplier: 0.95).isActive = true
        } else {
            stackView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.95).isActive = true
        }
    }

    fileprivate func addRankStack() {
        // Add Stack for centering
        rankStack = UIStackView(frame: .zero)
        rankStack.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(rankStack)

        rankStack.alignment = .fill
        rankStack.axis = .horizontal
        rankStack.distribution = .fillEqually

        // View in stack
        let viewInStack = UIView(frame: .zero)
        viewInStack.translatesAutoresizingMaskIntoConstraints = false
        rankStack.addArrangedSubview(viewInStack)

        // Background for logo image
        let logoBackground = UIView(frame: .zero)
        logoBackground.translatesAutoresizingMaskIntoConstraints = false
        viewInStack.addSubview(logoBackground)

        logoBackground.clipsToBounds = true
        logoBackground.layer.cornerRadius = 5
        logoBackground.backgroundColor = .white

        logoBackground.addEqualRatioConstraint()
        logoBackground.centerXAnchor.constraint(equalTo: viewInStack.centerXAnchor).isActive = true
        logoBackground.centerYAnchor.constraint(equalTo: viewInStack.centerYAnchor).isActive = true

        // Logo
        logoImageView = UIImageView(frame: .zero)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoBackground.addSubview(logoImageView)

        logoImageView.clipsToBounds = true
        logoImageView.layer.cornerRadius = 5
        logoImageView.contentMode = .scaleAspectFit

        logoImageView.heightAnchor.constraint(equalToConstant: 31).isActive = true
        logoImageView.topAnchor.constraint(equalTo: logoBackground.topAnchor, constant: 1).isActive = true
        logoImageView.leftAnchor.constraint(equalTo: logoBackground.leftAnchor, constant: 1).isActive = true
        logoImageView.rightAnchor.constraint(equalTo: logoBackground.rightAnchor, constant: -1).isActive = true
        logoImageView.bottomAnchor.constraint(equalTo: logoBackground.bottomAnchor, constant: -1).isActive = true

        // Rank
        rankLabel = BaseLabel(frame: .zero)
        rankLabel.translatesAutoresizingMaskIntoConstraints = false
        rankStack.addArrangedSubview(rankLabel)

        rankLabel.textAlignment = .center
        rankLabel.changeFontSize(to: 13)
    }

    fileprivate func addCoinStack() {
        // Stack
        coinStack = UIStackView(frame: .zero)
        coinStack.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(coinStack)

        coinStack.axis = .vertical
        coinStack.alignment = .fill
        coinStack.distribution = .fillEqually

        // Symbol
        coinSymbolLabel = BaseLabel(frame: .zero)
        coinSymbolLabel.translatesAutoresizingMaskIntoConstraints = false
        coinStack.addArrangedSubview(coinSymbolLabel)

        coinSymbolLabel.changeFontSize(to: 17)
        coinSymbolLabel.textAlignment = .center

        // Name
        coinNameLabel = BaseLabel(frame: .zero)
        coinNameLabel.translatesAutoresizingMaskIntoConstraints = false
        coinStack.addArrangedSubview(coinNameLabel)

        coinNameLabel.changeFontSize(to: 11)
        coinNameLabel.textAlignment = .center
    }

    fileprivate func addPriceStack() {
        // Stack
        priceStack = UIStackView(frame: .zero)
        priceStack.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(priceStack)

        priceStack.axis = .vertical
        priceStack.alignment = .fill
        priceStack.distribution = .fillEqually

        // Symbol
        priceValueLabel = BaseLabel(frame: .zero)
        priceValueLabel.translatesAutoresizingMaskIntoConstraints = false
        priceStack.addArrangedSubview(priceValueLabel)

        priceValueLabel.changeFontSize(to: 13)
        priceValueLabel.textAlignment = .center

        // Name
        priceCapitalizationLabel = BaseLabel(frame: .zero)
        priceCapitalizationLabel.translatesAutoresizingMaskIntoConstraints = false
        priceStack.addArrangedSubview(priceCapitalizationLabel)

        priceCapitalizationLabel.changeFontSize(to: 11)
        priceCapitalizationLabel.textAlignment = .center
    }

    fileprivate func addChangeStack() {
        // Stack
        changeStack = UIStackView(frame: .zero)
        changeStack.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(changeStack)

        changeStack.axis = .vertical
        changeStack.alignment = .fill
        changeStack.distribution = .fillEqually

        for i in 0...2 {
            let stack = UIStackView(frame: .zero)
            stack.translatesAutoresizingMaskIntoConstraints = false
            changeStack.addArrangedSubview(stack)

            stack.axis = .horizontal
            stack.alignment = .fill
            stack.distribution = .fillEqually

            let keyLabel = BaseLabel(frame: .zero)
            keyLabel.translatesAutoresizingMaskIntoConstraints = false
            stack.addArrangedSubview(keyLabel)

            keyLabel.changeFontSize(to: 11)
            keyLabel.textAlignment = .center

            switch i {
            case 0:
                // Hour
                keyLabel.setLocalizableText("coin_price_change_1_hour")

                hourLabel = UILabel(frame: .zero)
                hourLabel.translatesAutoresizingMaskIntoConstraints = false
                stack.addArrangedSubview(hourLabel)

                hourLabel.font = Constants.regularFont.withSize(11)
                hourLabel.textAlignment = .center
                hourLabel.adjustsFontSizeToFitWidth = true
            case 1:
                // Day
                keyLabel.setLocalizableText("coin_price_change_24_hours")

                dayLabel = UILabel(frame: .zero)
                dayLabel.translatesAutoresizingMaskIntoConstraints = false
                stack.addArrangedSubview(dayLabel)

                dayLabel.font = Constants.regularFont.withSize(11)
                dayLabel.textAlignment = .center
                dayLabel.adjustsFontSizeToFitWidth = true
            case 2:
                // Week
                keyLabel.setLocalizableText("coin_price_change_7_days")

                weekLabel = UILabel(frame: .zero)
                weekLabel.translatesAutoresizingMaskIntoConstraints = false
                stack.addArrangedSubview(weekLabel)

                weekLabel.font = Constants.regularFont.withSize(11)
                weekLabel.textAlignment = .center
                weekLabel.adjustsFontSizeToFitWidth = true
            default:
                continue
            }
        }
    }

    fileprivate func changeStackSubviewSizes() {
        stackView.distribution = .fill
        rankStack.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.2).isActive = true
        coinStack.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.25).isActive = true
        priceStack.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.3).isActive = true
        changeStack.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.25).isActive = true
    }
}

// MARK: - Set data
extension CoinPriceTableViewCell {
    public func setData(coin: CoinModel, indexPath: IndexPath) {
        self.indexPath = indexPath
//        let coinIconPath = Constants.HttpUrlWithoutApi + "images/coins/" + coin.icon
        logoImageView.tag = indexPath.row
        logoImageView.sd_setImage(with: URL(string: coin.iconPath), placeholderImage: UIImage(named: "empty_coin"))

        rankLabel.setLocalizableText("\(coin.rank)")
        coinSymbolLabel.setLocalizableText(coin.symbol)
        coinNameLabel.setLocalizableText(coin.name)

        priceValueLabel.setLocalizableText(Locale.appCurrencySymbol + " " + (coin.marketPriceUSD * (rates?[Locale.appCurrency] ?? 1.0)).getString() )
        priceCapitalizationLabel.setLocalizableText(Locale.appCurrencySymbol + " " + (coin.marketCapUsd * (rates?[Locale.appCurrency] ?? 1.0)).formatUsingAbbrevation())
       
        configChangeLabels(coin: coin)
    }
}

// MARK: - Actions
extension CoinPriceTableViewCell {
    fileprivate func configChangeLabels(coin: CoinModel) {
        let hour = coin.change1h
        hourLabel.text = hour < 0 ? "\(hour)%" : "+\(hour)%"
        hourLabel.textColor = hour < 0 ? .workerRed : .workerGreen

        let day = coin.change24h
        dayLabel.text = day < 0 ? "\(day)%" : "+\(day)%"
        dayLabel.textColor = day < 0 ? .workerRed : .workerGreen

        let week = coin.change7d
        weekLabel.text = week < 0 ? "\(week)%" : "+\(week)%"
        weekLabel.textColor = week < 0 ? .workerRed : .workerGreen
    }
}
