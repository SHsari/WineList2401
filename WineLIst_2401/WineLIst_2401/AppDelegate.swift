//
//  AppDelegate.swift
//  WineLIst_2401
//
//  Created by Seokhyun Song on 1/2/24.
//

import UIKit

@main

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 임시파일 생성 옵션
        makeTmpFile()
        return true
    }
    
    private func makeTmpFile() {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let tmpFile = documentsDirectory.appendingPathComponent(".tmp")
        if !FileManager.default.fileExists(atPath: tmpFile.path) {
            FileManager.default.createFile(atPath: tmpFile.path, contents: nil, attributes: nil)
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }/*
    func fetchSelectedFileName() -> String? {
        // UserDefaults 인스턴스에서 'SelectedFileNameKey'를 키로 가진 값을 가져옵니다.
        let fileName = UserDefaults.standard.string(forKey: "SelectedFileNameKey")
        return fileName
    }*/


}

