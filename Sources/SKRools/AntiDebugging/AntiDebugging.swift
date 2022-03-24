//
//  AntiDebugging.swift
//  
//
//  Created by Oscar Cardona on 20/3/22.
//  Copyright © 2020 Cardona.tv. All rights reserved.
//

import Foundation
import MachO

final class AntiDebugging {
    static let shared = AntiDebugging()
    
    func isDebuggerActive() -> Bool {
#if DEBUG
        return false
#else
        return amIBeingDebugged() || isDebuggerAttached() || checkDYLD() || checkSuspiciousFiles() || checkOpenedPorts()
#endif
    }
    
    private func amIBeingDebugged() -> Bool {
        var info = kinfo_proc()
        var size = MemoryLayout.stride(ofValue: info)
        var mib : [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        let junk = sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0)
        assert(junk == 0, "sysctl failed")
        
        return (info.kp_proc.p_flag & P_TRACED) != 0
    }
    
    private func isDebuggerAttached() -> Bool {
        return getppid() != 1
    }
}


// MARK: - Anti Frida

extension AntiDebugging {
    private func checkDYLD() -> Bool {
        let suspiciousLibraries = ["FridaGadget", "frida", "cynject", "libcycript"]
        
        for libraryIndex in 0..<_dyld_image_count() {
            guard let loadedLibrary = String(validatingUTF8: _dyld_get_image_name(libraryIndex)) else { continue }
            
            for suspiciousLibrary in suspiciousLibraries {
                if loadedLibrary.lowercased().contains(suspiciousLibrary.lowercased()) { return true }
            }
        }
        return false
    }
    
    private func checkSuspiciousFiles() -> Bool {
        let paths = ["/usr/sbin/frida-server"]
        
        for path in paths {
            if FileManager.default.fileExists(atPath: path) { return true }
        }
        return false
    }
    
    private func checkOpenedPorts() -> Bool {
        let ports = [27042, 4444]
        
        for port in ports {
            if canOpenLocalConnection(port: port) {
                return true
            }
        }
        return false
    }
    
    private func canOpenLocalConnection(port: Int) -> Bool {
        
        func swapBytesIfNeeded(port: in_port_t) -> in_port_t {
            let littleEndian = Int(OSHostByteOrder()) == OSLittleEndian
            return littleEndian ? _OSSwapInt16(port) : port
        }
        
        var serverAddress = sockaddr_in()
        serverAddress.sin_family = sa_family_t(AF_INET)
        serverAddress.sin_addr.s_addr = inet_addr("127.0.0.1")
        serverAddress.sin_port = swapBytesIfNeeded(port: in_port_t(port))
        
        let sock = socket(AF_INET, SOCK_STREAM, 0)
        let result = withUnsafePointer(to: &serverAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                connect(sock, $0, socklen_t(MemoryLayout<sockaddr_in>.stride))
            }
        }
        
        if result != -1 {
            return true
        } else {
            return false
        }
    }
}
