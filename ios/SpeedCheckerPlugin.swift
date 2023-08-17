//
//  SpeedCheckerPlugin.swift
//  speedchecker_react_native_plugin
//
//  Created by Predrag Bogdanic on 8/16/23.
//

import Foundation
import SpeedcheckerSDK
import React
import CoreLocation

@objc(SpeedCheckerPlugin)
public class SpeedCheckerPlugin: RCTEventEmitter {
    private var locationManager = CLLocationManager()
    private var internetSpeedTest: InternetSpeedTest?
    
    private var server: SpeedTestServer?
    
    private var resultDict = [String: Any]()
    
    override init() {
        super.init()
        // TODO: - Remove this
        requestLocation()
    }
    
    // MARK: - RCTEventEmitter supported events
    public override func supportedEvents() -> [String]! {
        return Event.allCases.compactMap({ $0.rawValue })
    }
    
    // MARK: - Queue
    public override class func requiresMainQueueSetup() -> Bool {
        return true
    }
    
    // MARK: - Available methods
    
    @objc
    public func startTest() {
        resetServer()
        checkPermissionsAndStartTest()
    }
    
    @objc
    public func startTestWithTestType(_ testType: Int) {
        startTest()
    }
    
    @objc
    public func startTestWithCustomServer(_ dict: [String: Any]) {
        let server = SpeedTestServer(
            ID: dict["id"] as? Int,
            scheme: "https",
            domain: dict["domain"] as? String,
            downloadFolderPath: (dict["downloadFolderPath"] as? String)?.replacingOccurrences(of: "\\", with: ""),
            uploadFolderPath: (dict["uploadFolderPath"] as? String)?.replacingOccurrences(of: "\\", with: ""),
            uploadScript: "php",
            countryCode: dict["countryCode"] as? String,
            cityName: dict["city"] as? String
        )
        
        self.server = server
        checkPermissionsAndStartTest()
    }
    
    @objc
    public func stopTest() {
        internetSpeedTest?.forceFinish({ _ in
        })
    }
    
    // MARK: - Helpers
    private func sendErrorResult(_ error: SpeedTestError) {
        print(error.localizedDescription)
        let dict = ["error": error.localizedDescription]
        self.bridge.eventDispatcher().sendAppEvent(withName: Event.onTestStarted.rawValue, body: dict)
//        self.sendEvent(withName: Event.onTestStarted.rawValue, body: dict)
    }
    
    private func sendResultDict() {
        let dict = resultDict
        self.bridge.eventDispatcher().sendAppEvent(withName: Event.onTestStarted.rawValue, body: dict)
//        self.sendEvent(withName: Event.onTestStarted.rawValue, body: dict)
    }
    
    private func resetServer() {
        server = nil
    }
    
    private func checkPermissionsAndStartTest() {
        SCLocationHelper().locationServicesEnabled { locationEnabled in
            guard locationEnabled else {
                self.sendErrorResult(.locationUndefined)
                return
            }
            
            self.startSpeedTest()
        }
    }
    
    private func startSpeedTest() {
        internetSpeedTest = InternetSpeedTest(delegate: self)
        
        let onTestStart: (SpeedcheckerSDK.SpeedTestError) -> Void = { (error) in
            if error != .ok {
                self.sendErrorResult(error)
                self.resetServer()
            } else {
                self.resultDict = [
                    "status": "Speed test started",
                    "server": "",
                    "ping": 0,
                    "jitter": 0,
                    "downloadSpeed": 0,
                    "percent": 0,
                    "currentSpeed": 0,
                    "uploadSpeed": 0,
                    "connectionType": "",
                    "serverInfo": "",
                    "deviceInfo": "",
                    "downloadTransferredMb": 0,
                    "uploadTransferredMb": 0
                ]
                
                self.sendResultDict()
            }
        }
        
        if let server = server, !(server.domain ?? "").isEmpty {
            internetSpeedTest?.start([server], completion: onTestStart)
        } else {
            internetSpeedTest?.startTest(onTestStart)
        }
    }
    
