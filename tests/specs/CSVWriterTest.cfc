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
	displayname="Class CSVWriterTests"
	output="false"
{
	// this will run once after initialization and before setUp()
	public void function beforeAll() {
		super.beforeAll();
		variables['CSVWriter'] = createObject("java", "com.opencsv.CSVWriter");
		LINE_SEPARATOR = createObject("java", "java.lang.System").getProperty("line.separator");
	}

	// this will run before every single test in this test case
	public void function setUp() {
		super.setup();
		var cArgs = {};
		cArgs['separator'] = ",";
		cArgs['quotechar'] = "'";
		variables['csvw'] = new cfboom.opencsv.CSVWriter(argumentCollection:cArgs);
	}

	// this will run after every single test in this test case
	public void function reset() {
		super.reset();
		structDelete(variables, "csvw");
	}

	// this will run once after all tests have been run
	public void function afterAll() {
		super.afterAll();
	}

	/**
	 * Test routine for converting output to a string.
	 *
	 * @param args the elements of a line of the cvs file
	 * @return a String version
	 * @throws IOException if there are problems writing
	 */
	private string function invokeWriter(array args) {
		var sw = createObject("java", "java.io.StringWriter").init();
		var cArgs = {};
		cArgs['writer'] = sw;
		cArgs['separator'] = ",";
		cArgs['quotechar'] = "'";
		var csvw = new cfboom.opencsv.CSVWriter(argumentCollection:cArgs);
		csvw.writeNext(args);
		return sw.toString();
	}

	private string function invokeNoEscapeWriter(array args) {
		var sw = createObject("java", "java.io.StringWriter").init();
		var cArgs = {};
		cArgs['writer'] = sw;
		cArgs['separator'] = CSVWriter.DEFAULT_SEPARATOR;
		cArgs['quotechar'] = "'";
		cArgs['escapechar'] = CSVWriter.NO_ESCAPE_CHARACTER;
		var csvw = new cfboom.opencsv.CSVWriter(argumentCollection:cArgs);
		csvw.writeNext(args);
		return sw.toString();
	}

	public void function testCorrectlyParseNullString() {
		var sw = createObject("java", "java.io.StringWriter").init();
		var cArgs = {};
		cArgs['writer'] = sw;
		var csvw = new cfboom.opencsv.CSVWriter(argumentCollection:cArgs);
		csvw.writeNext(javaCast("null", ""));
		assertEquals(0, len(sw.toString()));
	}

	public void function testCorrectlyParserNullObject() {
		var sw = createObject("java", "java.io.StringWriter").init();
		var cArgs = {};
		cArgs['writer'] = sw;
		var csvw = new cfboom.opencsv.CSVWriter(argumentCollection:cArgs);
		csvw.writeNext(javaCast("null", ""), false);
		assertEquals(0, len(sw.toString()));
	}

	/**
	 * Tests parsing individual lines.
	 *
	 * @throws IOException if the reader fails.
	 */
	public void function testParseLine() {

		// test normal case
		var normal = ["a", "b", "c"];
		var output = invokeWriter(normal);
		assertEquals("'a','b','c'#LINE_SEPARATOR#", output);

		// test quoted commas
		var quoted = ["a", "b,b,b", "c"];
		output = invokeWriter(quoted);
		assertEquals("'a','b,b,b','c'#LINE_SEPARATOR#", output);

		// test empty elements
		var empty = [javaCast("null", "")];
		output = invokeWriter(empty);
		assertEquals(LINE_SEPARATOR, output);

		// test multiline quoted
		var multiline = ["This is a #LINE_SEPARATOR# multiline entry", "so is #LINE_SEPARATOR# this"];
		output = invokeWriter(multiline);
		assertEquals("'This is a #LINE_SEPARATOR# multiline entry','so is #LINE_SEPARATOR# this'#LINE_SEPARATOR#", output);


		// test quoted line
		var quoteLine = ["This is a "" multiline entry", "so is #LINE_SEPARATOR# this"];
		output = invokeWriter(quoteLine);
		assertEquals("'This is a """" multiline entry','so is #LINE_SEPARATOR# this'#LINE_SEPARATOR#", output);
	}

	public void function testSpecialCharacters() {
		// test quoted line
		var quoteLine = ["This is a #chr(10)# multiline entry", "so is #LINE_SEPARATOR# this"];
		var output = invokeWriter(quoteLine);
		assertEquals("'This is a #chr(10)# multiline entry','so is #LINE_SEPARATOR# this'#LINE_SEPARATOR#", output);
	}

	public void function testParseLineWithBothEscapeAndQuoteChar() {
		// test quoted line
		var quoteLine = ["This is a 'multiline' entry", "so is #LINE_SEPARATOR# this"];
		var output = invokeWriter(quoteLine);
		assertEquals("'This is a ""'multiline""' entry','so is #LINE_SEPARATOR# this'#LINE_SEPARATOR#", output);
	}

	/**
	 * Tests parsing individual lines.
	 *
	 * @throws IOException if the reader fails.
	 */
	public void function testParseLineWithNoEscapeChar() {

		// test normal case
		var normal = ["a", "b", "c"];
		var output = invokeNoEscapeWriter(normal);
		assertEquals("'a','b','c'#LINE_SEPARATOR#", output);

		// test quoted commas
		var quoted = ["a", "b,b,b", "c"];
		output = invokeNoEscapeWriter(quoted);
		assertEquals("'a','b,b,b','c'#LINE_SEPARATOR#", output);

		// test empty elements
		var empty = [javaCast("null", "")];
		output = invokeNoEscapeWriter(empty);
		assertEquals(LINE_SEPARATOR, output);

		// test multiline quoted
		var multiline = ["This is a #LINE_SEPARATOR# multiline entry", "so is #LINE_SEPARATOR# this"];
		output = invokeNoEscapeWriter(multiline);
		assertEquals("'This is a #LINE_SEPARATOR# multiline entry','so is #LINE_SEPARATOR# this'#LINE_SEPARATOR#", output);
	}

	public void function testParseLineWithNoEscapeCharAndQuotes() throws IOException {
		var quoteLine = ["This is a "" 'multiline' entry", "so is #LINE_SEPARATOR# this"];
		var output = invokeNoEscapeWriter(quoteLine);
		assertEquals("'This is a "" 'multiline' entry','so is #LINE_SEPARATOR# this'#LINE_SEPARATOR#", output);
	}


	/**
	 * Test writing to a list.
	 *
	 * @throws IOException if the reader fails.
	 */
	public void function testWriteAll() {

		var allElements = [];
		var line1 = listToArray("Name##Phone##Email", "##");
		var line2 = listToArray("Glen##1234##glen@abcd.com", "##");
		var line3 = listToArray("John##5678##john@efgh.com", "##");
		arrayAppend(allElements, line1);
		arrayAppend(allElements, line2);
		arrayAppend(allElements, line3);

		var sw = createObject("java", "java.io.StringWriter").init();
		var csvw = new cfboom.opencsv.CSVWriter(sw);
		csvw.writeAll(allElements);

		var result = sw.toString();
		var lines = result.split(LINE_SEPARATOR);

		assertEquals(3, arrayLen(lines));
	}

	/**
	 * Test writing from a list.
	 *
	 * @throws IOException if the reader fails.
	 */
	public void function testWriteAllObjects() {

		var allElements = [];
		var line1 = listToArray("Name##Phone##Email", "##");
		var line2 = listToArray("Glen##1234##glen@abcd.com", "##");
		var line3 = listToArray("John##5678##john@efgh.com", "##");
		arrayAppend(allElements, line1);
		arrayAppend(allElements, line2);
		arrayAppend(allElements, line3);

		var sw = createObject("java", "java.io.StringWriter").init();
		var csvw = new cfboom.opencsv.CSVWriter(sw);
		csvw.writeAll(allElements, false);

		var result = sw.toString();
		var lines = result.split(LINE_SEPARATOR);

		assertEquals(3, arrayLen(lines));

		var values = lines[2].split(",");
		assertEquals("1234", values[2]);
	}

	/**
	 * Tests the option of having omitting quotes in the output stream.
	 *
	 * @throws IOException if bad things happen
	 */
	public void function testNoQuoteChars() {

		var line = ["Foo", "Bar", "Baz"];
		var sw = createObject("java", "java.io.StringWriter").init();
		var csvw = new cfboom.opencsv.CSVWriter(sw, CSVWriter.DEFAULT_SEPARATOR, CSVWriter.NO_QUOTE_CHARACTER);
		csvw.writeNext(line);
		var result = sw.toString();

		assertEquals("Foo,Bar,Baz#LINE_SEPARATOR#", result);
	}

	/**
	 * Tests the option of having omitting quotes in the output stream.
	 *
	 * @throws IOException if bad things happen
	 */
	public void function testNoQuoteCharsAndNoEscapeChars() {

		var line = ["Foo", "Bar", "Baz"];
		var sw = createObject("java", "java.io.StringWriter").init();
		var csvw = new cfboom.opencsv.CSVWriter(sw, CSVWriter.DEFAULT_SEPARATOR, CSVWriter.NO_QUOTE_CHARACTER, CSVWriter.NO_ESCAPE_CHARACTER);
		csvw.writeNext(line);
		var result = sw.toString();

		assertEquals("Foo,Bar,Baz#LINE_SEPARATOR#", result);
	}

	/**
	 * Tests the ability for the writer to apply quotes only where strings contain the separator, escape, quote or new line characters.
	 */
	public void function testIntelligentQuotes() {
		var line = ["1", "Foo", "With,Separator", "Line#LINE_SEPARATOR#Break", "Hello ""Foo Bar"" World", "Bar"];
		var sw = createObject("java", "java.io.StringWriter").init();
		var csvw = new cfboom.opencsv.CSVWriter(sw, CSVWriter.DEFAULT_SEPARATOR, CSVWriter.DEFAULT_QUOTE_CHARACTER, CSVWriter.DEFAULT_ESCAPE_CHARACTER);
		csvw.writeNext(line, false);
		var result = sw.toString();

		assertEquals("1,Foo,""With,Separator"",""Line#LINE_SEPARATOR#Break"",""Hello """"Foo Bar"""" World"",Bar#LINE_SEPARATOR#", result);
	}


	/**
	 * Test null values.
	 *
	 * @throws IOException if bad things happen
	 */
	public void function testNullValues() {

		var line = ["Foo", javaCast("null", ""), "Bar", "baz"];
		var sw = createObject("java", "java.io.StringWriter").init();
		var csvw = new cfboom.opencsv.CSVWriter(sw);
		csvw.writeNext(line);
		var result = sw.toString();

		assertEquals("""Foo"",,""Bar"",""baz""#LINE_SEPARATOR#", result);
	}

	public void function testStreamFlushing() {

		var WRITE_FILE = "myfile.csv";

		var nextLine = ["aaaa", "bbbb", "cccc", "dddd"];

		var fileWriter = createObject("java", "java.io.FileWriter").init(WRITE_FILE);
		var writer = new cfboom.opencsv.CSVWriter(fileWriter);

		writer.writeNext(nextLine);

		// If this line is not executed, it is not written in the file.
		writer.close();
	}

	public void function testAlternateEscapeChar() {
		var line = ["Foo", "bar's"];
		var sw = createObject("java", "java.io.StringWriter").init();
		var csvw = new cfboom.opencsv.CSVWriter(sw, CSVWriter.DEFAULT_SEPARATOR, CSVWriter.DEFAULT_QUOTE_CHARACTER, '''');
		csvw.writeNext(line);
		assertEquals("""Foo"",""bar''s""#LINE_SEPARATOR#", sw.toString());
	}

	public void function testEmbeddedQuoteInString() {
		var line = ["Foo", "I choose a \""hero\"" for this adventure"];
		var sw = createObject("java", "java.io.StringWriter").init();
		var csvw = new cfboom.opencsv.CSVWriter(sw, CSVWriter.DEFAULT_SEPARATOR, CSVWriter.DEFAULT_QUOTE_CHARACTER, CSVWriter.NO_ESCAPE_CHARACTER);
		csvw.writeNext(line);
		assertEquals("""Foo"",""I choose a \""hero\"" for this adventure""#LINE_SEPARATOR#", sw.toString());
	}

	public void function testNoQuotingNoEscaping() {
		var line = ["""Foo"",""Bar"""];
		var sw = createObject("java", "java.io.StringWriter").init();
		var csvw = new cfboom.opencsv.CSVWriter(sw, CSVWriter.DEFAULT_SEPARATOR, CSVWriter.NO_QUOTE_CHARACTER, CSVWriter.NO_ESCAPE_CHARACTER);
		csvw.writeNext(line);
		assertEquals("""Foo"",""Bar""#LINE_SEPARATOR#", sw.toString());
	}

	public void function testNestedQuotes() {
		var data = ["""""", "test"];
		var oracle = """"""""""""",""test""#LINE_SEPARATOR#";

		var writer = javaCast("null", "");
		var tempFile = javaCast("null", "");
		var fwriter = javaCast("null", "");
		var File = createObject("java", "java.io.File");

		try {
			tempFile = File.createTempFile("csvWriterTest", ".csv");
			tempFile.deleteOnExit();
			fwriter = createObject("java", "java.io.FileWriter").init(tempFile);
			writer = new cfboom.opencsv.CSVWriter(fwriter);
		} catch (IOException e) {
			fail();
		}

		// write the test data:
		writer.writeNext(data);

		try {
			writer.close();
		} catch (any e) {
			fail();
		}

		try {
			// assert that the writer was also closed.
			fwriter.flush();
			fail();
		} catch (any e) {
			// we should go through here..
		}

		// read the data and compare.
		var ins = javaCast("null", "");
		try {
			ins = createObject("java", "java.io.FileReader").init(tempFile);
		} catch (any e) {
			fail();
		}

		var fileContents = createObject("java", "java.lang.StringBuilder").init(CSVWriter.INITIAL_STRING_SIZE);
		try {
			var ch = ins.read();
			while (ch != -1) {
				fileContents.append(javaCast("char", ch));
				ch = ins.read();
			}
			ins.close();
		} catch (any e) {
			fail();
		}

		assertTrue(oracle.equals(fileContents.toString()));
	}

	public void function testAlternateLineFeeds() {
		var line = ["Foo", "Bar", "baz"];
		var sw = createObject("java", "java.io.StringWriter").init();
		var csvw = new cfboom.opencsv.CSVWriter(sw, CSVWriter.DEFAULT_SEPARATOR, CSVWriter.DEFAULT_QUOTE_CHARACTER, "\r");
		csvw.writeNext(line);
		var result = sw.toString();

		assertTrue(result.endsWith(chr(10)));
	}

	public void function testResultSetWithHeaders() {
		var header = ["Foo", "Bar", "baz"];
		var value = ["v1", "v2", "v3"];

		var sw = createObject("java", "java.io.StringWriter").init();
		var csvw = new cfboom.opencsv.CSVWriter(sw);

		//ResultSet rs = MockResultSetBuilder.buildResultSet(header, value, 1);
		var rs = queryNew("Foo,Bar,baz", "VarChar,VarChar,VarChar", [["v1", "v2", "v3"]]);

		var args = {};
		args['allLines'] = rs;
		args['includeColumnNames'] = true;
		var linesWritten = csvw.writeAll(argumentCollection:args); // don't need a result set since I am mocking the result.
		assertFalse(csvw.checkError());
		var result = sw.toString();

		$assert.notNull(result);
		assertEquals("""Foo"",""Bar"",""baz""#LINE_SEPARATOR#""v1"",""v2"",""v3""#LINE_SEPARATOR#", result);
		assertEquals(2, linesWritten);
	}

	public void function testMultiLineResultSetWithHeaders() {
		var header = ["Foo", "Bar", "baz"];
		var value = ["v1", "v2", "v3"];

		var sw = createObject("java", "java.io.StringWriter").init();
		var csvw = new cfboom.opencsv.CSVWriter(sw);

		//ResultSet rs = MockResultSetBuilder.buildResultSet(header, value, 3);
		var rs = queryNew("Foo,Bar,baz", "VarChar,VarChar,VarChar", [["v1", "v2", "v3"], ["v1", "v2", "v3"], ["v1", "v2", "v3"]]);

		var args = {};
		args['allLines'] = rs;
		args['includeColumnNames'] = true;
		var linesWritten = csvw.writeAll(argumentCollection:args); // don't need a result set since I am mocking the result.
		assertFalse(csvw.checkError());
		var result = sw.toString();

		assertTrue(!isNull(result));
		assertEquals("""Foo"",""Bar"",""baz""#LINE_SEPARATOR#""v1"",""v2"",""v3""#LINE_SEPARATOR#""v1"",""v2"",""v3""#LINE_SEPARATOR#""v1"",""v2"",""v3""#LINE_SEPARATOR#", result);
		assertEquals(4, linesWritten);
	}

	public void function testResultSetWithoutHeaders() {
		var header = ["Foo", "Bar", "baz"];
		var value = ["v1", "v2", "v3"];

		var sw = createObject("java", "java.io.StringWriter").init();
		var csvw = new cfboom.opencsv.CSVWriter(sw);

		//ResultSet rs = MockResultSetBuilder.buildResultSet(header, value, 1);
		var rs = queryNew("Foo,Bar,baz", "VarChar,VarChar,VarChar", [["v1", "v2", "v3"]]);

		var args = {};
		args['allLines'] = rs;
		args['includeColumnNames'] = false;
		var linesWritten = csvw.writeAll(argumentCollection:args); // don't need a result set since I am mocking the result.
		assertFalse(csvw.checkError());
		var result = sw.toString();

		assertTrue(!isNull(result));
		assertEquals("""v1"",""v2"",""v3""#LINE_SEPARATOR#", result);
		assertEquals(1, linesWritten);
	}

	public void function testMultiLineResultSetWithoutHeaders() {
		var header = ["Foo", "Bar", "baz"];
		var value = ["v1", "v2", "v3"];

		var sw = createObject("java", "java.io.StringWriter").init();
		var csvw = new cfboom.opencsv.CSVWriter(sw);

		//ResultSet rs = MockResultSetBuilder.buildResultSet(header, value, 3);
		var rs = queryNew("Foo,Bar,baz", "VarChar,VarChar,VarChar", [["v1", "v2", "v3"], ["v1", "v2", "v3"], ["v1", "v2", "v3"]]);

		var args = {};
		args['allLines'] = rs;
		args['includeColumnNames'] = false;
		var linesWritten = csvw.writeAll(argumentCollection:args); // don't need a result set since I am mocking the result.

		assertFalse(csvw.checkError());
		var result = sw.toString();

		assertTrue(!isNull(result));
		assertEquals("""v1"",""v2"",""v3""#LINE_SEPARATOR#""v1"",""v2"",""v3""#LINE_SEPARATOR#""v1"",""v2"",""v3""#LINE_SEPARATOR#", result);
		assertEquals(3, linesWritten);
	}

	public void function testResultSetTrim() {
		var header = ["Foo", "Bar", "baz"];
		var value = ["v1         ", "v2 ", "v3"];

		var sw = createObject("java", "java.io.StringWriter").init();
		var csvw = new cfboom.opencsv.CSVWriter(sw);

		//ResultSet rs = MockResultSetBuilder.buildResultSet(header, value, 1);
		var rs = queryNew("Foo,Bar,baz", "VarChar,VarChar,VarChar", [["v1         ", "v2 ", "v3"]]);

		var args = {};
		args['allLines'] = rs;
		args['includeColumnNames'] = true;
		args['trim'] = true;
		var linesWritten = csvw.writeAll(argumentCollection:args); // don't need a result set since I am mocking the result.
		assertFalse(csvw.checkError());
		var result = sw.toString();

		assertTrue(!isNull(result));
		assertEquals("""Foo"",""Bar"",""baz""#LINE_SEPARATOR#""v1"",""v2"",""v3""#LINE_SEPARATOR#", result);
		assertEquals(2, linesWritten);
	}

	public void function testDBQueryWithHeaders() {
		var sw = createObject("java", "java.io.StringWriter").init();
		var csvw = new cfboom.opencsv.CSVWriter(sw);

		var queryService = new query();
		queryService.setDatasource("jet_test");
		queryService.setSql("SELECT `id`, `created_at`, `updated_at`, `is_deleted`, `name`, `weight`, `email`, `birthdate`, `steps_taken`, `points`, `range`, `kudos`, `external_id`, `brief_bio` FROM `users`;");
		var rs = queryService.execute().getResult();

		var args = {};
		args['allLines'] = rs;
		args['includeColumnNames'] = true;
		args['convertToUTC'] = false; // DB stores dates in UTC; no need to do conversion
		var linesWritten = csvw.writeAll(argumentCollection:args);
		assertFalse(csvw.checkError());
		var result = sw.toString();

		var expected = '"id","created_at","updated_at","is_deleted","name","weight","email","birthdate","steps_taken","points","range","kudos","external_id","brief_bio"' &
		LINE_SEPARATOR &
		'"1","2016-03-16T05:42:26.000Z","2016-03-16T05:42:26.000Z","0.0","John Doe","215.25","test@email.com","1979-07-12","736252748837","1235.456","7652.24","235.4456","h","This is it."' &
		LINE_SEPARATOR &
		'"2","2015-10-15T16:59:48.774Z","2016-03-16T05:45:24.000Z","1.0","Joe Brown","175.00","","","678672.0","","","2221.0","i","     This has extra spaces.    "' & LINE_SEPARATOR;

		assertTrue(!isNull(result));
		assertEquals(expected, result);
		assertEquals(3, linesWritten);
	}

	public void function testDBQueryWithoutHeaders() {
		var sw = createObject("java", "java.io.StringWriter").init();
		var csvw = new cfboom.opencsv.CSVWriter(sw);

		var queryService = new query();
		queryService.setDatasource("jet_test");
		queryService.setSql("SELECT `id`, `created_at`, `updated_at`, `is_deleted`, `name`, `weight`, `email`, `birthdate`, `steps_taken`, `points`, `range`, `kudos`, `external_id`, `brief_bio` FROM `users`;");
		var rs = queryService.execute().getResult();

		var args = {};
		args['allLines'] = rs;
		args['includeColumnNames'] = false;
		args['convertToUTC'] = false; // DB stores dates in UTC; no need to do conversion
		var linesWritten = csvw.writeAll(argumentCollection:args); // don't need a result set since I am mocking the result.

		assertFalse(csvw.checkError());
		var result = sw.toString();

		var expected = '"1","2016-03-16T05:42:26.000Z","2016-03-16T05:42:26.000Z","0.0","John Doe","215.25","test@email.com","1979-07-12","736252748837","1235.456","7652.24","235.4456","h","This is it."' &
		LINE_SEPARATOR &
		'"2","2015-10-15T16:59:48.774Z","2016-03-16T05:45:24.000Z","1.0","Joe Brown","175.00","","","678672.0","","","2221.0","i","     This has extra spaces.    "' & LINE_SEPARATOR;

		assertTrue(!isNull(result));
		assertEquals(expected, result);
		assertEquals(2, linesWritten);
	}

	public void function testDBQueryTrim() {
		var sw = createObject("java", "java.io.StringWriter").init();
		var csvw = new cfboom.opencsv.CSVWriter(sw);

		var queryService = new query();
		queryService.setDatasource("jet_test");
		queryService.setSql("SELECT `id`, `created_at`, `updated_at`, `is_deleted`, `name`, `weight`, `email`, `birthdate`, `steps_taken`, `points`, `range`, `kudos`, `external_id`, `brief_bio` FROM `users`;");
		var rs = queryService.execute().getResult();

		var args = {};
		args['allLines'] = rs;
		args['includeColumnNames'] = true;
		args['convertToUTC'] = false; // DB stores dates in UTC; no need to do conversion
		args['trim'] = true;

		var linesWritten = csvw.writeAll(argumentCollection:args); // don't need a result set since I am mocking the result.
		assertFalse(csvw.checkError());
		var result = sw.toString();

		var expected = '"id","created_at","updated_at","is_deleted","name","weight","email","birthdate","steps_taken","points","range","kudos","external_id","brief_bio"' &
		LINE_SEPARATOR &
		'"1","2016-03-16T05:42:26.000Z","2016-03-16T05:42:26.000Z","0.0","John Doe","215.25","test@email.com","1979-07-12","736252748837","1235.456","7652.24","235.4456","h","This is it."' &
		LINE_SEPARATOR &
		'"2","2015-10-15T16:59:48.774Z","2016-03-16T05:45:24.000Z","1.0","Joe Brown","175.00","","","678672.0","","","2221.0","i","This has extra spaces."' & LINE_SEPARATOR;

		assertTrue(!isNull(result));
		assertEquals(expected, result);
		assertEquals(3, linesWritten);
	}

	public void function needToSetBothQuoteAndEscapeCharIfYouWantThemToBeTheSame() {
		var header = ["Foo", "Bar", "baz"];
		var value = ["v1", "v2'v2a", "v3"];

		var sw = createObject("java", "java.io.StringWriter").init();
		var csvw = new cfboom.opencsv.CSVWriter(sw, CSVWriter.DEFAULT_SEPARATOR, '\'', '\'');
		csvw.setResultService(createObject("java", "com.opencsv.ResultSetHelperService").init());

		//ResultSet rs = MockResultSetBuilder.buildResultSet(header, value, 1);
		var rs = queryNew("Foo,Bar,baz", "VarChar,VarChar,VarChar", [["v1", "v2'v2a", "v3"]]);

		var linesWritten = csvw.writeAll(rs, true, true); // don't need a result set since I am mocking the result.
		assertFalse(csvw.checkError());
		var result = sw.toString();

		assertTrue(!isNull(result));
		assertEquals("'Foo','Bar','baz'#LINE_SEPARATOR#'v1','v2''v2a','v3'#LINE_SEPARATOR#", result);
		assertEquals(2, linesWritten);
	}

	public void function issue123SeparatorEscapedWhenQuoteIsNoQuoteChar() {
		var header = ["Foo", "Bar", "baz"];
		var value = ["v1", "v2" & CSVWriter.DEFAULT_ESCAPE_CHARACTER & "v2a", "v3"];

		var lines = [];
		arrayAppend(lines, header);
		arrayAppend(lines, value);
		var sw = createObject("java", "java.io.StringWriter").init();
		var writer = new cfboom.opencsv.CSVWriter(sw, CSVWriter.DEFAULT_SEPARATOR, CSVWriter.NO_QUOTE_CHARACTER, CSVWriter.DEFAULT_ESCAPE_CHARACTER);
		writer.writeAll(lines);

		var result = sw.toString();
		assertTrue(!isNull(result));
		assertEquals("Foo,Bar,baz#LINE_SEPARATOR#v1,v2" & CSVWriter.DEFAULT_ESCAPE_CHARACTER & CSVWriter.DEFAULT_ESCAPE_CHARACTER & "v2a,v3#LINE_SEPARATOR#", result);
	}

	public void function issue123SeparatorEscapedWhenQuoteIsNoQuoteCharSpecifingNoneDefaultEscapeChar() {
		var header = ["Foo", "Bar", "baz"];
		var escapeCharacter = '\';
		var value = ["v1", "v2" & escapeCharacter & "v2a" & CSVWriter.DEFAULT_SEPARATOR & "v2b", "v3"];
		var lines = [];
		arrayAppend(lines, header);
		arrayAppend(lines, value);
		var sw = createObject("java", "java.io.StringWriter").init();
		var writer = new cfboom.opencsv.CSVWriter(sw, CSVWriter.DEFAULT_SEPARATOR, CSVWriter.NO_QUOTE_CHARACTER, escapeCharacter);
		writer.writeAll(lines);

		var result = sw.toString();
		$assert.notNull(result);
		assertEquals("Foo,Bar,baz#LINE_SEPARATOR#v1,v2" & escapeCharacter & escapeCharacter & "v2a" & escapeCharacter & CSVWriter.DEFAULT_SEPARATOR & "v2b,v3#LINE_SEPARATOR#", result);
	}
}