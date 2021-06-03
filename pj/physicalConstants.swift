//
//  File.swift
//  pj
//
//  Created by mac12 on 2021/5/12.
//  Copyright © 2021 mac11. All rights reserved.
//

import Foundation
let playerCollisionMask = UInt32(0x1 << 1)
let wallCollisionMask = UInt32(0x1 << 2)
let bulletCollisionMask = UInt32(0x1 << 3)
let enemyCollisionMask = UInt32(0x1 << 4)
let puddleCollisionMask = UInt32(0x1 << 5)
let starPlayerCollisionMask = UInt32(0x1 << 6)
let teleportCollisionMask = UInt32(0x1 << 7)
