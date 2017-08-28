# redux_dev_tools

[![build status](https://gitlab.com/brianegan/redux_dev_tools/badges/master/build.svg)](https://gitlab.com/brianegan/redux_dev_tools/commits/master)  [![coverage report](https://gitlab.com/brianegan/redux_dev_tools/badges/master/coverage.svg)](https://brianegan.gitlab.io/redux_dev_tools/coverage/)

A [Redux](https://pub.dartlang.org/packages/redux) `Store` with a [Delorean](http://www.imdb.com/title/tt0088763/). 

This library allows you to create a `DevToolsStore` during dev mode in place of a normal [Redux](https://pub.dartlang.org/packages/redux) Store. This `DevToolsStore` will act exactly like a normal Store at first, with one catch: It will allow you to travel back and forth throughout the State of your application!

You can write your own UI to travel in time, or use one of the existing options for the platform you're working with:

  * Flutter
    * [flutter_redux_dev_tools](https://pub.dartlang.org/packages/flutter_redux_dev_tools)
  * Web
    * No web UI exists yet. This could be you!
    
## Demo

### Flutter

A simple Flutter app that allows you to Increment and Decrement a counter.

![A screenshot of the Dev Tools in Action](https://gitlab.com/brianegan/redux_dev_tools/raw/master/devtools.gif)

## Usage

```dart
// Start by creating a simple Reducer, or a complex one. Dealer's choice. :)
int addOneReducer(int state, action) => state + 1;

// For production mode, this is how you should create your Store.
final store = new Store(addReducer);

// In Dev Mode, however, if you want to hook up to Time-Traveling 
// Dev Tools, create a `DevToolsStore` instead!
//
// It will act exactly like your normal Store, but give you super powers
// to travel back and forth in time throughout your app States!
final store = new DevToolsStore(addReducer);
```

## Credits

All of this code was directly inspired by the original [Redux Devtools](https://github.com/gaearon/redux-devtools). 

