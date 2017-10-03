//
//  LoungeViewController.swift
//  Pods
//
//  Created by Eddy Claessens on 19/01/16.
//
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


open class LoungeViewController: UIViewController {

    // MARK: - Properties
    
    //data
    weak open var dataSource: LoungeDataSource? = nil
    weak open var delegate: LoungeDelegate? = nil
    
    var messageArray : [LoungeMessageProtocol] = [LoungeMessageProtocol]() {
        didSet {
            
            if let emptyStateView = emptyStateView
            {
                if oldValue.count == 0 && messageArray.count > 0
                {
                    // hide empty state
                    tableView.alpha = 0
                    tableView.isHidden = false
                    UIView.animate(withDuration: 0.2, animations: { () -> Void in
                        emptyStateView.alpha = 0
                        self.tableView.alpha = 1
                        }, completion: { (terminated) -> Void in
                            emptyStateView.isHidden = true
                            emptyStateView.alpha = 1
                    })
                }
                else if oldValue.count > 0 && messageArray.count == 0
                {
                    // display empty state
                    emptyStateView.alpha = 0
                    emptyStateView.isHidden = false
                    UIView.animate(withDuration: 0.2, animations: { () -> Void in
                        emptyStateView.alpha = 1
                        self.tableView.alpha = 0
                        }, completion: { (terminated) -> Void in
                            self.tableView.isHidden = true
                            self.tableView.alpha = 1
                    })
                }
            }
        }
    }
    var hasMoreToLoad = false
    var maxLoadedMessages = 20
    var tmpId = -1
    
    override open var inputAccessoryView: UIView? {
        get {
            return inputMessageView
        }
    }

    /// This let you manage the send button status (e.g.: when network connection is lost)
    open var sendButtonEnabled: Bool = true {
        didSet {
            if let sendButton = sendButton
            {
                sendButton.isEnabled = textView.text.characters.count > 0 && sendButtonEnabled
            }
        }
    }
    
    //views
    @IBOutlet weak var topView: UIView?
    @IBOutlet weak var emptyStateView: UIView?
    @IBOutlet weak open var tableView: UITableView!
    @IBOutlet weak var inputMessageView: LoungeInputView!
    @IBOutlet weak var leftInputView: UIView?
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    let separator: UIView = UIView()
    var placeholderLabel: UILabel?
    
    //constraints
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint?
    var textViewTopPadding: NSLayoutConstraint?
    var textViewBottomPadding: NSLayoutConstraint?
    var textViewLeftPadding: NSLayoutConstraint?
    var textViewRightPadding: NSLayoutConstraint?
    var textviewHeightConstraint: NSLayoutConstraint?
    var buttonTopPadding: NSLayoutConstraint?
    var buttonBottomPadding: NSLayoutConstraint?
    var buttonRightPadding: NSLayoutConstraint?
    var emptyStateBottomConstraint: NSLayoutConstraint?
    
    // MARK: - lifeCycle methods
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.interactive
        tableView.delegate = self
        tableView.dataSource = self
        
        if let emptyStateView = emptyStateView
        {
            tableView.isHidden = true
            emptyStateView.isHidden = false
        }
        
        sendButton.isEnabled = false
        
        textView.delegate = self
        sendButton.addTarget(self, action: #selector(LoungeViewController.sendClicked), for: .touchUpInside)
        
        if self.canBecomeFirstResponder {
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
                self.updateIdOfLastMessageReceived()
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
                let time = DispatchTime.now() + Double(Int64(delayInSeconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: time) {
                    self.getLastMessages() // we call it again
                }
            }
        }
    }
    
    override open var canBecomeFirstResponder : Bool {
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
            _ = self.view.pinSubview(viewTop, on: .leading)
            _ = self.view.setSpace(on: .top, ofView: viewTop, fromView: self.topLayoutGuide)
            _ = self.view.pinSubview(viewTop, on: .trailing)
            _ = self.view.setSpace(space: 0, on: .bottom, ofView: viewTop, fromView: tableView)
        }
        else {
            _ = self.view.setSpace(on: .top, ofView: self.tableView, fromView: self.topLayoutGuide)
//            self.view.pinSubview(tableView, on: .Top)
        }
        
