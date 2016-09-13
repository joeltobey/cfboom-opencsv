component
    extends="cfboom.lang.Object"
    displayname="Class CSVReader"
    output="false"
{
    property name="javaLoader" inject="loader@cbjavaloader";
    
    public cfboom.opencsv.CSVReader function init() {
        return this;
    }

    public void function load( required string csv ) {
        _instance['CSVParserBuilder'] = javaLoader.create( "com.opencsv.CSVParserBuilder" ).init();
        _instance['CSVReaderBuilder'] = javaLoader.create( "com.opencsv.CSVReaderBuilder" ).init(
            createObject("java", "java.io.StringReader").init( arguments.csv )
        );
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
}