import Foundation
import NetworkExtension
import LeafFFI

extension NEVPNStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .disconnected: return "Disconnected"
        case .invalid: return "Invalid"
        case .connected: return "Connected"
        case .connecting: return "Connecting"
        case .disconnecting: return "Disconnecting"
        case .reasserting: return "Reasserting"
        default: return "Unknowed"
        }
    }
}

public class VPNManager {
    public var manager = NETunnelProviderManager.shared()

    private static var sharedVPNManager: VPNManager = {
        return VPNManager()
    }()

    public class func shared() -> VPNManager {
        return sharedVPNManager
    }

    public init() {}
    
    public func getStatus() -> NEVPNStatus {
        return manager.connection.status
    }
    
    public func getConnectedDate() -> Date? {
        return manager.connection.connectedDate
    }

    public func loadVPNPreference(completion: @escaping (Error?) -> Void) {
        NETunnelProviderManager.loadAllFromPreferences() { managers, error in
            guard let managers = managers, error == nil else {
                completion(error)
                return
            }

            if managers.count == 0 {
                let newManager = NETunnelProviderManager()
                let proto = NETunnelProviderProtocol()
                
                newManager.localizedDescription = "Xlnt"
                proto.serverAddress = "192.168.0.1:9999"
                proto.providerBundleIdentifier = "com.xlnt.vpn.packettunnel"
                newManager.protocolConfiguration = proto
                newManager.saveToPreferences { error in
                    guard error == nil else {
                        completion(error)
                        return
                    }
                    newManager.loadFromPreferences { error in
                        self.manager = newManager
                        completion(nil)
                    }
                }
            } else {
                self.manager = managers[0]
                completion(nil)
            }
            print("loadVPNPreference \(self.manager.protocolConfiguration.debugDescription)")
        }
    }

    public func enableVPNManager(completion: @escaping (Error?) -> Void) {
        print("enableVPNManager")
        manager.isEnabled = true
        manager.saveToPreferences { error in
            guard error == nil else {
                completion(error)
                return
            }
            self.manager.loadFromPreferences { error in
                completion(error)
            }
        }
    }

    public func toggleVPNConnection(completion: @escaping (Error?) -> Void) {
        if self.manager.connection.status == .disconnected || self.manager.connection.status == .invalid {
            print("toggleVPNConnection")
            do {
                try self.manager.connection.startVPNTunnel()
            } catch {
                print("toggleVPNConnection err: \(error.localizedDescription)")
                completion(error)
            }
            print("toggleVPNConnection done")
        } else {
            self.manager.connection.stopVPNTunnel()
        }
    }
}
