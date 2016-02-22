# Lounge

[![CI Status](http://img.shields.io/travis/Ysix/Lounge.svg?style=flat)](https://travis-ci.org/Ysix/Lounge)
[![Version](https://img.shields.io/cocoapods/v/Lounge.svg?style=flat)](http://cocoapods.org/pods/Lounge)
[![License](https://img.shields.io/cocoapods/l/Lounge.svg?style=flat)](http://cocoapods.org/pods/Lounge)
[![Platform](https://img.shields.io/cocoapods/p/Lounge.svg?style=flat)](http://cocoapods.org/pods/Lounge)

## Features    

* [x] Interactive keyboard
* [x] Adaptative text input
* [x] Custom cells and views with the storyboard
* [x] Browse chat history
* [x] Text placeholder
* [x] Auto enabling of send button

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Usage

1. Drag the files in your project or use cocoaPod
2. Create a view controller file that inherit from **LoungeViewController**
3. Create it also in your storyboard
4. In this view controller drag at least these elements :
  * A UITableView
  * A UIView (which need to be (or inherit from) **LoungeInputView**)
  * in this UIView
    * a UITextView
    * a UIButton
5. You can also add a view at the top of the UITableView and a UIView in the **LoungeInputView** (it will be displayed at the left of the UITextView)
6. Link all these views at the correct IBOutlet of the LoungeViewController
7. Implement the protocols **LoungeDelegate** and **LoungeDataSource** on your view controller.

*Don't bother much about the constraints, they will be removed at run time*

## Customisation

You can customise :

* Anything you want from the storyboard (except the constraints)
* The top view height with **setTopViewHeight** (if you did set a view at the top of the table view)
* The textView placeholder with **setPlaceHolder**
* A line on top of the input view with **setSeparatorColor**

## Requirements

* iOS 8.0+

## Installation

Lounge is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Lounge"
```

## Author

Ysix, eddy@omts.fr

## License

Lounge is available under the MIT license. See the LICENSE file for more info.
