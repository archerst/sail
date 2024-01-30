//
//  LeafAdapter.swift
//  Runner
//
//  Created by Jerry Bool on 2022/12/7.
//

import Foundation
import NetworkExtension
import XrayKit
import os

public enum XrayAdapterError: Error {
    /// Failure to locate tunnel file descriptor.
    case cannotLocateTunnelFileDescriptor

    /// Failure to perform an operation in such state.
    case invalidState

    /// Failure to set network settings.
    case setNetworkSettings(Error)
    
    /// Failure to set tunnel configuration
    case setTunnelConfiguration(Int32)

    /// Failure to start Leaf FFI.
    case startXray
}

/// Enum representing internal state of the `LeafAdapter`
private enum State {
    /// The tunnel is stopped
    case stopped

    /// The tunnel is up and running
    case started

    /// The tunnel is temporarily shutdown due to device going offline
    case temporaryShutdown
}

private extension Network.NWPath.Status {
    /// Returns `true` if the path is potentially satisfiable.
    var isSatisfiable: Bool {
        switch self {
        case .requiresConnection, .satisfied:
            return true
        case .unsatisfied:
            return false
        @unknown default:
            return true
        }
    }
}

public class XrayAdapater {
    private let logger = os.Logger(subsystem: "com.xlnt.vpn", category: "Core")
    private static var sharedXrayAdapater: XrayAdapater = {
        return XrayAdapater()
    }()

    public class func shared() -> XrayAdapater {
        return sharedXrayAdapater
    }
    
    /// Leaf instance id
    public static let xrayId: UInt16 = 666
    
    /// Network routes monitor.
    private var networkMonitor: NWPathMonitor?
    
    /// Private queue used to synchronize access to `LeafAdapter` members.
    private let workQueue = DispatchQueue(label: "XrayAdapterWorkQueue")
    
    /// Adapter state.
    private var state: State = .stopped
    
    public func setRuntimeConfiguration(outBound: String?, completionHandler: @escaping (XrayAdapterError?) -> Void) {
        guard let outBound = outBound else {
            completionHandler(.startXray)
            return
        }
        
        
        let fm = FileManager.default

        let file = fm.xrayConfFile
        var conf = """
{
    "log": {
        "loglevel": "info",
        "access": "{{accessLogFile}}",
        "error": "{{errorLogFile}}"
    },
    "policy":{
        "levels": {
            "8": {
                "handshake": 4,
                "connIdle": 300,
                "uplinkOnly": 1,
                "downlinkOnly": 1
            }
        },
        "system": {
            "statsOutboundUplink": true,
            "statsOutboundDownlink": true
        }
    },
    "inbounds": [
        {
            "tag": "socks",
            "port": 10801,
            "protocol": "socks",
            "settings": {
                "auth": "noauth",
                "udp": true,
                "userLevel": 8
            },
            "sniffing": {
                "enabled": true,
                "destOverride": [
                    "http",
                    "tls"
                ]
            }
        }
    ],
    "outbounds": [
        {{outboundConf}},
        {
            "settings": {
                "domainStrategy": "UseIP",
                    "userLevel": 0
                },
                "protocol": "freedom",
                "tag": "direct"
            },
            {
                "settings": {
                    "response": {
                        "type": "none"
                    }
                },
                "tag": "block",
                    "protocol": "blackhole"
                }
    ],
    "dns": {},
    "routing": {
        "domainStrategy": "AsIs",
        "rules": [
        {
            "type": "field",
            "ip": [
                "geoip:private"
            ],
            "outboundTag": "direct"
        },
        {
            "type": "field",
            "domain": [
                "excellentconnect.com"
            ],
            "outboundTag": "direct"
        }
        ]
    },
    "transport": {}
    }
"""
        conf = conf
            .replacingOccurrences(of: "{{accessLogFile}}", with: fm.xrayAccessLogFile?.path ?? "")
            .replacingOccurrences(of: "{{errorLogFile}}", with: fm.xrayErrorLogFile?.path ?? "")
            .replacingOccurrences(of: "{{outboundConf}}", with: outBound)
        try! conf.write(to: file!, atomically: true, encoding: .utf8)
        
        conf = file?.contents ?? ""
        logger.debug("setRuntimeConfiguration: \(conf, privacy: .public)")
        completionHandler(nil)
    }
    
    /// Returns a runtime configuration.
    /// - Parameter completionHandler: completion handler.
    public func getRuntimeConfiguration(completionHandler: @escaping (String?) -> Void) {
        workQueue.async {
            let fm = FileManager.default

            if let conf = fm.xrayConfFile?.contents {
                completionHandler(conf)
            } else {
                completionHandler(nil)
            }
        }
    }
    
    /// Start the tunnel tunnel.
    /// - Parameters:
    ///   - tunnelConfiguration: tunnel configuration.
    ///   - completionHandler: completion handler.
    public func start(completionHandler: @escaping (LeafAdapterError?) -> Void) {
        workQueue.async {
            guard case .stopped = self.state else {
                completionHandler(.invalidState)
                return
            }
            
            // Reset log file.
            let fm = FileManager.default
            fm.xrayAccessLogFile?.truncate()
            fm.xrayErrorLogFile?.truncate()

            let confFile = fm.xrayConfFile
            let logFile = fm.xrayErrorLogFile
            let conf = confFile?.contents ?? ""
            NSLog("start xray, conf: \(conf)")
            
            setenv("LOG_NO_COLOR", "true", 1)

            XrayCore.run(config: confFile!, assets: Bundle.main.bundleURL, log: logFile!){ error in
            if let error = error {
                    // Present error
//                let fm = FileManager.default
//                let errlogFile = fm.xrayErrorLogFile
//                let accesslogFile = fm.xrayAccessLogFile
//                let errLog = errlogFile?.contents ?? "no content"
//                let accessLog = accesslogFile?.contents ?? "no content"
//                NSLog("xray errlog log: \(errLog)")
//                NSLog("xray accesslog log: \(accessLog)")
                }
            }
            
            let errlogFile = fm.xrayErrorLogFile
            let accesslogFile = fm.xrayAccessLogFile
            let errLog = errlogFile?.contents ?? "no content"
            let accessLog = accesslogFile?.contents ?? "no content"
            NSLog("xray errlog log: \(errLog)")
            NSLog("xray accesslog log: \(accessLog)")
            
            self.state = .started
            completionHandler(nil)
        }
    }
    
    /// Stop the tunnel.
    /// - Parameter completionHandler: completion handler.
    public func stop(completionHandler: @escaping (XrayAdapterError?) -> Void) {
        workQueue.async {
            switch self.state {
            case .started:
                XrayCore.quit()

            case .temporaryShutdown:
                break

            case .stopped:
                completionHandler(.invalidState)
                return
            }

            self.state = .stopped

            completionHandler(nil)
        }
    }
}
