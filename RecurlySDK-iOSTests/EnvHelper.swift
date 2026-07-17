//
//  EnvHelper.swift
//  RecurlySDK-iOSTests
//

import Foundation

func getEnviornmentVar(_ name: String) -> String?{
    return ProcessInfo.processInfo.environment[name]
}
