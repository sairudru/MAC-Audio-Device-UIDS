//
//  main.swift
//  OBS_AUDIO_Devices
//
//  Created by Krishna, Rudru Sai on 05/04/23.
//

import Foundation
import CoreAudio


func getAudioDeviceIDs() -> [AudioDeviceID] {
    var propertyAddress = AudioObjectPropertyAddress(
        mSelector: kAudioHardwarePropertyDevices,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain
    )

    var deviceIDs: [AudioDeviceID] = []
    var dataSize: UInt32 = 0

    // get the size of the device ID array
    var status = AudioObjectGetPropertyDataSize(
        AudioObjectID(kAudioObjectSystemObject),
        &propertyAddress,
        0,
        nil,
        &dataSize
    )

    if status != noErr {
        print("Error getting device ID array size: \(status)")
        exit(1)
    }

    // get the device ID array
    let count = Int(dataSize) / MemoryLayout<AudioDeviceID>.size
    deviceIDs = [AudioDeviceID](repeating: 0, count: count)
    status = AudioObjectGetPropertyData(
        AudioObjectID(kAudioObjectSystemObject),
        &propertyAddress,
        0,
        nil,
        &dataSize,
        &deviceIDs
    )

    if status != noErr {
        print("Error getting device ID array: \(status)")
        exit(1)
    }

    return deviceIDs
}

func getAudioDeviceNamesAndUIDs(deviceIDs: [AudioDeviceID]) -> [(name: String, uid: String)] {
    var deviceNamesAndUIDs: [(name: String, uid: String)] = []
    for deviceID in deviceIDs {
        var deviceName: CFString = "" as CFString
        var dataSize = UInt32(MemoryLayout<CFString>.size)
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyDeviceNameCFString,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        let status = AudioObjectGetPropertyData(
            deviceID,
            &propertyAddress,
            0,
            nil,
            &dataSize,
            &deviceName
        )
        if status != noErr {
            print("Error getting device name: \(status)")
            deviceNamesAndUIDs.append((name: "", uid: ""))
        } else {
            var deviceUID: CFString = "" as CFString
            dataSize = UInt32(MemoryLayout<CFString>.size)
            propertyAddress = AudioObjectPropertyAddress(
                mSelector: kAudioDevicePropertyDeviceUID,
                mScope: kAudioObjectPropertyScopeGlobal,
                mElement: kAudioObjectPropertyElementMain
            )
            let status = AudioObjectGetPropertyData(
                deviceID,
                &propertyAddress,
                0,
                nil,
                &dataSize,
                &deviceUID
            )
            if status != noErr {
                print("Error getting device UID: \(status)")
                deviceNamesAndUIDs.append((name: deviceName as String, uid: ""))
            } else {
                deviceNamesAndUIDs.append((name: deviceName as String, uid: deviceUID as String))
            }
        }
    }
    return deviceNamesAndUIDs
}


func main() {
    let deviceIDs = getAudioDeviceIDs()
       let deviceNamesAndUIDs = getAudioDeviceNamesAndUIDs(deviceIDs: deviceIDs)
       for (_,device) in deviceNamesAndUIDs.enumerated() {
           print("Name:\(device.name)+UID:\(device.uid)")
       }

}
main()