        // pin tableView
        _ = self.view.pinSubview(tableView, on: .leading)
        _ = self.view.pinSubview(tableView, on: .trailing)
        _ = self.view.pinSubview(tableView, on: .bottom)
        
        // input message view
        inputMessageView.removeFromSuperview()
        inputMessageView.removeConstraints(inputMessageView.constraints)
        
        // separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = UIColor.clear
        inputMessageView.addSubview(separator)
        _ = inputMessageView.pinSubview(separator, on: .top)
        _ = inputMessageView.pinSubview(separator, on: .leading)
        _ = inputMessageView.pinSubview(separator, on: .trailing)
        _ = separator.set(.height, size: 0.5)
        
        // send button
        buttonRightPadding = inputMessageView.pinSubview(sendButton, on: .trailing, space : 15)
        buttonTopPadding = inputMessageView.pinSubview(sendButton, on: .top, relation: .greaterThanOrEqual, space: 5)
        buttonBottomPadding = inputMessageView.pinSubview(sendButton, on: .bottom, space : 5)
        if sendButton.constraints.count == 0 {
            _ = sendButton.set(.height, size: 35)
        }

        
        // left input View
        if let leftViewMessage = leftInputView {
            _ = inputMessageView.pinSubview(leftViewMessage, on: .leading, space : 5)
            _ = inputMessageView.pinSubview(leftViewMessage, on: .top, relation: .greaterThanOrEqual, space : 5)
            _ = inputMessageView.pinSubview(leftViewMessage, on: .bottom, space : 5)
            _ = inputMessageView.setSpace(space: 5, on: .trailing, ofView: leftViewMessage, fromView: textView)
        }
        else {
            textViewLeftPadding = inputMessageView.pinSubview(textView, on: .leading, space: 15)
        }
        
        // textView
        textViewTopPadding = inputMessageView.pinSubview(textView, on: .top, space : 5)
        textViewBottomPadding = inputMessageView.pinSubview(textView, on: .bottom, space : 5)
        textViewRightPadding = inputMessageView.setSpace(space: 15, on: .leading, ofView: sendButton, fromView: textView)
        textviewHeightConstraint = textView.set(.height, size: 35)
        textviewHeightConstraint?.priority = 999
        
        // empty state view
        if let emptyStateView = emptyStateView {
            _ = self.view.align(emptyStateView, andTheView: tableView, on: .top)
            emptyStateBottomConstraint = self.view.align(emptyStateView, andTheView: tableView, on: .bottom)
            _ = self.view.align(emptyStateView, andTheView: tableView, on: .right)
            _ = self.view.align(emptyStateView, andTheView: tableView, on: .left)
        }
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoungeViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoungeViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoungeViewController.keyboardDidHide(_:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func keyboardWillShow(_ notification: Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let height = keyboardSize.height - (tabBarController?.tabBar.bounds.size.height ?? 0)
            tableView.contentInset = UIEdgeInsetsMake(0, 0, height, 0)
            emptyStateBottomConstraint?.constant = -height
            self.view.layoutIfNeeded()
            if height > inputMessageView.frame.size.height {
                self.scrollToLastCell()
                delegate?.keyBoardStateChanged(displayed: true)
            }
            else
            {
                delegate?.keyBoardStateChanged(displayed: false)
            }
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        self.view.layoutIfNeeded()
    }
    
    func keyboardDidHide(_ notification: Notification) {
        self.becomeFirstResponder()
    }
    
    func scrollToLastCell(_ animated: Bool = true) {
        if tableView.numberOfRows(inSection: 0) > 0 {
            let lastIndexPath = IndexPath(row: tableView.numberOfRows(inSection: 0) - 1, section: 0)
            tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: animated)
        }
    }

