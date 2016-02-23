//
//  LoungeViewController.swift
//  Pods
//
//  Created by Eddy Claessens on 19/01/16.
//
//

import UIKit

public class LoungeViewController: UIViewController {

    // MARK: - Properties
    weak public var dataSource: LoungeDataSource? = nil
    weak public var delegate: LoungeDelegate? = nil
    
    var messageArray : [LoungeMessageProtocol] = [LoungeMessageProtocol]()
    var hasMoreToLoad = false
    var maxLoadedMessages = 20
    var tmpId = -1
    
    override public var inputAccessoryView: UIView? {
        get {
            return inputMessageView
        }
    }
    
    @IBOutlet weak var topView: UIView?
    @IBOutlet weak public var tableView: UITableView!
    @IBOutlet weak var inputMessageView: LoungeInputView!
    @IBOutlet weak var leftInputView: UIView?
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    let separator: UIView = UIView()
    
    
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint?
    var textViewTopPadding: NSLayoutConstraint?
    var textViewBottomPadding: NSLayoutConstraint?
    var textViewLeftPadding: NSLayoutConstraint?
    var textViewRightPadding: NSLayoutConstraint?
    var textviewHeightConstraint: NSLayoutConstraint?
    var buttonTopPadding: NSLayoutConstraint?
    var buttonBottomPadding: NSLayoutConstraint?
    var buttonRightPadding: NSLayoutConstraint?
    var placeholderLabel: UILabel?
    
    var sendButtonEnabled: Bool = true { // This let you manage the send button status (e.g.: when network connection is lost)
        didSet {
            if let sendButton = sendButton
            {
                if sendButton.enabled == true && sendButtonEnabled == false
                {
                    sendButton.enabled = false
                }
                
                if (sendButton.enabled == false && sendButtonEnabled == true)
                {
                    if textView.text.characters.count > 0
                    {
                        sendButton.enabled = true
                    }
                }
            }
        }
    }
    
    // MARK: - lifeCycle methods
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.Interactive
        tableView.delegate = self;
        tableView.dataSource = self;
        
        sendButton.enabled = false
        
        textView.delegate = self
        sendButton.addTarget(self, action: "sendClicked", forControlEvents: .TouchUpInside)
        
        if self.canBecomeFirstResponder() {
            self.becomeFirstResponder()
        }
        
        self.setConstraints()
        
