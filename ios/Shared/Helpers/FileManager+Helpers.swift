//
//  FileManager+Helpers.swift
//  PacketTunnel
//
//  Created by Jerry Bool on 2022/12/6.
//

import Foundation

extension FileManager {
    static var appGroupId = "group.com.xlnt.vpn"

    private var sharedFolderURL: URL? {
        let appGroupId = FileManager.appGroupId
        guard let sharedFolderURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupId) else {
            Logger.log("Cannot obtain shared folder URL", to: Logger.vpnLogFile)
            return nil
        }
        return sharedFolderURL
    }

    var vpnLogFile: URL? {
        sharedFolderURL?.appendingPathComponent("log")
    }

    var leafLogFile: URL? {
        sharedFolderURL?.appendingPathComponent("leaf.log")
    }

    var xrayAccessLogFile: URL? {
        sharedFolderURL?.appendingPathComponent("access.log")
    }
    var xrayErrorLogFile: URL? {
        sharedFolderURL?.appendingPathComponent("error.log")
    }
    
    var xrayConfFile: URL? {
        sharedFolderURL?.appendingPathComponent("conf.json")
    }

    var leafConfFile: URL? {
        sharedFolderURL?.appendingPathComponent("leaf.conf")
    }

    var leafConfTemplateFile: URL? {
        Bundle.main.url(forResource: "template", withExtension: "conf")
    }
    
    var leafSiteDataFile: URL? {
//        Bundle.main.url(forResource: "site", withExtension: "dat", subdirectory: "Shared")
        Bundle.main.url(forResource: "site", withExtension: "dat")
    }
}
