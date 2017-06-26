[![Build Status](https://api.travis-ci.org/joeltobey/cfboom-opencsv.svg?branch=development)](https://travis-ci.org/joeltobey/cfboom-opencsv)

# Welcome to the cfboom HTTP Coldbox Module
The cfboom-opencsv module provides a wrapper facade to the opencsv project (http://opencsv.sourceforge.net).

## License
Apache License, Version 2.0.

## Important Links
- https://github.com/joeltobey/cfboom-opencsv/wiki

## System Requirements
- Lucee 4.5+
- ColdFusion 9+

# Instructions
Just drop into your **modules** folder or use CommandBox to install

`box install cfboom-opencsv`

## WireBox Mappings
The module registers the CSVReader: `CSVReader@cfboomOpencsv` and CSVWriter: `CSVWriter@cfboomOpencsv` that allows you to read and write CSV data. Check out the API Docs for all the possible functions.

## Settings
There's an optional setting in your `ColdBox.cfc` file under a `cfboomOpencsv` struct of `moduleSettings` to override the default `HttpRequestExecutor`:

```js
moduleSettings = {
  cfboomOpencsv = {
    /**
     * The default `Sanitizer` used when building a query.
     * It must implement cfboom.opencsv.Sanitizer.
     * The default is [cfboom.opencsv.PassthroughSanitizer]
     */
    defaultSanitizer = "cfboom.opencsv.Sanitizer"
  }
};
```

## CSVReader Methods

Once you have an instance of the `HttpClient`, you can call these methods:

```
var csvr = getInstance( "CSVReader@cfboomOpencsv" ).load( csvData ).build();
```

## CSVWriter Methods

```
var sw = createObject("java", "java.io.StringWriter").init();
var cArgs = {};
cArgs.writer = sw;
cArgs.separator = ",";
cArgs.quotechar = "'";
var csvw = getInstance( "CSVWriter@cfboomOpencsv" ).build(argumentCollection:cArgs);
csvw.writeNext(args);
return sw.toString();
```

## Testing

For testing, you'll need to create a MySQL datasource named 'cfboom_test' using the tests/resources/Dump_All_Types.sql script.