/*
 * Copyright 2002-2015 the original author or authors and Joel Tobey <joeltobey@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * @auther Joel Tobey
 */
component
    extends="coldbox.system.testing.BaseTestCase"
    appMapping="/root"
    displayname="Class CSVReaderTests"
    output="false"
{
    // this will run once after initialization and before setUp()
    public void function beforeTests() {
        super.beforeTests();
        var javaLoader = getInstance( "loader@cbjavaloader" );
        LINE_SEPARATOR = createObject("java", "java.lang.System").getProperty("line.separator");
        variables['CSVReaderNullFieldIndicator'] = javaLoader.create( "com.opencsv.enums.CSVReaderNullFieldIndicator" );
    }

    // this will run before every single test in this test case
    public void function setUp() {
        super.setup();
        var sb = createObject("java", "java.lang.StringBuilder").init( javaCast("int", 1024) );
        sb.append("a,b,c").append(LINE_SEPARATOR);   // standard case
        sb.append('a,"b,b,b",c').append(LINE_SEPARATOR);  // quoted elements
        sb.append(",,").append(LINE_SEPARATOR); // empty elements
        sb.append('a,"PO Box 123,').append(LINE_SEPARATOR).append('Kippax,ACT. 2615.').append(LINE_SEPARATOR).append('Australia",d.').append(LINE_SEPARATOR);
        sb.append('"Glen ""The Man"" Smith",Athlete,Developer').append(LINE_SEPARATOR); // Test quoted quote chars
        sb.append('"""""","test"').append(LINE_SEPARATOR); // """""","test"  representing:  "", test
        sb.append('"a').append(LINE_SEPARATOR).append('b",b,"').append(LINE_SEPARATOR).append('d",e').append(LINE_SEPARATOR);

        variables['csvr'] = getInstance( "CSVReader@cfboomOpencsv" ).load( sb.toString() ).build();
    }

    // this will run after every single test in this test case
    public void function reset() {
        super.reset();
        structDelete( variables, "csvr" );
    }

    // this will run once after all tests have been run
    public void function afterTests() {
        structDelete(variables, "LINE_SEPARATOR");
        structDelete(variables, "CSVReaderNullFieldIndicator");
        super.afterTests();
    }

    /**
     * Tests iterating over a reader.
     *
     * @throws IOException if the reader fails.
     */
    public void function testParseLine() {

        // test normal case
        var nextLine = csvr.readNext();
        assertEquals("a", nextLine[1]);
        assertEquals("b", nextLine[2]);
        assertEquals("c", nextLine[3]);

        // test quoted commas
        nextLine = csvr.readNext();
        assertEquals("a", nextLine[1]);
        assertEquals("b,b,b", nextLine[2]);
        assertEquals("c", nextLine[3]);

        // test empty elements
        nextLine = csvr.readNext();
        assertEquals(3, arrayLen(nextLine));

        // test multiline quoted
        nextLine = csvr.readNext();
        assertEquals(3, arrayLen(nextLine));

        // test quoted quote chars
        nextLine = csvr.readNext();
        assertEquals("Glen ""The Man"" Smith", nextLine[1]);

        nextLine = csvr.readNext();
        assertEquals("""""", nextLine[1]); // check the tricky situation
        assertEquals("test", nextLine[2]); // make sure we didn't ruin the next field..

        nextLine = csvr.readNext();
        assertEquals(4, arrayLen(nextLine));

        //test end of stream
        $assert.null(csvr.readNext());
    }

    public void function testReaderCanHandleNullInString() {
        var sb = createObject("java", "java.lang.StringBuilder").init( javaCast("int", 1024) );
        sb.append("a,#chr(0)#b,c");

        var reader = createObject("java", "java.io.StringReader").init( sb.toString() );

        var builder = getInstance( "CSVReader@cfboomOpencsv" ).load( reader );
        var defaultReader = builder.build();

        var nextLine = defaultReader.readNext();
        assertEquals(3, arrayLen(nextLine));
        assertEquals("a", nextLine[1]);
        assertEquals("#chr(0)#b", nextLine[2]);
        //assertEquals(chr(0), nextLine[2].charAt(0));
        assertEquals("c", nextLine[3]);
    }

    public void function testParseLineStrictQuote() {
        var sb = createObject("java", "java.lang.StringBuilder").init( javaCast("int", 1024) );
        sb.append("a,b,c").append(LINE_SEPARATOR);   // standard case
        sb.append('a,"b,b,b",c').append(LINE_SEPARATOR);  // quoted elements
        sb.append(",,").append(LINE_SEPARATOR); // empty elements
        sb.append('a,"PO Box 123,').append(LINE_SEPARATOR).append('Kippax,ACT. 2615.').append(LINE_SEPARATOR).append('Australia",d.').append(LINE_SEPARATOR);
        sb.append('"Glen ""The Man"" Smith",Athlete,Developer').append(LINE_SEPARATOR); // Test quoted quote chars
        sb.append('"""""","test"').append(LINE_SEPARATOR); // """""","test"  representing:  "", test
        sb.append('"a').append(LINE_SEPARATOR).append('b",b,"').append(LINE_SEPARATOR).append('d",e').append(LINE_SEPARATOR);

        var csvreader = getInstance( "CSVReader@cfboomOpencsv" ).load( sb.toString() ).withStrictQuotes(true).build();

        // test normal case
        var nextLine = csvreader.readNext();
        assertEquals("", nextLine[1]);
        assertEquals("", nextLine[2]);
        assertEquals("", nextLine[3]);

        // test quoted commas
        nextLine = csvreader.readNext();
        assertEquals("", nextLine[1]);
        assertEquals("b,b,b", nextLine[2]);
        assertEquals("", nextLine[3]);

        // test empty elements
        nextLine = csvreader.readNext();
        assertEquals(3, arrayLen(nextLine));

        // test multiline quoted
        nextLine = csvreader.readNext();
        assertEquals(3, arrayLen(nextLine));

        // test quoted quote chars
        nextLine = csvreader.readNext();
        assertEquals("Glen ""The Man"" Smith", nextLine[1]);

        nextLine = csvreader.readNext();
        assertEquals("""""", nextLine[1]); // check the tricky situation
        assertEquals("test", nextLine[2]); // make sure we didn't ruin the next field..

        nextLine = csvreader.readNext();
        assertEquals(4, arrayLen(nextLine));
        assertEquals("a#LINE_SEPARATOR#b", nextLine[1]);
        assertEquals("", nextLine[2]);
        assertEquals("#LINE_SEPARATOR#d", nextLine[3]);
        assertEquals("", nextLine[4]);

        //test end of stream
        $assert.null(csvreader.readNext());
    }


    /**
     * Test parsing to a list.
     *
     * @throws IOException if the reader fails.
     */
    public void function testParseAll() {
        assertEquals(7, arrayLen(csvr.readAll()));
    }

    /**
     * Tests constructors with optional delimiters and optional quote char.
     *
     * @throws IOException if the reader fails.
     */
    public void function testOptionalConstructors() {

        var sb = createObject("java", "java.lang.StringBuilder").init( javaCast("int", 1024) );
        sb.append("a#chr(9)#b#chr(9)#c").append(LINE_SEPARATOR);   // tab separated case
        sb.append("a#chr(9)#'b#chr(9)#b#chr(9)#b'#chr(9)#c").append(LINE_SEPARATOR);  // single quoted elements

        var c = getInstance( "CSVReader@cfboomOpencsv" ).load( sb.toString() ).withSeparator( chr(9) ).withQuoteChar("'").build();

        var nextLine = c.readNext();
        assertEquals(3, arrayLen(nextLine));

        nextLine = c.readNext();
        assertEquals(3, arrayLen(nextLine));
    }

    public void function testParseQuotedStringWithDefinedSeperator() {
        var sb = createObject("java", "java.lang.StringBuilder").init( javaCast("int", 1024) );
        sb.append("a#chr(9)#b#chr(9)#c").append(LINE_SEPARATOR);   // tab separated case

        var c = getInstance( "CSVReader@cfboomOpencsv" ).load( sb.toString() ).withSeparator( chr(9) ).build();

        var nextLine = c.readNext();
        assertEquals(3, arrayLen(nextLine));
    }

    /**
     * Tests option to skip the first few lines of a file.
     *
     * @throws IOException if bad things happen
     */
    public void function testSkippingLines() {

        var sb = createObject("java", "java.lang.StringBuilder").init( javaCast("int", 1024) );
        sb.append("Skip this line#chr(9)# with tab").append(LINE_SEPARATOR);   // should skip this
        sb.append("And this line too").append(LINE_SEPARATOR);   // and this
        sb.append("a#chr(9)#'b#chr(9)#b#chr(9)#b'#chr(9)#c").append(LINE_SEPARATOR);  // single quoted elements
        var c = getInstance( "CSVReader@cfboomOpencsv" ).load( sb.toString() ).withSeparator( chr(9) ).withQuoteChar("'").withSkipLines(2).build();

        var nextLine = c.readNext();
        assertEquals(3, arrayLen(nextLine));

        assertEquals("a", nextLine[1]);
    }

    /**
     * Tests methods to get the number of lines and records read.
     *
     * @throws IOException if bad things happen
     */
    public void function testLinesAndRecordsRead() {

        var sb = createObject("java", "java.lang.StringBuilder").init( javaCast("int", 1024) );
        sb.append("Skip this line#chr(9)# with tab").append(LINE_SEPARATOR);   // should skip this
        sb.append("And this line too").append(LINE_SEPARATOR);   // and this
        sb.append("a,b,c").append(LINE_SEPARATOR);    // second line
        sb.append(LINE_SEPARATOR);                    // no data here just a blank line
        sb.append("a,""b").append(LINE_SEPARATOR).append("b"",c");

        var c = getInstance( "CSVReader@cfboomOpencsv" ).load( sb.toString() ).withSkipLines(2).build();

        assertEquals(0, c.getLinesRead());
        assertEquals(0, c.getRecordsRead());

        var nextLine = c.readNext();
        assertEquals(3, arrayLen(nextLine));

        assertEquals(3, c.getLinesRead());
        assertEquals(1, c.getRecordsRead());

        nextLine = c.readNext();
        assertEquals(1, arrayLen(nextLine));
        for (var line in nextLine) {
            assertEquals(0, len(line));
        }

        assertEquals(4, c.getLinesRead());
        assertEquals(2, c.getRecordsRead());  // A blank line is considered a record with a single element

        nextLine = c.readNext();
        assertEquals(3, arrayLen(nextLine));

        assertEquals(6, c.getLinesRead());
        assertEquals(3, c.getRecordsRead());  // two lines read to get a single record.

        nextLine = c.readNext();  // reading after all the data has been read.
        assertTrue(isNull(nextLine));

        assertEquals(6, c.getLinesRead());
        assertEquals(3, c.getRecordsRead());
    }

    /**
     * Tests option to skip the first few lines of a file.
     *
     * @throws IOException if bad things happen
     */
    public void function testSkippingLinesWithDifferentEscape() {

        var sb = createObject("java", "java.lang.StringBuilder").init( javaCast("int", 1024) );
        sb.append("Skip this line?t with tab").append(LINE_SEPARATOR);   // should skip this
        sb.append("And this line too").append(LINE_SEPARATOR);   // and this
        sb.append("a#chr(9)#'b#chr(9)#b#chr(9)#b'#chr(9)#'c'").append(LINE_SEPARATOR);  // single quoted elements
        var c = getInstance( "CSVReader@cfboomOpencsv" ).load( sb.toString() ).withSeparator( chr(9) ).withQuoteChar("'").withSkipLines(2).withEscapeChar("?").build();

        var nextLine = c.readNext();

        assertEquals(3, arrayLen(nextLine));

        assertEquals("a", nextLine[1]);
        assertEquals("b#chr(9)#b#chr(9)#b", nextLine[2]);
        assertEquals("c", nextLine[3]);
    }

    /**
     * Test a normal non quoted line with three elements
     *
     * @throws IOException
     */
    public void function testNormalParsedLine() {

        var sb = createObject("java", "java.lang.StringBuilder").init( javaCast("int", 1024) );

        sb.append("a,1234567,c").append(LINE_SEPARATOR);// a,1234567,c

        var c = getInstance( "CSVReader@cfboomOpencsv" ).load( sb.toString() ).build();

        var nextLine = c.readNext();
        assertEquals(3, arrayLen(nextLine));

        assertEquals("a", nextLine[1]);
        assertEquals("1234567", nextLine[2]);
        assertEquals("c", nextLine[3]);
    }


    /**
     * Same as testADoubleQuoteAsDataElement but I changed the quotechar to a
     * single quote.
     *
     * @throws IOException
     */
    public void function testASingleQuoteAsDataElement() {

        var sb = createObject("java", "java.lang.StringBuilder").init( javaCast("int", 1024) );

        sb.append("a,'''',c").append(LINE_SEPARATOR);// a,',c

        var c = getInstance( "CSVReader@cfboomOpencsv" ).load( sb.toString() ).withSeparator(",").withQuoteChar("'").build();

        var nextLine = c.readNext();
        assertEquals(3, arrayLen(nextLine));

        assertEquals("a", nextLine[1]);
        assertEquals(1, len(nextLine[2]));
        assertEquals("'", nextLine[2]);
        assertEquals("c", nextLine[3]);
    }

    /**
     * Same as testADoubleQuoteAsDataElement but I changed the quotechar to a
     * single quote.  Also the middle field is empty.
     *
     * @throws IOException
     */
    public void function testASingleQuoteAsDataElementWithEmptyField() {

        var sb = createObject("java", "java.lang.StringBuilder").init( javaCast("int", 1024) );

        sb.append("a,'',c").append(LINE_SEPARATOR);// a,,c

        var c = getInstance( "CSVReader@cfboomOpencsv" ).load( sb.toString() ).withSeparator(",").withQuoteChar("'").build();

        var nextLine = c.readNext();
        assertEquals(3, arrayLen(nextLine));

        assertEquals("a", nextLine[1]);
        assertEquals(0, len(nextLine[2]));
        assertEquals("", nextLine[2]);
        assertEquals("c", nextLine[3]);
    }

    public void function testSpacesAtEndOfString() {
        var sb = createObject("java", "java.lang.StringBuilder").init( javaCast("int", 1024) );

        sb.append("""a"",""b"",""c""   ");

        var c = getInstance( "CSVReader@cfboomOpencsv" ).load( sb.toString() ).withStrictQuotes(true).build();

        var nextLine = c.readNext();
        assertEquals(3, arrayLen(nextLine));

        assertEquals("a", nextLine[1]);
        assertEquals("b", nextLine[2]);
        assertEquals("c", nextLine[3]);
    }

    public void function testEscapedQuote() {

        var sb = createObject("java", "java.lang.StringBuilder").init( javaCast("int", 1024) );

        sb.append("a,""123\""4567"",c").append(LINE_SEPARATOR);// a,123"4",c

        var c = getInstance( "CSVReader@cfboomOpencsv" ).load( sb.toString() ).build();

        var nextLine = c.readNext();
        assertEquals(3, arrayLen(nextLine));

        assertEquals("123""4567", nextLine[2]);
    }

    public void function testEscapedEscape() {

        var sb = createObject("java", "java.lang.StringBuilder").init( javaCast("int", 1024) );

        sb.append("a,""123\\\\4567"",c").append(LINE_SEPARATOR);// a,123"4",c

        var c = getInstance( "CSVReader@cfboomOpencsv" ).load( sb.toString() ).build();

        var nextLine = c.readNext();
        assertEquals(3, arrayLen(nextLine));

        assertEquals("123\\4567", nextLine[2]);
    }

    /**
     * Test a line where one of the elements is two single quotes and the
     * quote character is the default double quote.  The expected result is two
     * single quotes.
     *
     * @throws IOException
     */
    public void function testSingleQuoteWhenDoubleQuoteIsQuoteChar() {

        var sb = createObject("java", "java.lang.StringBuilder").init( javaCast("int", 1024) );

        sb.append("a,'',c").append(LINE_SEPARATOR);// a,'',c

        var c = getInstance( "CSVReader@cfboomOpencsv" ).load( sb.toString() ).build();

        var nextLine = c.readNext();
        assertEquals(3, arrayLen(nextLine));

        assertEquals("a", nextLine[1]);
        assertEquals(2, len(nextLine[2]));
        assertEquals("''", nextLine[2]);
        assertEquals("c", nextLine[3]);
    }

    /**
     * Test a normal line with three elements and all elements are quoted
     *
     * @throws IOException
     */
    public void function testQuotedParsedLine() {

        var sb = createObject("java", "java.lang.StringBuilder").init( javaCast("int", 1024) );

        sb.append("""a"",""1234567"",""c""").append(LINE_SEPARATOR); // "a","1234567","c"

        var c = getInstance( "CSVReader@cfboomOpencsv" ).load( sb.toString() ).withStrictQuotes(true).build();

        var nextLine = c.readNext();
        assertEquals(3, arrayLen(nextLine));

        assertEquals("a", nextLine[1]);
        assertEquals(1, len(nextLine[1]));

        assertEquals("1234567", nextLine[2]);
        assertEquals("c", nextLine[3]);
    }

    public void function testBug106ParseLineWithCarriageReturnNewLineStrictQuotes() throws IOException {

        var sb = createObject("java", "java.lang.StringBuilder").init( javaCast("int", 1024) );

        sb.append("""a"",""123#chr(13)##chr(10)#4567"",""c""").append(LINE_SEPARATOR); // "a","123\r\n4567","c"

        // public CSVReader(Reader reader, char separator, char quotechar, char escape, int line, boolean strictQuotes,
        // boolean ignoreLeadingWhiteSpace, boolean keepCarriageReturn)
        var c = getInstance( "CSVReader@cfboomOpencsv" ).load( sb.toString() ).withStrictQuotes(true).withKeepCarriageReturn(true).build();
        //CSVReader c = new CSVReader(new StringReader(sb.toString()), CSVParser.DEFAULT_SEPARATOR, CSVParser.DEFAULT_QUOTE_CHARACTER, CSVParser.DEFAULT_ESCAPE_CHARACTER,
        //        CSVReader.DEFAULT_SKIP_LINES, true, CSVParser.DEFAULT_IGNORE_LEADING_WHITESPACE, true);

        var nextLine = c.readNext();
        assertEquals(3, arrayLen(nextLine));

        assertEquals("a", nextLine[1]);
        assertEquals(1, len(nextLine[1]));

        assertEquals("123#chr(13)##chr(10)#4567", nextLine[2]);
        assertEquals("c", nextLine[3]);
    }

    public void function testIssue2992134OutOfPlaceQuotes() throws IOException {
        var sb = createObject("java", "java.lang.StringBuilder").init( javaCast("int", 1024) );

        // sb.append("a,b,c,ddd\\\"eee\nf,g,h,\"iii,jjj\"");
        sb.append("a,b,c,ddd\""eee#LINE_SEPARATOR#f,g,h,""iii,jjj""");

        var c = getInstance( "CSVReader@cfboomOpencsv" ).load( sb.toString() ).build();

        var nextLine = c.readNext();

        assertEquals("a", nextLine[1]);
        assertEquals("b", nextLine[2]);
        assertEquals("c", nextLine[3]);
        assertEquals("ddd""eee", nextLine[4]);
    }

    //@Test(expected = UnsupportedOperationException.class)
    public void function testQuoteAndEscapeMustBeDifferent() {
        var sb = createObject("java", "java.lang.StringBuilder").init( javaCast("int", 1024) );

        sb.append("a,b,c,ddd\\""eee\nf,g,h,""iii,jjj""");

        // new CSVReader(new StringReader(sb.toString()), CSVParser.DEFAULT_SEPARATOR, CSVParser.DEFAULT_QUOTE_CHARACTER, CSVParser.DEFAULT_QUOTE_CHARACTER, CSVReader.DEFAULT_SKIP_LINES, CSVParser.DEFAULT_STRICT_QUOTES, CSVParser.DEFAULT_IGNORE_LEADING_WHITESPACE);
        try {
            var c = getInstance( "CSVReader@cfboomOpencsv" ).load( sb.toString() ).withQuoteChar('"').withEscapeChar('"').build();
            fail("Should have thrown java.lang.UnsupportedOperationException.");
        } catch (any ex) {
            if (ex.type != "java.lang.UnsupportedOperationException") {
                fail("Should have thrown java.lang.UnsupportedOperationException.");
            }
        }
    }

    //@Test(expected = UnsupportedOperationException.class)
    public void function testSeparatorAndEscapeMustBeDifferent() {
        var sb = createObject("java", "java.lang.StringBuilder").init( javaCast("int", 1024) );

        sb.append("a,b,c,ddd\\""eee\nf,g,h,""iii,jjj""");

        // new CSVReader(new StringReader(sb.toString()), CSVParser.DEFAULT_SEPARATOR, CSVParser.DEFAULT_QUOTE_CHARACTER, CSVParser.DEFAULT_SEPARATOR, CSVReader.DEFAULT_SKIP_LINES, CSVParser.DEFAULT_STRICT_QUOTES, CSVParser.DEFAULT_IGNORE_LEADING_WHITESPACE);
        try {
            var c = getInstance( "CSVReader@cfboomOpencsv" ).load( sb.toString() ).withSeparator(',').withEscapeChar(',').build();
            fail("Should have thrown java.lang.UnsupportedOperationException.");
        } catch (any ex) {
            if (ex.type != "java.lang.UnsupportedOperationException") {
                fail("Should have thrown java.lang.UnsupportedOperationException.");
            }
        }
    }

    //@Test(expected = UnsupportedOperationException.class)
    public void function testSeparatorAndQuoteMustBeDifferent() {
        var sb = createObject("java", "java.lang.StringBuilder").init( javaCast("int", 1024) );

        sb.append("a,b,c,ddd\\""eee\nf,g,h,""iii,jjj""");

        //new CSVReader(new StringReader(sb.toString()), CSVParser.DEFAULT_SEPARATOR, CSVParser.DEFAULT_SEPARATOR, CSVParser.DEFAULT_ESCAPE_CHARACTER, CSVReader.DEFAULT_SKIP_LINES, CSVParser.DEFAULT_STRICT_QUOTES, CSVParser.DEFAULT_IGNORE_LEADING_WHITESPACE);
        try {
            var c = getInstance( "CSVReader@cfboomOpencsv" ).load( sb.toString() ).withSeparator(',').withQuoteChar(',').build();
            fail("Should have thrown java.lang.UnsupportedOperationException.");
        } catch (any ex) {
            if (ex.type != "java.lang.UnsupportedOperationException") {
                fail("Should have thrown java.lang.UnsupportedOperationException.");
            }
        }
    }

    /**
     * Tests iterating over a reader.
     *
     * @throws IOException if the reader fails.
     */
    public void function testIteratorFunctionality() {
        var expectedResult = [];
        arrayAppend(expectedResult, ["a", "b", "c"]);
        arrayAppend(expectedResult, ["a", "b,b,b", "c"]);
        arrayAppend(expectedResult, ["", "", ""]);
        arrayAppend(expectedResult, ["a", "PO Box 123,#LINE_SEPARATOR#Kippax,ACT. 2615.#LINE_SEPARATOR#Australia", "d."]);
        arrayAppend(expectedResult, ["Glen ""The Man"" Smith", "Athlete", "Developer"]);
        arrayAppend(expectedResult, ["""""", "test"]);
        arrayAppend(expectedResult, ["a#LINE_SEPARATOR#b", "b", "#LINE_SEPARATOR#d", "e"]);

        var idx = 1;
        var it = csvr.iterator();
        while (it.hasNext()) {
            var line = it.next();
            var expectedLine = expectedResult[idx++];
            assertArrayEquals(expectedLine, line);
        }
    }

    public void function testCanCloseReader() {
        csvr.close();
    }

    public void function testCanCreateIteratorFromReader() {
        $assert.notNull(csvr.iterator());
    }

    public void function testIssue102() {
        var csvReader = getInstance( "CSVReader@cfboomOpencsv" ).load( """"",a#LINE_SEPARATOR#"""",b#LINE_SEPARATOR#" ).build();

        var firstRow = csvReader.readNext();
        assertEquals(2, arrayLen(firstRow));
        assertTrue(firstRow[1].isEmpty());
        assertEquals("a", firstRow[2]);

        var secondRow = csvReader.readNext();
        assertEquals(2, arrayLen(secondRow));
        assertTrue(secondRow[1].isEmpty());
        assertEquals("b", secondRow[2]);
    }

    public void function testFeatureRequest60ByDefaultEmptyFieldsAreBlank() {
        var sb = createObject("java", "java.lang.StringBuilder").init( javaCast("int", 1024) );

        sb.append(",,,"""",");

        var csvReader = getInstance( "CSVReader@cfboomOpencsv" ).load( sb.toString() ).build();

        var row = csvReader.readNext();

        assertEquals(5, arrayLen(row));
        assertEquals("", row[1]);
        assertEquals("", row[2]);
        assertEquals("", row[3]);
        assertEquals("", row[4]);
        assertEquals("", row[5]);
    }

    public void function testFeatureRequest60TreatEmptyFieldsAsNull() {

        var sb = createObject("java", "java.lang.StringBuilder").init( javaCast("int", 1024) );

        sb.append(",,,"""",");

        var csvReader = getInstance( "CSVReader@cfboomOpencsv" ).load( sb.toString() ).withFieldAsNull(CSVReaderNullFieldIndicator.EMPTY_SEPARATORS).build();

        var items = csvReader.readNext();

        assertEquals(5, arrayLen(items));
        var idx = 0;
        for (var item in items) {
            idx++;
            if (idx == 1) {
                assertTrue(isNull(item));
            } else if (idx == 2) {
                assertTrue(isNull(item));
            } else if (idx == 3) {
                assertTrue(isNull(item));
            } else if (idx == 4) {
                assertEquals("", item);
            } else if (idx == 5) {
                assertTrue(isNull(item));
            }
        }
    }

    public void function testFeatureRequest60TreatEmptyDelimitedFieldsAsNull() {
        var sb = createObject("java", "java.lang.StringBuilder").init( javaCast("int", 1024) );

        sb.append(",,,"""",");

        var csvReader = getInstance( "CSVReader@cfboomOpencsv" ).load( sb.toString() ).withFieldAsNull(CSVReaderNullFieldIndicator.EMPTY_QUOTES).build();

        var items = csvReader.readNext();

        assertEquals(5, arrayLen(items));
        var idx = 0;
        for (var item in items) {
            idx++;
            if (idx == 1) {
                assertEquals("", item);
            } else if (idx == 2) {
                assertEquals("", item);
            } else if (idx == 3) {
                assertEquals("", item);
            } else if (idx == 4) {
                assertTrue(isNull(item));
            } else if (idx == 5) {
                assertEquals("", item);
            }
        }
    }

    public void function testFeatureRequest60TreatEmptyFieldsDelimitedOrNotAsNull() {

        var sb = createObject("java", "java.lang.StringBuilder").init( javaCast("int", 1024) );

        sb.append(",,,"""",");

        var csvReader = getInstance( "CSVReader@cfboomOpencsv" ).load( sb.toString() ).withFieldAsNull(CSVReaderNullFieldIndicator.BOTH).build();

        var items = csvReader.readNext();

        assertEquals(5, arrayLen(items));
        var idx = 0;
        for (var item in items) {
            idx++;
            if (idx == 1) {
                assertTrue(isNull(item));
            } else if (idx == 2) {
                assertTrue(isNull(item));
            } else if (idx == 3) {
                assertTrue(isNull(item));
            } else if (idx == 4) {
                assertTrue(isNull(item));
            } else if (idx == 5) {
                assertTrue(isNull(item));
            }
        }
    }

    public void function testDBQueryWithHeaders() {
        var csvQuery = getInstance( "CSVReader@cfboomOpencsv" ).load( fileRead( expandPath("/tests/resources/all_types.csv") ) ).buildQuery();
        assertEquals(3, csvQuery.recordCount);

        var csvQueryMeta = getMetaData(csvQuery);
        assertEquals(31, arrayLen(csvQueryMeta));

        assertEquals("id", csvQueryMeta[1].name);
        assertEquals("INTEGER", csvQueryMeta[1].typeName);

        assertEquals("blob", csvQueryMeta[2].name);
        assertEquals("VARCHAR", csvQueryMeta[2].typeName);

        assertEquals("binary", csvQueryMeta[3].name);
        assertEquals("VARCHAR", csvQueryMeta[3].typeName);

        assertEquals("longblob", csvQueryMeta[4].name);
        assertEquals("VARCHAR", csvQueryMeta[4].typeName);

        assertEquals("mediumblob", csvQueryMeta[5].name);
        assertEquals("VARCHAR", csvQueryMeta[5].typeName);

        assertEquals("tinyblob", csvQueryMeta[6].name);
        assertEquals("VARCHAR", csvQueryMeta[6].typeName);

        assertEquals("varbinary", csvQueryMeta[7].name);
        assertEquals("VARCHAR", csvQueryMeta[7].typeName);

        assertEquals("date", csvQueryMeta[8].name);
        assertEquals("TIMESTAMP", csvQueryMeta[8].typeName);

        assertEquals("datetime", csvQueryMeta[9].name);
        assertEquals("TIMESTAMP", csvQueryMeta[9].typeName);

        assertEquals("time", csvQueryMeta[10].name);
        assertEquals("TIMESTAMP", csvQueryMeta[10].typeName);

        assertEquals("timestamp", csvQueryMeta[11].name);
        assertEquals("TIMESTAMP", csvQueryMeta[11].typeName);

        assertEquals("year", csvQueryMeta[12].name);
        assertEquals("TIMESTAMP", csvQueryMeta[12].typeName);

        assertEquals("bigint", csvQueryMeta[13].name);
        assertEquals("DOUBLE", csvQueryMeta[13].typeName);

        assertEquals("decimal", csvQueryMeta[14].name);
        assertEquals("DOUBLE", csvQueryMeta[14].typeName);

        assertEquals("double", csvQueryMeta[15].name);
        assertEquals("DOUBLE", csvQueryMeta[15].typeName);

        assertEquals("float", csvQueryMeta[16].name);
        assertEquals("TIMESTAMP", csvQueryMeta[16].typeName);

        assertEquals("int", csvQueryMeta[17].name);
        assertEquals("INTEGER", csvQueryMeta[17].typeName);

        assertEquals("mediumint", csvQueryMeta[18].name);
        assertEquals("INTEGER", csvQueryMeta[18].typeName);

        assertEquals("real", csvQueryMeta[19].name);
        assertEquals("DOUBLE", csvQueryMeta[19].typeName);

        assertEquals("smallint", csvQueryMeta[20].name);
        assertEquals("INTEGER", csvQueryMeta[20].typeName);

        assertEquals("tinyint", csvQueryMeta[21].name);
        assertEquals("INTEGER", csvQueryMeta[21].typeName);

        assertEquals("char", csvQueryMeta[22].name);
        assertEquals("VARCHAR", csvQueryMeta[22].typeName);

        assertEquals("nvarchar", csvQueryMeta[23].name);
        assertEquals("VARCHAR", csvQueryMeta[23].typeName);

        assertEquals("varchar", csvQueryMeta[24].name);
        assertEquals("VARCHAR", csvQueryMeta[24].typeName);

        assertEquals("longtext", csvQueryMeta[25].name);
        assertEquals("VARCHAR", csvQueryMeta[25].typeName);

        assertEquals("mediumtext", csvQueryMeta[26].name);
        assertEquals("VARCHAR", csvQueryMeta[26].typeName);

        assertEquals("text", csvQueryMeta[27].name);
        assertEquals("VARCHAR", csvQueryMeta[27].typeName);

        assertEquals("tinytext", csvQueryMeta[28].name);
        assertEquals("VARCHAR", csvQueryMeta[28].typeName);

        assertEquals("bit", csvQueryMeta[29].name);
        assertEquals("BIT", csvQueryMeta[29].typeName);

        assertEquals("enum", csvQueryMeta[30].name);
        assertEquals("VARCHAR", csvQueryMeta[30].typeName);

        assertEquals("set", csvQueryMeta[31].name);
        assertEquals("VARCHAR", csvQueryMeta[31].typeName);
    }
}