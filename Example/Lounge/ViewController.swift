//
//  ViewController.swift
//  Lounge
//
//  Created by Ysix on 01/19/2016.
//  Copyright (c) 2016 Ysix. All rights reserved.
//

import UIKit
import Lounge

class ViewController: LoungeViewController {

    override func loadView() {
        super.loadView()
        
        self.delegate = self
        self.dataSource = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: customizations
        setPlaceholder("Type here", color: UIColor.darkGray)
        setSeparatorColor(UIColor(red: 66/255.0, green: 122/255.0, blue: 185/255.0, alpha: 1))
//        setTopViewHeight(120) // only if you set a top View you can adjust it's height this way
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // demo only
    func fakeServerCallBack()
    {
        // simulate the call to the server for fetching new messages.
        self.newMessagesReceived(self.getMessagesAfter(self.lastMessageIdReceived()))
    }
    
    func getMessagesAfter(_ messageId: Int?) -> [LoungeMessageProtocol] // used for demo only
    {
        var msg = ChatMessage()
        
        if let msgId = messageId
        {
            msg.id = msgId + 1
            msg.text = "Ssshh, it's the quiet room !"
        }
        else
        {
            msg.id = 1
            msg.text = "Hi I'm Blackagar Boltagon, welcome to the quiet room."
        }
        
        if msg.id == 3 {
            self.displayAlert()
        }
        
        return [msg]
    }
    
    func displayAlert()
    {
        let alert = UIAlertController(title: "I said Ssshh!", message: "(This is for testing that the inputAccessoryView is still present when alert is fired)", preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        alert.addAction(dismissAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension ViewController : LoungeDataSource {
    
    func getLastMessages(_ limit: Int, completion : (_ messages: [LoungeMessageProtocol]?) -> ())
    {
        //TODO: fetch last messages from your server or local Datadase
        completion([])
    }
    
    func getOldMessages(_ limit: Int, beforeMessage: LoungeMessageProtocol, completion : (_ messages: [LoungeMessageProtocol]) -> ())
    {
        //TODO: fetch messages before "beforeMessage" from your server or local Database
        completion([])
    }
}

extension ViewController : LoungeDelegate {
    
    func cellForLoadMore(_ indexPath: IndexPath) -> UITableViewCell
    {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "LoadMoreCell", for: indexPath)
        return cell
    }
    
    func cellForMessage(_ message: LoungeMessageProtocol, indexPath: IndexPath, width: CGFloat) -> UITableViewCell
    {
        let msg = message as! ChatMessage
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: (msg.fromMe ? "MyMessageCell" : "OthersMessageCell"), for: indexPath) as! ChatMessageCell
        
        cell.textLB.text = msg.text
        
        return cell
    }
    
    func cellHeightForMessage(_ message: LoungeMessageProtocol, width: CGFloat) -> CGFloat
    {
        let msg = message as! ChatMessage
        let widthAvailableForText = width - 150 // we remove the size of constraints + space we want on the right or left of the bubble
        
        let textHeight = ceil(msg.text.boundingRect(with: CGSize(width: widthAvailableForText, height: 9999), options: [NSStringDrawingOptions.usesLineFragmentOrigin, NSStringDrawingOptions.usesFontLeading], attributes:[NSFontAttributeName: UIFont(name: MessageCellValues.labelFontName, size:  MessageCellValues.labelFontSize)!], context:nil).size.height)
        
        return textHeight + 30 // we add the size of our constraints
    }
    
    func messageFromText(_ text: String) -> LoungeMessageProtocol // given a text as String, you should return the appropriate object conform to LoungeMessageProtocol
    {
        var msg = ChatMessage()
        msg.text = text
        return msg
    }
    
    func sendNewMessage(_ message: LoungeMessageProtocol)
    {
        //TODO: send the message to your server
        
        // demo only
        self.perform("fakeServerCallBack", with: nil, afterDelay: 1)
    }
    
    // optionnal
    
    func keyBoardStateChanged(displayed: Bool) {
        
        if displayed
        {
            print("keyboard is up")
        }
        else
        {
            print("keyboard is down")
        }
    }
}

