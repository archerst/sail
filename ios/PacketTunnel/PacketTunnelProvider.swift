import NetworkExtension
import LeafFFI
import Tun2SocksKit
import XrayKit
 extension MGConstant {
     static let cachesDirectory = URL(filePath: NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0])
 }

class PacketTunnelProvider: NEPacketTunnelProvider {

    private lazy var adapter: LeafAdapater = {
        LeafAdapater.setPacketTunnelProvider(with: self)
        return LeafAdapater.shared()
    }()

    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        NSLog("Starting tunnel with options: \(options ?? [:])")
        let ipv4 = NEIPv4Settings(addresses: ["198.18.20.20"], subnetMasks: ["255.255.255.0"])
        ipv4.includedRoutes = [NEIPv4Route.default()]

        let ipv6 = NEIPv6Settings(addresses: ["FD00::9999:9999"], networkPrefixLengths: [7])
        ipv6.includedRoutes = [NEIPv6Route.default()]

        let dns = NEDNSSettings(servers: ["8.8.8.8","114.114.114.114"])
        // https://developer.apple.com/forums/thread/116033
        // Mention special Tor domains here, so the OS doesn't drop onion domain
        // resolve requests immediately.
        dns.matchDomains = ["", "onion", "exit"]

        let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "198.18.20.200")
        settings.ipv4Settings = ipv4
        settings.ipv6Settings = ipv6
        settings.dnsSettings = dns
        settings.proxySettings = nil
        settings.mtu = 1500

        FileManager.default.leafLogFile?.truncate()

//        let fm = FileManager.default
//        let file = fm.leafConfFile
//        var conf = file?.contents ?? ""
//        NSLog("start leaf, original conf: \(conf)")
//        setenv("LOG_NO_COLOR", "true", 1)
//        self.adapter.start(completionHandler: completionHandler)
//        conf = file?.contents ?? ""
//        NSLog("start leaf, updated conf: \(conf)")
//        startXray()
        do {
            try startSocks5Tunnel(serverPort:10801)
        }catch{
            NSLog("startSocks5Tunnel exception")
        }
        
        XrayAdapater.shared().start{ error in
            if let error = error {
                Logger.log(error.localizedDescription, to: Logger.vpnLogFile)
            }
        }

        setTunnelNetworkSettings(settings) { error in
            if let error = error {
                return completionHandler(error)
            }

            completionHandler(nil)
        }
    }

    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        XrayAdapater.shared().stop{ error in
            if let error = error {
                Logger.log(error.localizedDescription, to: Logger.vpnLogFile)
            }

            completionHandler()
        }
//        self.adapter.stop { error in
//            if let error = error {
//                Logger.log(error.localizedDescription, to: Logger.vpnLogFile)
//            }
//
//            completionHandler()
//        }
    }

     private func startSocks5Tunnel(serverPort port: Int) throws{
         let config = """
         tunnel:
           mtu: 9000
         socks5:
           port: \(port)
           address: 127.0.0.1
           udp: 'udp'
         misc:
           task-stack-size: 20480
           connect-timeout: 5000
           read-write-timeout: 60000
           log-file: stderr
           log-level: error
           limit-nofile: 65535
         """
         let configurationFilePath = MGConstant.cachesDirectory.appending(component: "config.yml").path(percentEncoded: false)
         guard FileManager.default.createFile(atPath: configurationFilePath, contents: config.data(using: .utf8)!) else {
             NSLog("Tunnel 配置文件写入失败, \(configurationFilePath)")
             throw NSError.newError("Tunnel 配置文件写入失败")
         }
         DispatchQueue.global(qos: .userInitiated).async {
             NSLog("HEV_SOCKS5_TUNNEL_MAIN: \(Socks5Tunnel.run(withConfig: configurationFilePath))")
         }
     }
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        // Add code here to handle the message.
        if let handler = completionHandler {
            handler(messageData)
        }
    }

    override func sleep(completionHandler: @escaping () -> Void) {
        // Add code here to get ready to sleep.
        completionHandler()
    }

    override func wake() {
        // Add code here to wake up.
    }
}
