/*
 * Copyright 2016 Joel Tobey <joeltobey@gmail.com>.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * A very simple CSV reader released under a commercial-friendly license.
 */
component singleton
    extends="cfboom.lang.Object"
    displayname="Class CSVReader"
    output="false"
{
    property name="javaLoader" inject="loader@cbjavaloader";
    property name="defaultSanitizer" inject="coldbox:setting:defaultSanitizer@cfboom-opencsv";

    public cfboom.opencsv.CSVReader function init() {
        return this;
    }

    public void function onDIComplete() {
        withSanitizer( new "#defaultSanitizer#"() );
    }

    public cfboom.opencsv.CSVReader function load( string csv, any reader ) {
        _instance['CSVParserBuilder'] = javaLoader.create( "com.opencsv.CSVParserBuilder" ).init();
        if (structKeyExists(arguments, "csv")) {
            _instance['CSVReaderBuilder'] = javaLoader.create( "com.opencsv.CSVReaderBuilder" ).init(
                createObject("java", "java.io.StringReader").init( arguments.csv )
            );
        } else if (structKeyExists(arguments, "reader")) {
            _instance['CSVReaderBuilder'] = javaLoader.create( "com.opencsv.CSVReaderBuilder" ).init( arguments.reader );
        } else {
            throw("Can't load CSVReader. Must have either 'csv' or 'reader'");
        }
        return this;
    }

    /**
     * Sets the `Sanitizer` to use while building a query
     *
     * @param separator the delimiter to use for separating entries (char)
     * @return The CSVReader
     */
    public cfboom.opencsv.CSVReader function withSanitizer(required cfboom.opencsv.Sanitizer sanitizer) {
        _instance['sanitizer'] = arguments.sanitizer;
        return this;
    }

    /**
     * Sets the delimiter to use for separating entries.
     *
     * @param separator the delimiter to use for separating entries (char)
     * @return The CSVReader
     */
    public cfboom.opencsv.CSVReader function withSeparator(any separator) {
        _instance.CSVParserBuilder.withSeparator(arguments.separator);
        return this;
    }

    /**
     * Sets the character to use for quoted elements.
     *
     * @param quoteChar the character to use for quoted element.
     * @return The CSVReader
     */
    public cfboom.opencsv.CSVReader function withQuoteChar(any quoteChar) {
        _instance.CSVParserBuilder.withQuoteChar(arguments.quoteChar);
        return this;
    }

    /**
     * Sets the character to use for escaping a separator or quote.
     *
     * @param escapeChar the character to use for escaping a separator or quote.
     * @return The CSVReader
     */
    public cfboom.opencsv.CSVReader function withEscapeChar(any escapeChar) {
        _instance.CSVParserBuilder.withEscapeChar(arguments.escapeChar);
        return this;
    }

    /**
     * Sets the strict quotes setting - if true, characters
     * outside the quotes are ignored.
     *
     * @param strictQuotes if true, characters outside the quotes are ignored
     * @return The CSVReader
     */
    public cfboom.opencsv.CSVReader function withStrictQuotes(boolean strictQuotes) {
        _instance.CSVParserBuilder.withStrictQuotes(arguments.strictQuotes);
        return this;
    }

    /**
     * Sets the ignore leading whitespace setting - if true, white space
     * in front of a quote in a field is ignored.
     *
     * @param ignoreLeadingWhiteSpace if true, white space in front of a quote in a field is ignored
     * @return The CSVReader
     */
    public cfboom.opencsv.CSVReader function withIgnoreLeadingWhiteSpace(boolean ignoreLeadingWhiteSpace) {
        _instance.CSVParserBuilder.withIgnoreLeadingWhiteSpace(arguments.ignoreLeadingWhiteSpace);
        return this;
    }

    /**
     * Sets the ignore quotations mode - if true, quotations are ignored.
     *
     * @param ignoreQuotations if true, quotations are ignored
     * @return The CSVReader
     */
    public cfboom.opencsv.CSVReader function withIgnoreQuotations(boolean ignoreQuotations) {
        _instance.CSVParserBuilder.withIgnoreQuotations(arguments.ignoreQuotations);
        return this;
    }

    /**
     * Sets the NullFieldIndicator.
     *
     * @param fieldIndicator - CSVReaderNullFieldIndicator set to what should be considered a null field.
     * @return - The CSVParserBuilder
     */
    public cfboom.opencsv.CSVReader function withFieldAsNull(any fieldIndicator) {
        _instance.CSVParserBuilder.withFieldAsNull(arguments.fieldIndicator);
        return this;
    }

    /**
     * Sets the line number to skip for start reading.
     *
     * @param skipLines the line number to skip for start reading.
     * @return the CSVReaderBuilder with skipLines set.
     */
    public cfboom.opencsv.CSVReader function withSkipLines(numeric skipLines) {
        _instance.CSVReaderBuilder.withSkipLines( javaCast("int", arguments.skipLines) );
        return this;
    }

    /**
     * Sets if the reader will keep or discard carriage returns.
     *
     * @param keepCR - true to keep carriage returns, false to discard.
     * @return the CSVReaderBuilder based on the set criteria.
     */
    public cfboom.opencsv.CSVReader function withKeepCarriageReturn(boolean keepCR) {
        _instance.CSVReaderBuilder.withKeepCarriageReturn(arguments.keepCR);
        return this;
    }

    /**
     * Checks to see if the CSVReader should verify the reader state before reads or not.
     *
     * This should be set to false if you are using some form of asynchronous reader (like readers created
     * by the java.nio.* classes).
     *
     * The default value is true.
     *
     * @param verifyReader true if CSVReader should verify reader before each read, false otherwise.
     * @return The CSVReaderBuilder based on this criteria.
     */
    public cfboom.opencsv.CSVReader function withVerifyReader(boolean verifyReader) {
        _instance.CSVReaderBuilder.withVerifyReader(arguments.verifyReader);
        return this;
    }

    /**
     * Creates the CSVReader.
     * @return the CSVReader based on the set criteria.
     */
    public any function build() {
        var parser = _instance.CSVParserBuilder.build();
        _instance.CSVReaderBuilder.withCSVParser(parser);
        return _instance.CSVReaderBuilder.build();
    }

    /**
     * Creates a query from the CSV data.
     * @return a query based on the set criteria in CSVReaderBuilder.
     */
    public query function buildQuery(array columns = [], boolean firstRowIsColumnList = true) {
        if (!arguments.firstRowIsColumnList && arrayIsEmpty(arguments.columns))
            throw("Must provide 'columns' if 'firstRowIsColumnList' is false");

        var columnList = "";
        var columnTypeList = "";
        var queryInitialized = false;

        var parser = _instance.CSVParserBuilder.build();
        _instance.CSVReaderBuilder.withCSVParser(parser);
        var csvr = _instance.CSVReaderBuilder.build();
        var it = csvr.iterator();

        if (arguments.firstRowIsColumnList && it.hasNext()) {
            var columnListRow = it.next();
            if (arrayIsEmpty(arguments.columns)) {
                // Only use first row for column list if not provided explicitly.
                for (var columnName in columnListRow) {
                    var column = {"name":columnName};
                    arrayAppend(arguments.columns, column);
                }
            }
        }

        if (arrayIsEmpty(arguments.columns))
            throw(object=creatObject("java", "java.lang.IllegalStateException").init("'columns' should have column list names at this point"));

        while(it.hasNext()) {
            var dataArray = it.next();

            // We initialize the query here so we can parse the column types from the data if necessary.
            if (!queryInitialized) {

                // One use first row of data to determine the column type if not provided explicitly
                if (!structKeyExists(arguments.columns[1], "type")) {
                    for (var i = 1; i <= arrayLen(arguments.columns); i++) {
                        var column = arguments.columns[i];
                        try {
                            column['type'] = parseType( dataArray[i] );
                        } catch (expression ex) {
                            // If cell is empty/null, then we default to 'VarChar'.
                            column['type'] = "VarChar";
                        }
                    }
                }
                for (var column in arguments.columns) {
                    columnList = listAppend(columnList, column.name);
                    columnTypeList = listAppend(columnTypeList, column.type);
                }
                var dataQuery = queryNew(columnList, columnTypeList);
                queryInitialized = true;
            }
            queryAddRow(dataQuery);
            for (var i = 1; i <= arrayLen(arguments.columns); i++) {
                try {
                    querySetCell(dataQuery, arguments.columns[i].name, _instance.sanitizer.sanatize( dataArray[i], arguments.columns[i] ));
                } catch (expression ex) {
                    // Ignore empty/null fields
                }
            }
        }
        return dataQuery;
    }

    private string function parseType( required any data ) {
        var type = "VarChar"; // Default
        if (isBinary( arguments.data )) {
            type = "Binary";
        } else if (isDate( arguments.data )) {
            type = "Timestamp";
        } else if (isNumeric( arguments.data )) {
            if (isValid("integer", arguments.data)) {
                type = "Integer";
            } else {
                type = "Double";
            }
        } else if (isBoolean( arguments.data )) {
            type = "Bit";
        }
        return type;
    }
}