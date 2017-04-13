//
//  LoungeProtocols.swift
//  Pods
//
//  Created by Eddy Claessens on 19/01/16.
//
//

import UIKit

public protocol LoungeMessageProtocol
{
    var id: Int { get set } // the id will be negatif for the user when the message is not yet sent to the server
    var fromMe : Bool { get set } // indicate that the message was sent from the current user or not
}

public protocol LoungeDelegate : NSObjectProtocol
{
    func cellForLoadMore(_ indexPath: IndexPath) -> UITableViewCell
    func cellForMessage(_ message: LoungeMessageProtocol, indexPath: IndexPath, width: CGFloat) -> UITableViewCell
    func cellHeightForMessage(_ message: LoungeMessageProtocol, width: CGFloat) -> CGFloat
    func messageFromText(_ text: String) -> LoungeMessageProtocol // given a text as String, you should return the appropriate object conform to ChatMessageProtocol
    func sendNewMessage(_ message: LoungeMessageProtocol)
    // optionnal
    func keyBoardStateChanged(displayed: Bool)
}

public extension LoungeDelegate
{
    func keyBoardStateChanged(displayed: Bool)
    {
        
    }
}

public protocol LoungeDataSource : NSObjectProtocol
{
    func getLastMessages(_ limit: Int, completion : (_ messages: [LoungeMessageProtocol]?) -> ())
    func getOldMessages(_ limit: Int, beforeMessage: LoungeMessageProtocol, completion : (_ messages: [LoungeMessageProtocol]) -> ())
}