        self.getLastMessages()
    }
    
    func getLastMessages()
    {
        dataSource!.getLastMessages(maxLoadedMessages) { messages in
            if let messages = messages
            {
                self.messageArray = messages
                if messages.count == self.maxLoadedMessages
                {
                    self.hasMoreToLoad = true
                }
                
                self.tableView.reloadData()
                self.scrollToLastCell(false)
            }
            else // error or no internet what do we do ?
            {
                let delayInSeconds = 1.0
                let time = dispatch_time(DISPATCH_TIME_NOW,
                    Int64(delayInSeconds * Double(NSEC_PER_SEC)))
                dispatch_after(time, dispatch_get_main_queue()) {
                    self.getLastMessages() // we call it again
                }
            }
        }
    }
    
    override public func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    func setConstraints() {
        
        // We need to keep the layout guide constraints so we don't delete all constraints but only those concerned by the selected views.
        var constraintsToRemove : [NSLayoutConstraint] = []
        var viewWeNeedToRemoveConstraints : [UIView] = [tableView, inputMessageView]
        if let topView = topView
        {
            viewWeNeedToRemoveConstraints.append(topView)
        }
        for constraint in self.view.constraints
        {
            if let firstItem = constraint.firstItem as? UIView, let secondItem = constraint.secondItem as? UIView
            {
                if viewWeNeedToRemoveConstraints.contains(firstItem) || viewWeNeedToRemoveConstraints.contains(secondItem)
                {
                    constraintsToRemove.append(constraint)
                }
            }
        }
        self.view.removeConstraints(constraintsToRemove)

        // pin topView
        if let viewTop = topView {
            self.view.pinSubview(viewTop, on: .Leading)
            self.view.setSpace(on: .Top, ofView: viewTop, fromView: self.topLayoutGuide)
            self.view.pinSubview(viewTop, on: .Trailing)
            self.view.setSpace(space: 0, on: .Bottom, ofView: viewTop, fromView: tableView)
        }
        else {
            self.view.setSpace(on: .Top, ofView: self.tableView, fromView: self.topLayoutGuide)
//            self.view.pinSubview(tableView, on: .Top)
        }
        
        // pin tableView
        self.view.pinSubview(tableView, on: .Leading)
        self.view.pinSubview(tableView, on: .Trailing)
        self.view.pinSubview(tableView, on: .Bottom)
        
        // input message view
        inputMessageView.removeFromSuperview()
        inputMessageView.removeConstraints(inputMessageView.constraints)
        
        // separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = UIColor.clearColor()
        inputMessageView.addSubview(separator)
        inputMessageView.pinSubview(separator, on: .Top)
        inputMessageView.pinSubview(separator, on: .Leading)
        inputMessageView.pinSubview(separator, on: .Trailing)
        separator.set(.Height, size: 0.5)
        
        // send button
        buttonRightPadding = inputMessageView.pinSubview(sendButton, on: .Trailing, space : 15)
        buttonTopPadding = inputMessageView.pinSubview(sendButton, on: .Top, relation: .GreaterThanOrEqual, space: 5)
        buttonBottomPadding = inputMessageView.pinSubview(sendButton, on: .Bottom, space : 5)
        sendButton.set(.Height, size: 35)

        
        // left input View
        if let leftViewMessage = leftInputView {
            inputMessageView.pinSubview(leftViewMessage, on: .Leading, space : 5)
            inputMessageView.pinSubview(leftViewMessage, on: .Top, relation: .GreaterThanOrEqual, space : 5)
            inputMessageView.pinSubview(leftViewMessage, on: .Bottom, space : 5)
            inputMessageView.setSpace(space: 5, on: .Trailing, ofView: leftViewMessage, fromView: textView)
        }
        else {
            textViewLeftPadding = inputMessageView.pinSubview(textView, on: .Leading, space: 15)
        }
        
        // textView
        textViewTopPadding = inputMessageView.pinSubview(textView, on: .Top, space : 5)
        textViewBottomPadding = inputMessageView.pinSubview(textView, on: .Bottom, space : 5)
        textViewRightPadding = inputMessageView.setSpace(space: 15, on: .Leading, ofView: sendButton, fromView: textView)
        textviewHeightConstraint = textView.set(.Height, size: 35)
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            tableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0)
            self.view.layoutIfNeeded()
            if keyboardSize.height > inputMessageView.frame.size.height {
                self.scrollToLastCell()
                delegate?.keyBoardStateChanged(displayed: true)
            }
            else
            {
                delegate?.keyBoardStateChanged(displayed: false)
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        self.view.layoutIfNeeded()
    }
    
    func scrollToLastCell(animated: Bool = true) {
        if tableView.numberOfRowsInSection(0) > 0 {
            let lastIndexPath = NSIndexPath(forRow: tableView.numberOfRowsInSection(0) - 1, inSection: 0)
            tableView.scrollToRowAtIndexPath(lastIndexPath, atScrollPosition: .Bottom, animated: animated)
        }
    }
    
    // MARK: - Internal Action methods
    
    func sendClicked() {
        let message = delegate!.messageFromText(textView.text)
        newMessage(message)
    }
    
    // MARK: - Methods for subclasses
    // MARK: Customization
    
    public func setTopViewHeight(height: CGFloat) {
        topViewHeightConstraint?.constant = height
        self.view.layoutIfNeeded()
    }
    
    
    public func setPlaceholder(text: String, color: UIColor = UIColor.lightGrayColor()) {
        if (placeholderLabel == nil) {
            self.placeholderLabel = UILabel()
            inputMessageView.addSubview(placeholderLabel!)
            placeholderLabel!.textColor = color
            placeholderLabel!.translatesAutoresizingMaskIntoConstraints = false
            placeholderLabel?.font = textView.font
            
            inputMessageView.align(placeholderLabel!, andTheView: textView, on: .Top, space:  textView.contentInset.top)
            inputMessageView.align(placeholderLabel!, andTheView: textView, on: .Bottom, space:  textView.contentInset.bottom)
            inputMessageView.align(placeholderLabel!, andTheView: textView, on: .Leading, space: 5)
        }
        
        placeholderLabel!.text = text
    }
    
    public func setSeparatorColor(color: UIColor) {
        separator.backgroundColor = color
    }
    
    public func setPadding(verticalPadding: CGFloat, horizontalPadding: CGFloat) {
        textViewTopPadding?.constant = verticalPadding
        textViewBottomPadding?.constant = verticalPadding
        textViewLeftPadding?.constant = horizontalPadding
        textViewRightPadding?.constant = horizontalPadding
        buttonTopPadding?.constant = verticalPadding
        buttonBottomPadding?.constant = verticalPadding
        buttonRightPadding?.constant = horizontalPadding
        self.view.layoutIfNeeded()
    }
    
    //MARK: Methods you may call
    
    public func newMessage(var newMessage: LoungeMessageProtocol) // call this when you want to send custom message (e.g. : picture), it's called automatically when send button is clicked
    {
        newMessage.id = tmpId
        newMessage.fromMe = true
        tmpId--
        delegate!.sendNewMessage(newMessage)
        
        messageArray.append(newMessage)
        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.messageArray.count - 1 + (self.hasMoreToLoad ? 1 : 0), inSection: 0)], withRowAnimation: .Bottom)
        
        textView.text = ""
        if let placeholderLB = placeholderLabel {
            placeholderLB.hidden = false
        }
        sendButton.enabled = false
        textviewHeightConstraint?.constant = 35
        self.inputAccessoryView?.layoutIfNeeded()
        self.reloadInputViews()
        self.scrollToLastCell()
    }
    
    //MARK: Methods you have to call
    
    public func lastMessageIdReceived() -> Int? // use this method to get the last message id received, typically used for fetching new messages (id > lastIdReceived)
    {
        var idMessage : Int? = nil
        var i = messageArray.count - 1
        
        while idMessage == nil && i >= 0
        {
            idMessage = messageArray[i].id
            if idMessage < 0
            {
                idMessage = nil
            }
            i--
        }
        return idMessage
    }
    
    // call this method when you did receive messages (this will be typically called by the dataSource)
    public func newMessagesReceived(messages: [LoungeMessageProtocol]?)
    {
        if let messages = messages
        {
            if messages.count > 0
            {
                let otherUserMessages : [LoungeMessageProtocol] = messages.filter({ message in
                    return message.fromMe == false
                })
                
                var newIndexPaths : [NSIndexPath] = []
                
                for message in otherUserMessages {
                    
                    self.messageArray.append(message)
                    newIndexPaths.append(NSIndexPath(forRow: self.messageArray.count - 1 + (self.hasMoreToLoad ? 1 : 0), inSection: 0))
                }
                
                if newIndexPaths.count > 0 {
                    self.tableView.insertRowsAtIndexPaths(newIndexPaths, withRowAnimation: .Bottom)
                    self.scrollToLastCell(true)
                }
            }
        }
    }
}

