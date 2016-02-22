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
    func cellForLoadMore(indexPath: NSIndexPath) -> UITableViewCell
    func cellForMessage(message: LoungeMessageProtocol, indexPath: NSIndexPath, width: CGFloat) -> UITableViewCell
    func cellHeightForMessage(message: LoungeMessageProtocol, width: CGFloat) -> CGFloat
    func messageFromText(text: String) -> LoungeMessageProtocol // given a text as String, you should return the appropriate object conform to ChatMessageProtocol
    func sendNewMessage(message: LoungeMessageProtocol)
    // optionnal
    func keyBoardStateChanged(displayed displayed: Bool)
}

extension LoungeDelegate
{
    func keyBoardStateChanged(displayed displayed: Bool)
    {
        
    }
}

public protocol LoungeDataSource : NSObjectProtocol
{
    func getLastMessages(limit: Int, completion : (messages: [LoungeMessageProtocol]?) -> ())
    func getOldMessages(limit: Int, beforeMessage: LoungeMessageProtocol, completion : (messages: [LoungeMessageProtocol]) -> ())
}