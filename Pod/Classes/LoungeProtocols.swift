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
    var idOfLastMessageReceived: Int? { get set } // use this var to know the last message id received, typically used for fetching new messages (id > idOfLastMessageReceived)

    func getLastMessages(_ limit: Int, completion: @escaping (_ messages: [LoungeMessageProtocol]?) -> ())
    func getOldMessages(_ limit: Int, beforeMessage: LoungeMessageProtocol, completion: @escaping (_ messages: [LoungeMessageProtocol]) -> ())
    func messageFromText(_ text: String) -> LoungeMessageProtocol // given a text as String, you should return the appropriate object conform to ChatMessageProtocol
    func sendNewMessage(_ message: LoungeMessageProtocol)
}