    fileprivate func requestLocation() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.delegate = self
                self.locationManager.requestWhenInUseAuthorization()
                self.locationManager.requestAlwaysAuthorization()
            }
        }
    }
}

extension SpeedCheckerPlugin: InternetSpeedTestDelegate {
    public func internetTestError(error: SpeedcheckerSDK.SpeedTestError) {
        sendErrorResult(error)
        resetServer()
    }
    
    public func internetTestFinish(result: SpeedcheckerSDK.SpeedTestResult) {
        print(result.downloadSpeed.mbps)
        print(result.uploadSpeed.mbps)
        print(result.latencyInMs)
        resultDict["status"] = "Speed test finished"
        resultDict["server"] = result.server.domain
        resultDict["ping"] = result.latencyInMs
        resultDict["jitter"] = result.jitter
        resultDict["downloadSpeed"] = result.downloadSpeed.mbps
        resultDict["uploadSpeed"] = result.uploadSpeed.mbps
        resultDict["connectionType"] = result.connectionType
        resultDict["serverInfo"] = [result.server.cityName, result.server.country].compactMap({ $0 }).joined(separator: ", ")
        resultDict["deviceInfo"] = result.deviceInfo
        resultDict["downloadTransferredMb"] = result.downloadTransferredMb
        resultDict["uploadTransferredMb"] = result.uploadTransferredMb
        sendResultDict()
        resetServer()
    }
    
    public func internetTestReceived(servers: [SpeedcheckerSDK.SpeedTestServer]) {
        resultDict["status"] = "Ping"
        sendResultDict()
    }
    
    public func internetTestSelected(server: SpeedcheckerSDK.SpeedTestServer, latency: Int, jitter: Int) {
        print("Latency: \(latency)")
        print("Jitter: \(jitter)")
        resultDict["ping"] = latency
        resultDict["server"] = server.domain
        resultDict["jitter"] = jitter
        sendResultDict()
    }
    
    public func internetTestDownloadStart() {
        resultDict["status"] = "Download Test"
        sendResultDict()
    }
    
    public func internetTestDownloadFinish() {
    }
    
    public func internetTestDownload(progress: Double, speed: SpeedcheckerSDK.SpeedTestSpeed) {
        print("Download: \(speed.descriptionInMbps)")
        resultDict["status"] = "Download Test"
        resultDict["percent"] = Int(progress * 100)
        resultDict["currentSpeed"] = speed.mbps
        resultDict["downloadSpeed"] = speed.mbps
        sendResultDict()
    }
    
    public func internetTestUploadStart() {
        resultDict["status"] = "Upload Test"
        resultDict["currentSpeed"] = 0
        resultDict["percent"] = 0
        sendResultDict()
    }
    
    public func internetTestUploadFinish() {
    }
    
    public func internetTestUpload(progress: Double, speed: SpeedcheckerSDK.SpeedTestSpeed) {
        print("Upload: \(speed.descriptionInMbps)")
        resultDict["percent"] = Int(progress * 100)
        resultDict["currentSpeed"] = speed.mbps
        resultDict["uploadSpeed"] = speed.mbps
        sendResultDict()
    }
}

extension SpeedCheckerPlugin: CLLocationManagerDelegate {
}

private extension SpeedCheckerPlugin {
    enum Event: String, CaseIterable {
        case onTestStarted
    }
}

extension SpeedTestError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .ok:
            return "Ok"
        case .invalidSettings:
            return "Invalid settings"
        case .invalidServers:
            return "Invalid servers"
        case .inProgress:
            return "In progress"
        case .failed:
            return "Failed"
        case .notSaved:
            return "Not saved"
        case .cancelled:
            return "Cancelled"
        case .locationUndefined:
            return "Location undefined"
        @unknown default:
            return "Unknown"
        }
    }
}