// MARK: - Delegates Methods
extension LoungeViewController: UITextViewDelegate {
    
    public func textViewDidChange(textView: UITextView) {
        
        if textView.text.characters.count > 0 {
            if let placeholderLB = placeholderLabel {
                
                placeholderLB.hidden = true
            }
            sendButton.enabled = sendButtonEnabled
        }
        else {
            if let placeholderLB = placeholderLabel {
                
                placeholderLB.hidden = false
            }
            sendButton.enabled = false
        }
        
        if textView.contentSize.height > 120 {
            textviewHeightConstraint?.constant = 120
        }
        else if textView.contentSize.height < 35 {
            textviewHeightConstraint?.constant = 35
        }
        else {
            textviewHeightConstraint?.constant = textView.contentSize.height
            textView.layoutIfNeeded()
            textView.scrollRangeToVisible(NSMakeRange(0, 0))
        }
        self.reloadInputViews()
    }
    
}


extension LoungeViewController: UITableViewDataSource {
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count + (hasMoreToLoad ? 1 : 0)
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if hasMoreToLoad && indexPath.row == 0
        {
            return delegate!.cellForLoadMore(indexPath)
        }
        
        let currentIndex = indexPath.row - (hasMoreToLoad ? 1 : 0)
        let message = messageArray[currentIndex]
        
        return delegate!.cellForMessage(message, indexPath: indexPath, width: tableView.frame.size.width)
    }
    
}

extension LoungeViewController: UITableViewDelegate {
    
    public func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return self.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        if hasMoreToLoad && indexPath.row == 0
        {
            return tableView.rowHeight
        }
        
