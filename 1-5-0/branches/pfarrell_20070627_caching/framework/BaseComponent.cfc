<!---
License:
Copyright 2007 GreatBizTools, LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Copyright: GreatBizTools, LLC
$Id$

Created version: 1.0.10
Updated version: 1.1.0

MachComponent:
Base Mach-II component.

Notes:
The BaseComponent extended by Listener, EventFilter and Plugin components and gives
quick access to things such as announcing a new event or getting/setting properties.

- Implemented accessors to access the PropertyManager instead of direct name space
calling. (pfarrell)
- Deprecated hasParameter(). Duplicate method isParameterDefined is more inline with
the rest of the framework. (pfarrell)
--->
<cfcomponent
	displayname="Mach-II Base Component"
	output="false"
	hint="Base Mach-II component.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.appManager = "" />
	<cfset variables.parameters = StructNew() />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="void" output="false"
		hint="Used by the framework for initialization. Do not override.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true"
			hint="The framework instances' AppManager." />
		<cfargument name="parameters" type="struct" required="false" default="#StructNew()#"
			hint="The initial set of configuration parameters." />
		
		<!--- PropertyManager be in set after AppManager --->
		<cfset setAppManager(arguments.appManager) />
		<cfset setParameters(arguments.parameters) />
	</cffunction>

	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Override to provide custom configuration logic. Called after init().">
		<!--- Override to provide custom configuration logic. Called after init(). --->
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->	
	<cffunction name="announceEvent" access="public" returntype="void" output="false"
		hint="Announces a new event to the framework.">
		<cfargument name="eventName" type="string" required="true"
			hint="The name of the event to announce." />
		<cfargument name="eventArgs" type="struct" required="false" default="#StructNew()#"
			hint="A struct of arguments to set as the event's args." />
		
		<cfif StructKeyExists(request, "_MachIIRequestHandler_#getAppManager().getAppLoader().getAppKey()#")>
			<cfset request["_MachIIRequestHandler_#getAppManager().getAppLoader().getAppKey()#"].getEventContext().announceEvent(arguments.eventName, arguments.eventArgs) />
		<cfelse>
			<cfthrow message="The RequestHandler is necessary to announce events is not set in 'request['_MachIIRequestHandler_#getAppManager().getAppLoader().getAppKey()#']'" />
		</cfif>
	</cffunction>
	
	<cffunction name="announceEventInModule" access="public" returntype="void" output="false"
		hint="Announces a new event to the framework.">
		<cfargument name="moduleName" type="string" required="true"
			hint="The name of the module in which event exists." />
		<cfargument name="eventName" type="string" required="true"
			hint="The name of the event to announce." />
		<cfargument name="eventArgs" type="struct" required="false" default="#StructNew()#"
			hint="A struct of arguments to set as the event's args." />
		
		<cfif StructKeyExists(request, "_MachIIRequestHandler_#getAppManager().getAppLoader().getAppKey()#")>
			<cfset request["_MachIIRequestHandler_#getAppManager().getAppLoader().getAppKey()#"].getEventContext().announceEvent(arguments.eventName, arguments.eventArgs, arguments.moduleName) />
		<cfelse>
			<cfthrow message="The RequestHandler is necessary to announce events is not set in 'request['_MachIIRequestHandler_#getAppManager().getAppLoader().getAppKey()#']'" />
		</cfif>
	</cffunction>
	
	<cffunction name="buildUrl" access="public" returntype="string" output="false"
		hint="Builds a framework specific url and automatically escapes entities for html display.">
		<cfargument name="eventName" type="string" required="true"
			hint="Name of the event to build the url with." />
		<cfargument name="urlParameters" type="any" required="false" default=""
			hint="Name/value pairs (urlArg1=value1|urlArg2=value2) to build the url with or a struct of data." />
		<cfargument name="urlBase" type="string" required="false" default=""
			hint="Base of the url. Defaults to the value of the urlBase property." />
		<cfreturn getAppManager().getRequestManager().buildUrl(argumentcollection=arguments) />
	</cffunction>
	
	<cffunction name="buildUrlToModule" access="public" returntype="string" output="false"
		hint="Builds a framework specific url and automatically escapes entities for html display.">
		<cfargument name="moduleName" type="string" required="true"
			hint="Name of the module to build the url with. Defaults to current module if empty string." />
		<cfargument name="eventName" type="string" required="true"
			hint="Name of the event to build the url with." />
		<cfargument name="urlParameters" type="any" required="false" default=""
			hint="Name/value pairs (urlArg1=value1|urlArg2=value2) to build the url with or a struct of data." />
		<cfargument name="urlBase" type="string" required="false" default=""
			hint="Base of the url. Defaults to the value of the urlBase property." />
		
		<!--- Pull the current module name if empty string (we use the request scope so we do not
			pollute the variables scope which is shared in the views) --->
		<cfif NOT Len(arguments.moduleName)>
			<cfset argument.moduleName = request.event.getModuleName() />
		</cfif>
		<cfreturn getAppManager().getRequestManager().buildUrl(argumentcollection=arguments) />
	</cffunction>
	
	<cffunction name="setParameter" access="public" returntype="void" output="false"
		hint="Sets a configuration parameter.">
		<cfargument name="name" type="string" required="true"
			hint="The parameter name." />
		<cfargument name="value" required="true"
			hint="The parameter value." />
		<cfset variables.parameters[arguments.name] = arguments.value />
	</cffunction>
	<cffunction name="getParameter" access="public" returntype="any" output="false"
		hint="Gets a configuration parameter value, or a default value if not defined.">
		<cfargument name="name" type="string" required="true"
			hint="The parameter name." />
		<cfargument name="defaultValue" type="string" required="false" default=""
			hint="The default value to return if the parameter is not defined. Defaults to a blank string." />
		<cfif isParameterDefined(arguments.name)>
			<cfreturn bindValue(arguments.name) />
		<cfelse>
			<cfreturn arguments.defaultValue />
		</cfif>
	</cffunction>
	<cffunction name="isParameterDefined" access="public" returntype="boolean" output="false"
		hint="Checks to see whether or not a configuration parameter is defined.">
		<cfargument name="name" type="string" required="true"
			hint="The parameter name." />
		<cfreturn StructKeyExists(variables.parameters, arguments.name) />
	</cffunction>
	<cffunction name="hasParameter" access="public" returntype="boolean" output="false"
		hint="DEPRECATED - use isParameterDefined() instead. Checks to see whether or not a configuration parameter is defined.">
		<cfargument name="name" type="string" required="true"
			hint="The parameter name." />
		
		<cftry>
			<cfthrow type="MachII.framework.deprecatedMethod"
				message="The hasParameter() method has been deprecated. Please use isParameterDefined() instead." />
			<cfcatch type="MachII.framework.deprecatedMethod">
				<!--- Do nothing --->
			</cfcatch> 
		</cftry>
		
		<cfreturn StructKeyExists(variables.parameters, arguments.name) />
	</cffunction>

	<cffunction name="getProperty" access="public" returntype="any" output="false"
		hint="Gets the specified property - this is just a shortcut for getPropertyManager().getProperty()">
		<cfargument name="propertyName" type="string" required="true"
			hint="The name of the property to return."/>
		<cfreturn getPropertyManager().getProperty(arguments.propertyName) />
	</cffunction>
	<cffunction name="setProperty" access="public" returntype="any" output="false"
		hint="Sets the specified property - this is just a shortcut for getPropertyManager().setProperty()">
		<cfargument name="propertyName" type="string" required="true"
			hint="The name of the property to set."/>
		<cfargument name="propertyValue" type="any" required="true" 
			hint="The value to store in the property." />
		<cfreturn getPropertyManager().setProperty(arguments.propertyName, arguments.propertyValue) />
	</cffunction>

	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="bindValue" access="private" returntype="any" output="false"
		hint="Binds placeholders values in parameters.">
		<cfargument name="parameterName" type="string" required="true"
			hint="The parameter name." />
		
		<cfset var propertyName = "" />
		<cfset var value = variables.parameters[arguments.parameterName] />
		
		<!--- Can only bind simple parameter values --->
		<cfif IsSimpleValue(value) AND REFindNoCase("\${(.)*?}", value)>
			<cfset propertyName = Mid(value, 3, Len(value) -3) />
			<cfif getPropertyManager().isPropertyDefined(propertyName)>
				<cfset value = getProperty(propertyName) />
			<cfelse>
				<cfthrow type="MachII.framework.ProperyNotDefinedToBindToParameter" 
					message="The required property is not defined to bind to a parameter named '#arguments.parameterName#'." />
			</cfif>
		</cfif>
		
		<cfreturn value />
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="setParameters" access="public" returntype="void" output="false"
		hint="Sets the full set of configuration parameters for the component.">
		<cfargument name="parameters" type="struct" required="true" />
		
		<cfset var key = "" />
		
		<cfloop collection="#arguments.parameters#" item="key">
			<cfset setParameter(key, parameters[key]) />
		</cfloop>
	</cffunction>
	<cffunction name="getParameters" access="public" returntype="struct" output="false"
		hint="Gets the full set of configuration parameters for the component.">
		
		<cfset var key = "" />
		<cfset var resolvedParameters = StructNew() />
		
		<!--- Get values and bind placeholders --->
		<cfloop collection="#variables.parameters#" item="key">
			<cfset resolvedParameters[key] = bindValue(key) />
		</cfloop>
		
		<cfreturn resolvedParameters />
	</cffunction>
	
	<cffunction name="setAppManager" access="private" returntype="void" output="false"
		hint="Sets the components AppManager instance.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true"
			hint="The AppManager instance to set." />
		<cfset variables.appManager = arguments.appManager />
	</cffunction>
	<cffunction name="getAppManager" access="package" returntype="MachII.framework.AppManager" output="false"
		hint="Gets the components AppManager instance.">
		<cfreturn variables.appManager />
	</cffunction>
	
	<cffunction name="getPropertyManager" access="package" returntype="MachII.framework.PropertyManager" output="false"
		hint="Gets the components PropertyManager instance.">
		<cfreturn getAppManager().getPropertyManager() />
	</cffunction>

</cfcomponent>