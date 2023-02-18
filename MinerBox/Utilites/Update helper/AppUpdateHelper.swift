//
//  AppUpdateHelper.swift
//  MinerBox
//
//  Created by Sargis on 3/4/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

enum VersionError: Error {
    case invalidResponse, invalidBundleInfo
}

struct AppUpdateHelper {

    static func checkAndAskForUpdate(_ update: @escaping() -> Void) {
        AppUpdateHelper().requestUpdate {
            update()
        }
    }

    private func requestUpdate(_ updateTapped: @escaping() -> Void) {
        DispatchQueue.global().async {
            _ = try? self.isUpdateAvailable { (update, error) in
                if let error = error {
                    debugPrint(error.localizedDescription)
                } else if update != nil, update == true {
                    DispatchQueue.main.async {
                        self.handleOpenUrl {
                            updateTapped()
                        }
                    }
                }
            }
        }
    }

    private func handleOpenUrl(_ updateTapped: @escaping() -> Void) {
        guard Date().timeIntervalSince1970 > UserDefaults.standard.double(forKey: "laterTapped") else { return }

        let alertViewController = UpdateAppViewController(nibName: "UpdateAppViewController", bundle: nil)
        alertViewController.modalPresentationStyle = .overCurrentContext
        UIApplication.shared.keyWindow?.rootViewController?.present(alertViewController, animated: true, completion: nil)

        alertViewController.completionHandler = { tag in
            alertViewController.dismiss(animated: true, completion: {
                if tag == UpdateAppViewController.updateButtonTag {
                    UserDefaults.standard.set(0, forKey: "laterTapped")
                    updateTapped()
                } else if tag == UpdateAppViewController.laterButtonTag {
                    let now = Date().timeIntervalSince1970
                    let day: Double = 86400
                    let endTime = now + 3 * day
                    UserDefaults.standard.set(endTime, forKey: "laterTapped")
                }
            })
        }
    }

    private func isUpdateAvailable(completion: @escaping (Bool?, Error?) -> Void) throws -> URLSessionDataTask {
        guard let info = Bundle.main.infoDictionary,
            let currentVersion = info["CFBundleShortVersionString"] as? String,
            let identifier = info["CFBundleIdentifier"] as? String,
            let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(identifier)") else {
                throw VersionError.invalidBundleInfo
        }

        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringCacheData

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            do {
                if let error = error { throw error }
                guard let data = data else { throw VersionError.invalidResponse }
                let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any]
                guard let result = (json?["results"] as? [Any])?.first as? [String: Any], let version = result["version"] as? String else {
                    throw VersionError.invalidResponse
                }

                let comparision = self.compareVersions(appstore: version, current: currentVersion)
                if comparision == false {
                    UserDefaults.standard.set(0, forKey: "laterTapped")
                }
                completion(comparision, nil)
//                completion(true, nil)
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
        return task
    }

    func getVersionNumbers(version: String) -> [Int] {
        let numbers = version.components(separatedBy: ".").map { item in
            return Int(item)
        }
        var newNumbers = [Int]()
        guard numbers.contains(nil) == false else { return [] }
        newNumbers = numbers.map { ($0)! }

        return newNumbers
    }

    func compareVersions(appstore: String, current: String) -> Bool {
        var appStoreVersion = getVersionNumbers(version: appstore)
        var currentVersion = getVersionNumbers(version: current)

        if appStoreVersion.count < currentVersion.count {
            for _ in 0..<(currentVersion.count - appStoreVersion.count) {
                appStoreVersion.append(0)
            }
        }
        if currentVersion.count < appStoreVersion.count {
            for _ in 0..<(appStoreVersion.count - currentVersion.count) {
                currentVersion.append(0)
            }
        }
        let count = max(appStoreVersion.count, currentVersion.count)

        for i in 0...count - 1 {
            if appStoreVersion[i] == currentVersion[i] {
                continue
            }
            return appStoreVersion[i] > currentVersion[i]
        }

        return false
    }
}

fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value) })
}
