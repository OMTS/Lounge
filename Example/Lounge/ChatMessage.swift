//
//  ChatMessage.swift
//  chatTemplateDemo
//
//  Created by Eddy Claessens on 16/12/15.
//  Copyright © 2015 OMTS. All rights reserved.
//

import Foundation
import Lounge

struct ChatMessage : LoungeMessageProtocol {
 
    var id: Int = 0
    var fromMe : Bool = false
    var text = ""
}