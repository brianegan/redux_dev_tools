# redux_dev_tools

[![Build Status](https://travis-ci.org/brianegan/redux_dev_tools.svg?branch=master)](https://travis-ci.org/brianegan/redux_dev_tools) [![codecov](https://codecov.io/gh/brianegan/redux_dev_tools/branch/master/graph/badge.svg)](https://codecov.io/gh/brianegan/redux_dev_tools)

A [Redux](https://pub.dartlang.org/packages/redux) `Store` with a [Delorean](http://www.imdb.com/title/tt0088763/). 

This library allows you to create a `DevToolsStore` during dev mode in place of a normal [Redux](https://pub.dartlang.org/packages/redux) Store. This `DevToolsStore` will act exactly like a normal Store at first, with one catch: It will allow you to travel back and forth throughout the State of your application!

You can write your own UI to travel in time, or use one of the existing options for the platform you're working with:

  * Flutter
    * [flutter_redux_dev_tools](https://pub.dartlang.org/packages/flutter_redux_dev_tools)
  * Web
    * [angular_redux_dev_tools](https://github.com/localhurst/angular_redux_dev_tools)
    
## Demo

### Flutter

A simple Flutter app that allows you to Increment and Decrement a counter.

![A screenshot of the Dev Tools in Action](https://gitlab.com/brianegan/redux_dev_tools/raw/master/devtools.gif)

## Usage

```dart
// Start by creating a simple Reducer, or a complex one. Dealer's choice. :)
int addOneReducer(int state, action) => state + 1;

// For production mode, this is how you should create your Store.
final store = new Store(addReducer, initialState: 0);

// In Dev Mode, however, if you want to hook up to Time-Traveling 
// Dev Tools, create a `DevToolsStore` instead!
//
// It will act exactly like your normal Store, but give you super powers
// to travel back and forth in time throughout your app States!
// 
// Remember: By itself this will beef up your Store, but will not provide
// a UI to Time Travel. See the libraries listed above to learn how to
// connect your Redux store to a UI! 
final store = new DevToolsStore(addReducer, initialState: 0);
```

## Credits

All of this code was directly inspired by the original [Redux Devtools](https://github.com/gaearon/redux-devtools). 