    func updateIdOfLastMessageReceived()
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
            i -= 1
        }
        dataSource?.idOfLastMessageReceived = idMessage
    }

    // MARK: - Internal Action methods
    
    open func sendClicked() {
        let message = dataSource!.messageFromText(textView.text)
        newMessage(message)
    }
    
    // MARK: - Methods for subclasses
    // MARK: Customization
    
    open func setTopViewHeight(_ height: CGFloat) {
        topViewHeightConstraint?.constant = height
        self.view.layoutIfNeeded()
    }
    
    
    open func setPlaceholder(_ text: String, color: UIColor = UIColor.lightGray) {
        if (placeholderLabel == nil) {
            self.placeholderLabel = UILabel()
            inputMessageView.addSubview(placeholderLabel!)
            placeholderLabel!.textColor = color
            placeholderLabel!.translatesAutoresizingMaskIntoConstraints = false
            placeholderLabel?.font = textView.font
            
            _ = inputMessageView.align(placeholderLabel!, andTheView: textView, on: .top, space:  textView.contentInset.top)
            _ = inputMessageView.align(placeholderLabel!, andTheView: textView, on: .bottom, space:  textView.contentInset.bottom)
            _ = inputMessageView.align(placeholderLabel!, andTheView: textView, on: .leading, space: 5)
        }
        
        placeholderLabel!.text = text
    }
    
    open func setSeparatorColor(_ color: UIColor) {
        separator.backgroundColor = color
    }
    
    open func setPadding(_ verticalPadding: CGFloat, horizontalPadding: CGFloat) {
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
    
    public func newMessage(_ newMessage: LoungeMessageProtocol) // call this when you want to send custom message (e.g. : picture), it's called automatically when send button is clicked
    {
        var newMessage = newMessage
        newMessage.id = tmpId
        newMessage.fromMe = true
        tmpId -= 1
        dataSource!.sendNewMessage(newMessage)
        
        messageArray.append(newMessage)
        self.tableView.insertRows(at: [IndexPath(row: self.messageArray.count - 1 + (self.hasMoreToLoad ? 1 : 0), section: 0)], with: .bottom)
        
        textView.text = ""
        if let placeholderLB = placeholderLabel {
            placeholderLB.isHidden = false
        }
        sendButton.isEnabled = false
        textviewHeightConstraint?.constant = 35
        self.inputAccessoryView?.layoutIfNeeded()
        self.reloadInputViews()
        self.scrollToLastCell()
    }
    
    //MARK: Methods you have to call
    
    // call this method when you did receive messages (this will be typically called by the dataSource)
    open func newMessagesReceived(_ messages: [LoungeMessageProtocol])
    {
        guard messages.count > 0 else {
            return
        }

        let otherUserMessages : [LoungeMessageProtocol] = messages.filter({ message in
            return message.fromMe == false
        })

        var newIndexPaths : [IndexPath] = []

        for message in otherUserMessages {

            self.messageArray.append(message)
            newIndexPaths.append(IndexPath(row: self.messageArray.count - 1 + (self.hasMoreToLoad ? 1 : 0), section: 0))
        }
        updateIdOfLastMessageReceived()

        if newIndexPaths.count > 0 {
            self.tableView.insertRows(at: newIndexPaths, with: .bottom)
            self.scrollToLastCell(true)
        }
    }
}

// MARK: - Delegates Methods
extension LoungeViewController: UITextViewDelegate {

