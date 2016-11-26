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
 * A data sanitizer for CSV data
 */
interface  displayname="Interface Sanitizer"
{
    /**
     * @data.hint Data from one CSV cell
     * @schema.hint Option definition of the column name and type of the CSV cell of data. Example: {"name":"username","type":"varchar"}
     */
    public any function sanatize(required any data, struct schema);
}