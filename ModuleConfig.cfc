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
    this.title              = "cfboom HTTP";
    this.author             = "Joel Tobey";
    this.webURL             = "https://github.com/joeltobey/cfboom-http";
    this.description        = "The cfboom-http module provides solid, consistent HTTP request and response handling.";
    this.version            = "1.0.0";
    // If true, looks for views in the parent first, if not found, then in the module. Else vice-versa
    this.viewParentLookup   = true;
    // If true, looks for layouts in the parent first, if not found, then in module. Else vice-versa
    this.layoutParentLookup = true;
    // Module Entry Point
    this.entryPoint         = "cfboom/http";
    // Model Namespace
    this.modelNamespace     = "cfboomHttp";
    // CF Mapping
    this.cfmapping          = "cfboom/http";
    // Auto-map models
    this.autoMapModels      = false;
    // Module Dependencies
    this.dependencies       = [ "cfboom-lang" ];

    function configure(){

        // module settings - stored in modules.name.settings
        settings = {
            // The HttpRequestExecutor used by the BasicHttpClient by default
            "httpRequestExecutor" = "cfboom.http.protocol.BasicHttpRequestExecutor"
        };

        // Binder Mappings
        binder.map("BasicHttpClient@cfboomHttp").to("cfboom.http.client.BasicHttpClient");

        // Need to map cfboom.http.HttpStatus with noInit(). Otherwise, the factory method mapping
        // will try to autowire it and attempt to do the init() method.
        binder.map("cfboom.http.HttpStatus").to("cfboom.http.HttpStatus").noInit();
        binder.map("HttpStatus@cfboomHttp").toFactoryMethod("cfboom.http.HttpStatus", "enum").asSingleton().noInit();
    }

    /**
     * Fired when the module is registered and activated.
     */
    function onLoad(){
    	// parse parent settings
		parseParentSettings();
    }

    /**
     * Fired when the module is unregistered and unloaded
     */
    function onUnload(){}

    private function parseParentSettings() {
        // Read parent application config
        var oConfig         = controller.getSetting( "ColdBoxConfig" );
        var parentSettings  = oConfig.getPropertyMixin( "cfboomHttp", "variables", {} );
        var configStruct    = controller.getConfigSettings();
        var moduleSettings  = configStruct.modules['cfboom-http'].settings;

        if (structKeyExists(parentSettings, "httpRequestExecutor") && len(parentSettings.httpRequestExecutor)) {
            moduleSettings['httpRequestExecutor'] = parentSettings.httpRequestExecutor;
        }
    }

}