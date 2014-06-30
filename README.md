OffensiveFirewall
=================


#### Usage:
```
<!--- application.cfc --->

<cfcomponent displayname="Application">
  <cffunction name="onApplicationStart">
		<cfset application.offensiveFirewall = createObject("component", "OffensiveFirewall")/>
	</cffunction>


  <cffunction name="onRequestStart">
  		<cfargument name="requestname" required="true" />		
  		
  		<cfset offensiveFilter()/>
  </cffunction>
  
  <cfscript>
  		
  		public void function offensiveFilter() output="false"{
  			request.offensiveFilter = {};
  			
  			// Url Scope
  			if(isdefined("url")){
  				request.offensiveFilter.url = application.offensiveFirewall.scan(url);
  			}
  			
  			// Form Scope
  			if(isdefined("form")){
  				request.offensiveFilter.form = application.offensiveFirewall.scan(form);
  			}
  			
  		}
  	
  </cfscript>
</cfcomponent>
```
