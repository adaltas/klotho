[![Build Status](https://secure.travis-ci.org/adaltas/node-templated-object.png)][travis]

# Node.js Self Templated project

Self Templated brings the power of templating to your literal object with a graph resolution of the references. It traverses an object recursively and use the same self-referenced object as a context. It is entirely agnostic of the templating engine being used and default to [Handlebars](https://handlebarsjs.com/).

If this is not clear, imagine a templating engine rendering all the string of an object and inject that same object as a context.

If this is still not clear, imagine a configuration where each value can referenced other values from that same configuration, see the example below.

If you have understood but a more sarrow introduction would have helped, please [share your suggestions](https://github.com/adaltas/node-templated-object/edit/master/README.md).

This package features:

* Agnostic/multi template engines
* Circular refenrences detection
* Simple and consise API
* Full test coverage

## Installation

This is OSS and licensed under the [new BSD license][license]. The project
homepage is located on GitHub and the package is distributed by [NPM](https://www.npmjs.com/package/templated-object):

```bash
npm install templated-object
```

## Usage

`templated(object[,options])`

Quite simple, the exported module is a function taking the `object` to render as
first argument and optionally an `options` object as second argument.

Options includes:

* `handlebars` (object)   
  Options passed to HandleBars.
* `partial` ([string])   
  Filtering the templating to a restricuted list of properties.
* `render` (function)   
  A user defined function responsible to render a template. Argments are the template and the context, expect to returned the rendered result. Default implementation is using [HandleBars](http://handlebarsjs.com).

## Examples

```js
templated = require('templated-object');
// Render
config = templated({
  "webapp": {
    "app_name": 'cool_app',
    "db_url": 'mysql://{{db.host}}:{{db.port}}/{{webapp.db_name}}',
    "db_name": 'db_{{webapp.app_name}}'
  },
  "db": {
    "host": 'localhost',
    "port":  '3306'
  }
});
// Assert
console.log(config.webapp.db_url == "mysql://localhost:3306/db_cool_app");
```

## Development

Tests are executed with mocha. To install it, simple run `npm install`, it will install
mocha and its dependencies in your project "node_modules" directory.

To run the tests:
```bash
npm test
```

The tests run against the CoffeeScript source files.

The test suite is run online with [Travis][travis].

## Contributors

*   David Worms: <https://github.com/wdavidw>

[travis]: http://travis-ci.org/adaltas/node-templated-object
[license]: https://github.com/adaltas/node-templated-object/blob/master/LICENSE.md