    public func textViewDidChange(_ textView: UITextView) {
        
        if textView.text.characters.count > 0 {
            if let placeholderLB = placeholderLabel {
                
                placeholderLB.isHidden = true
            }
            sendButton.isEnabled = sendButtonEnabled
        }
        else {
            if let placeholderLB = placeholderLabel {
                
                placeholderLB.isHidden = false
            }
            sendButton.isEnabled = false
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
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count + (hasMoreToLoad ? 1 : 0)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return self.tableView(tableView, heightForRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if hasMoreToLoad && indexPath.row == 0
        {
            return tableView.rowHeight
        }
        
        let currentIndex = indexPath.row - (hasMoreToLoad ? 1 : 0)
        return delegate!.cellHeightForMessage(messageArray[currentIndex], width: tableView.frame.size.width)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        checkToLoadMore()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            checkToLoadMore()
        }
    }
    
    func checkToLoadMore() {
        if hasMoreToLoad && tableView.contentOffset.y == 0 {
            
            dataSource!.getOldMessages(maxLoadedMessages, beforeMessage: messageArray.first!, completion: { messages in
                
                var indexPaths : [IndexPath] = []

                for (index, message) in messages.enumerated() {
                    self.messageArray.insert(message, at: 0)
                    indexPaths.append(IndexPath(row: index + 1, section: 0))
                }
                
                let yOfLastCell = self.tableView.rectForRow(at: IndexPath(row: 1, section: 0)).origin.y
                if indexPaths.count > 0 {
                    UIView.setAnimationsEnabled(false)
                    self.tableView.beginUpdates()
                    self.tableView.insertRows(at: indexPaths, with: .none)
                    self.tableView.endUpdates()
                    UIView.setAnimationsEnabled(true)

                    let newY = self.tableView.rectForRow(at: IndexPath(row: messages.count + 1, section: 0)).origin.y - yOfLastCell

                    self.tableView.setContentOffset(CGPoint(x: 0, y: newY), animated: false)
                }
                
                if (messages.count < self.maxLoadedMessages)
                {
                    self.hasMoreToLoad = false
                    self.tableView.beginUpdates()
                    self.tableView.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                    self.tableView.endUpdates()
                }
            })
        }
    }
}

extension UIView {
    
    func pinSubview(_ subview: UIView, on: NSLayoutAttribute, relation: NSLayoutRelation = .equal, space : CGFloat = 0) -> NSLayoutConstraint {
        let constraint : NSLayoutConstraint = NSLayoutConstraint(item: (on == .top || on == .leading ? subview : self), attribute: on, relatedBy: relation, toItem: (on == .top || on == .leading ? self : subview), attribute: on, multiplier: 1, constant: space)
        
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
    
    func setSpace(_ relation: NSLayoutRelation = .equal, space: CGFloat = 0, on: NSLayoutAttribute, ofView: UIView, fromView: AnyObject) -> NSLayoutConstraint {
        let oppositeSide: NSLayoutAttribute
        
        switch on {
        case .top:
            oppositeSide = .bottom
        case .bottom:
            oppositeSide = .top
        case .leading:
            oppositeSide = .trailing
        case .trailing:
            oppositeSide = .leading
        default:
            oppositeSide = on
        }
        
        let constraint : NSLayoutConstraint = NSLayoutConstraint(item: (on == .top || on == .leading ? ofView : fromView),
            attribute: (on == .top || on == .leading ? on : oppositeSide), relatedBy: relation,
            toItem: (on == .top || on == .leading ? fromView : ofView),
            attribute: (on == .top || on == .leading ? oppositeSide : on), multiplier: 1, constant: space)
        
        self.addConstraint(constraint)
        
        return constraint
    }
    
    func align(_ theView: UIView, andTheView: UIView, relation: NSLayoutRelation = .equal, on: NSLayoutAttribute, space: CGFloat = 0) -> NSLayoutConstraint
    {
        let constraint : NSLayoutConstraint = NSLayoutConstraint(item: theView, attribute: on, relatedBy: relation, toItem: andTheView, attribute: on, multiplier: 1, constant: space)
        self.addConstraint(constraint)
        return constraint
    }
    
    func set(_ widthOrHeight: NSLayoutAttribute, relation: NSLayoutRelation = .equal, size: CGFloat = 0) -> NSLayoutConstraint {
        let constraint : NSLayoutConstraint = NSLayoutConstraint(item: self, attribute: widthOrHeight, relatedBy: relation, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: size)
        self.addConstraint(constraint)
        return constraint
    }

}