        let currentIndex = indexPath.row - (hasMoreToLoad ? 1 : 0)
        return delegate!.cellHeightForMessage(messageArray[currentIndex], width: tableView.frame.size.width)
    }
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        checkToLoadMore()
    }
    
    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            checkToLoadMore()
        }
    }
    
    func checkToLoadMore() {
        if hasMoreToLoad && tableView.contentOffset.y == 0 {
            
            dataSource!.getOldMessages(maxLoadedMessages, beforeMessage: messageArray.first!, completion: { messages in
                
                var indexPaths : [NSIndexPath] = []
                
                var count = 1
                
                for message in messages {
                    self.messageArray.insert(message, atIndex: 0)
                    indexPaths.append(NSIndexPath(forRow: count, inSection: 0))
                    count++
                }
                
                let yOflastCell = self.tableView.rectForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)).origin.y
                
                if indexPaths.count > 0 {
                    UIView.setAnimationsEnabled(false)
                    self.tableView.beginUpdates()
                    self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
                    self.tableView.endUpdates()
                    UIView.setAnimationsEnabled(true)
                    
                    let newY = self.tableView.rectForRowAtIndexPath(NSIndexPath(forRow: count, inSection: 0)).origin.y - yOflastCell
                    
                    self.tableView.setContentOffset(CGPointMake(0, newY), animated: false)
                }
                
                if (messages.count < self.maxLoadedMessages)
                {
                    self.hasMoreToLoad = false
                    self.tableView.beginUpdates()
                    self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .None)
                    self.tableView.endUpdates()
                }
            })
        }
    }
}

extension UIView {
    
    func pinSubview(subview: UIView, on: NSLayoutAttribute, relation: NSLayoutRelation = .Equal, space : CGFloat = 0) -> NSLayoutConstraint {
        let constraint : NSLayoutConstraint = NSLayoutConstraint(item: (on == .Top || on == .Leading ? subview : self), attribute: on, relatedBy: relation, toItem: (on == .Top || on == .Leading ? self : subview), attribute: on, multiplier: 1, constant: space)
        
        self.addConstraint(constraint)
        
        return constraint
    }
    
    //    func pinOnTopLayoutGuide(subview: UIView, on: NSLayoutAttribute, viewController: UIViewController, space : CGFloat = 0) -> NSLayoutConstraint {
    //        let constraint : NSLayoutConstraint = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: viewController.topLayoutGuide, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: space)
    //
    //        self.addConstraint(constraint)
    //
    //        return constraint
    //    }
    
    func setSpace(relation: NSLayoutRelation = .Equal, space: CGFloat = 0, on: NSLayoutAttribute, ofView: UIView, fromView: AnyObject) -> NSLayoutConstraint {
        let oppositeSide: NSLayoutAttribute
        
        switch on {
        case .Top:
            oppositeSide = .Bottom
        case .Bottom:
            oppositeSide = .Top
        case .Leading:
            oppositeSide = .Trailing
        case .Trailing:
            oppositeSide = .Leading
        default:
            oppositeSide = on
        }
        
        let constraint : NSLayoutConstraint = NSLayoutConstraint(item: (on == .Top || on == .Leading ? ofView : fromView),
            attribute: (on == .Top || on == .Leading ? on : oppositeSide), relatedBy: relation,
            toItem: (on == .Top || on == .Leading ? fromView : ofView),
            attribute: (on == .Top || on == .Leading ? oppositeSide : on), multiplier: 1, constant: space)
        
        self.addConstraint(constraint)
        
        return constraint
    }
    
    func align(theView: UIView, andTheView: UIView, relation: NSLayoutRelation = .Equal, on: NSLayoutAttribute, space: CGFloat = 0) -> NSLayoutConstraint
    {
        let constraint : NSLayoutConstraint = NSLayoutConstraint(item: theView, attribute: on, relatedBy: relation, toItem: andTheView, attribute: on, multiplier: 1, constant: space)
        self.addConstraint(constraint)
        return constraint
    }
    
    func set(widthOrHeight: NSLayoutAttribute, relation: NSLayoutRelation = .Equal, size: CGFloat = 0) -> NSLayoutConstraint {
        let constraint : NSLayoutConstraint = NSLayoutConstraint(item: self, attribute: widthOrHeight, relatedBy: relation, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: size)
        self.addConstraint(constraint)
        return constraint
    }

}
