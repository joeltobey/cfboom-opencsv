component
    extends="cfboom.lang.Object"
    displayname="Class CSVWriter"
    output="false"
{
    property name="javaLoader" inject="loader@cbjavaloader";
    property name="DateUtils" inject="DateUtils@cfboomUtil";

    public cfboom.opencsv.CSVWriter function init(any writer, any separator, any quotechar, any escapechar, string lineEnd) {
        return this;
    }

    public void function onDIComplete() {
        variables['CSVWriter'] = javaLoader.create( "com.opencsv.CSVWriter" );
        variables['javaClass'] = CSVWriter.getClass();
        variables['javaClassLoader'] = javaClass.getClassLoader();
        variables['Array'] = createObject("java","java.lang.reflect.Array");
    }

    public cfboom.opencsv.CSVWriter function build(any writer, any separator, any quotechar, any escapechar, string lineEnd) {
        if (structKeyExists(arguments, "writer")) {
            _instance['writer'] = arguments.writer;
        } else {
            _instance['writer'] = createObject("java", "java.io.StringWriter").init();
        }
        if (structKeyExists(arguments, "separator")) {
            _instance['separator'] = javaCast("char", arguments.separator);
        } else {
            _instance['separator'] = CSVWriter.DEFAULT_SEPARATOR;
        }
        if (structKeyExists(arguments, "quotechar")) {
            _instance['quotechar'] = javaCast("char", arguments.quotechar);
        } else {
            _instance['quotechar'] = CSVWriter.DEFAULT_QUOTE_CHARACTER;
        }
        if (structKeyExists(arguments, "escapechar")) {
            _instance['escapechar'] = javaCast("char", arguments.escapechar);
        } else {
            _instance['escapechar'] = CSVWriter.DEFAULT_ESCAPE_CHARACTER;
        }
        if (structKeyExists(arguments, "lineEnd")) {
            _instance['lineEnd'] = javaCast("char", arguments.lineEnd);
        } else {
            _instance['lineEnd'] = CSVWriter.DEFAULT_LINE_END;
        }
        _instance['CSVWriter'] = javaLoader.create( "com.opencsv.CSVWriter" ).init(
            _instance.writer, _instance.separator, _instance.quotechar, _instance.escapechar, _instance.lineEnd
        );
        return this;
    }

    public any function getWriter() {
        return _instance.writer;
    }

    /**
     * Writes the entire list to a CSV file. The list is assumed to be a
     * String[]
     *
     * @param allLines         a List of String[], with each String[] representing a line of
     *                         the file.
     * @param applyQuotesToAll true if all values are to be quoted.  false if quotes only
     *                         to be applied to values which contain the separator, escape,
     *                         quote or new line characters.
     */
    public any function writeAll(any allLines, boolean applyQuotesToAll = true, boolean includeColumnNames = true, boolean trim = false, boolean nullToNotSet = false, boolean convertToUTC = true) {
        if (!structKeyExists(arguments, "allLines")) {
            _instance.CSVWriter.writeAll(javaCast("null", ""), javaCast("boolean", arguments.applyQuotesToAll));
        } else if (isArray(arguments.allLines)) {
            for (var nextLine in arguments.allLines) {
                if (isNull(nextLine)) {
                    writeNext(javaCast("null", ""), arguments.applyQuotesToAll);
                } else {
                    writeNext(nextLine, arguments.applyQuotesToAll);
                }
            }
        } else if (isQuery(arguments.allLines)) {
            var linesWritten = 0;
            var qMeta = getMetaData(arguments.allLines);

            // First write the headers (if included)
            if (arguments.includeColumnNames) {
                var headerArray = Array.newInstance(javaClassLoader.loadClass("java.lang.String"), javaCast("int",arrayLen(qMeta)));
                var idx = 0;
                for (var meta in qMeta) {
                    idx++;
                    if (structKeyExists(meta, "name")) {
                        headerArray[idx] = meta.name;
                    }
                }
                _instance.CSVWriter.writeNext(headerArray, javaCast("boolean", arguments.applyQuotesToAll));
                linesWritten++;
            }

            // Then write the data
            for (var nextLine in arguments.allLines) {
                var dataArray = Array.newInstance(javaClassLoader.loadClass("java.lang.String"), javaCast("int",arrayLen(qMeta)));
                var idx = 0;
                for (var meta in qMeta) {
                    idx++;
                    if (structKeyExists(meta, "typeName") && structKeyExists(meta, "name") && structKeyExists(nextLine, meta.name)) {
                        dataArray[idx] = formatQueryData( nextLine[meta.name], meta.typeName, arguments.trim, arguments.nullToNotSet, arguments.convertToUTC );
                    } else {
                        if (arguments.nullToNotSet && structKeyExists(meta, "typeName") && listFindNoCase("varchar", meta.typeName)) {
                            dataArray[idx] = "(not set)";
                        }
                    }
                }
                _instance.CSVWriter.writeNext(dataArray, javaCast("boolean", arguments.applyQuotesToAll));
                linesWritten++;
            }
            return javaCast("int", linesWritten);

        } else {
            var sb = createObject("java", "java.lang.StringBuilder").init(arguments.allLines.getClass());
            throw("method is not implemented for " & sb.toString());
        }
    }

    private string function formatQueryData(required any data, required string type, boolean trim = false, boolean nullToNotSet = false, boolean convertToUTC = true) {
        if (lCase(arguments.type) == "date" && len(trim(arguments.data))) {
            arguments.data = dateFormat(arguments.data, "yyyy-mm-dd");
        } else if (lCase(arguments.type) == "time" && len(trim(arguments.data))) {
            arguments.data = timeFormat(arguments.data, "HH:mm:ss");
        } else if (lCase(arguments.type) == "timestamp" && len(trim(arguments.data))) {
            arguments.data = DateUtils.formatIso8601Date( arguments.data, arguments.convertToUTC );
        } else if (listFindNoCase("varchar,longvarchar", arguments.type)) {
            if (arguments.trim) {
                arguments.data = trim(arguments.data);
            }
            if (arguments.nullToNotSet && arguments.type == "varchar" && !len(arguments.data)) {
                arguments.data = "(not set)";
            }
        }
        return arguments.data.toString();
    }

    /**
     * Writes the next line to the file.
     *
     * @param nextLine         a string array with each comma-separated element as a separate
     *                         entry.
     * @param applyQuotesToAll true if all values are to be quoted.  false applies quotes only
     *                         to values which contain the separator, escape, quote or new line characters.
     */
    public void function writeNext(array nextLine, boolean applyQuotesToAll = true) {
        if (!structKeyExists(arguments, "nextLine")) {
            _instance.CSVWriter.writeNext(javaCast("null", ""), javaCast("boolean", arguments.applyQuotesToAll));
        } else {
            var stringArray = Array.newInstance(javaClassLoader.loadClass("java.lang.String"), javaCast("int",arrayLen(arguments.nextLine)));
            var idx = 0;
            for (var ele in arguments.nextLine) {
                idx++;
                if (!isNull(ele)) {
                    stringArray[idx] = ele;
                }
            }
            _instance.CSVWriter.writeNext(stringArray, javaCast("boolean", arguments.applyQuotesToAll));
        }
    }

    /**
     * checks to see if the line contains special characters.
     * @param line - element of data to check for special characters.
     * @return true if the line contains the quote, escape, separator, newline or return.
     */
    public boolean function stringContainsSpecialCharacters(string line) {
        return _instance.CSVWriter.stringContainsSpecialCharacters(arguments.line);
    }

    /**
     * Processes all the characters in a line.
     * @param nextElement - element to process.
     * @return a StringBuilder with the elements data.
     */
    public any function processLine(string nextElement) {
        return _instance.CSVWriter.processLine(arguments.nextElement);
    }
    
    /**
     * Flush underlying stream to writer.
     *
     * @throws IOException if bad things happen
     */
    public void function flush() {
        _instance.CSVWriter.flush();
    }

    /**
     * Close the underlying stream writer flushing any buffered content.
     *
     * @throws IOException if bad things happen
     */
    public void function close() {
        _instance.CSVWriter.close();
    }

    /**
     * Checks to see if the there has been an error in the printstream.
     *
     * @return <code>true</code> if the print stream has encountered an error,
     *          either on the underlying output stream or during a format
     *          conversion.
     */
    public boolean function checkError() {
        return _instance.CSVWriter.checkError();
    }

    /**
     * flushes the writer without throwing any exceptions.
     */
    public void function flushQuietly() {
        _instance.CSVWriter.flushQuietly();
    }
}