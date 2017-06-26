/*
 * Copyright 2016 Joel Tobey <joeltobey@gmail.com>
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
 * @author Joel Tobey
 */
component {

    // Module Properties
    this.title              = "cfboom opencsv";
    this.author             = "Joel Tobey";
    this.webURL             = "https://github.com/joeltobey/cfboom-opencsv";
    this.description        = "The cfboom-opencsv module provides a wrapper facade to the opencsv project (http://opencsv.sourceforge.net).";
    this.version            = "1.1.0";
    // If true, looks for views in the parent first, if not found, then in the module. Else vice-versa
    this.viewParentLookup   = true;
    // If true, looks for layouts in the parent first, if not found, then in module. Else vice-versa
    this.layoutParentLookup = true;
    // Module Entry Point
    this.entryPoint         = "cfboom/opencsv";
    // Model Namespace
    this.modelNamespace     = "cfboomOpencsv";
    // CF Mapping
    this.cfmapping          = "cfboom/opencsv";
    // Auto-map models
    this.autoMapModels      = false;
    // Module Dependencies
    this.dependencies       = [ "cfboom-lang", "cfboom-util" ];

    function configure(){

        // module settings - stored in modules.name.settings
        settings = {
            // The default `Sanitizer` used when building a query
            "defaultSanitizer" = "cfboom.opencsv.PassthroughSanitizer"
        };

        // Binder Mappings
        binder.map("CSVReader@cfboomOpencsv").to("cfboom.opencsv.CSVReader");
        binder.map("CSVWriter@cfboomOpencsv").to("cfboom.opencsv.CSVWriter");
    }

    /**
     * Fired when the module is registered and activated.
     */
    function onLoad() {
        try {
            createObject("java", "com.opencsv.CSVParserBuilder");
        } catch (any ex) {
            // If jar isn't loaded directly, try using javaLoader (it will fail if module isn't loaded)
            wirebox.getInstance( "loader@cbjavaloader" ).appendPaths( modulePath & "/lib" );
        }
    }

    /**
     * Fired when the module is unregistered and unloaded
     */
    function onUnload() {}

}