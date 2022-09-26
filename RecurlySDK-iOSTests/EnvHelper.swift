//
//  EnvHelper.swift
//  RecurlySDK-iOSTests
//
//  Created by George Andrew Shoemaker on 9/12/22.
//

import Foundation

func getEnviornmentVar(_ name: String) -> String?{
    return ProcessInfo.processInfo.environment["PUBLIC_KEY"]
}
