/*
The MIT License (MIT)

Copyright (c) 2014 Lyle Svendsen (@lylesvendsen)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the "Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the
following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial
portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Special Thanks To Olson: 
This script was made available with permission from Olson, a U.S. based loyalty and brand marketing firm. http://olson.com

*/

component displayName="xssFirewall" accessors="true" output="false"
{
	// Filtering Option Switches
	//property name="filterWordsOn" 		type="boolean" 		default=true;			// Allows select words to be filtered out
		
	// Replace for XSS filtered Text
	property name="invalidMarker" 		type="string" 		default="[FILTERED]";				// Replaces stripped items.						
	property name="wordFilterList"		type="string" 		default="shit,bitch,ass,fuck,fucking,whore,slut,asshole,cunt"; 	// List of Words To Be Filtered. Recommended Lists: https://github.com/shutterstock/List-of-Dirty-Naughty-Obscene-and-Otherwise-Bad-Words
	property name="ignoreFields" 		type="string" 		default="";					// Comma delimited list of fields not to scan
	
	
	variables.wordRegEx = "";
	
	public offensiveFirewall function init(string strWorldList="",string invalidMarker="") output="false"
	{
		if(len(trim(arguments.strWorldList))){
			setWordFilterList(arguments.strWorldList);
		}
		
		if(len(trim(arguments.invalidMarker))){
			setInvalidMarker(arguments.invalidMarker);
		}
		
		setWordRegEx(getWordFilterList());
		
		return this;
	}
	
	
	// scan
	public struct function scan(required struct scope, string ignore=""){
		local.results = {};
		
		// Get Filterable Keys
		local.filterKeys = getFilterableKeys(arguments.scope, arguments.ignore);
		
		// Get RegEx
		local.wordRegEx = getWordRegEx();
		
		// Loop Keys
		try{
			for(local.key IN local.filterKeys){
				local.strEval = arguments.scope[local.key];
				local.results[local.key] = getResponse(org:duplicate(local.strEval),cleanText:duplicate(local.strEval),isOffensive:false);
				
				// Scan simple values with length
				if(IsSimpleValue(local.strEval) && len(trim(local.strEval)) && !isNumeric(local.strEval)){
					// Filter Words
					if(REFindNoCase(local.wordRegEx,arguments.scope[local.key])){
						local.strEval = filterWords(local.strEval);
						arguments.scope[local.key] = local.strEval;
						local.results[local.key].cleanText = local.strEval;
						local.results[local.key].isOffensive = true;
					}
				}
			}
		}
		catch(exType ex){ 
		    // Log Failure
		    logError(ex);
		}
		
		return local.results;
	} 
	
		
	
	// filterWords
	public string function filterWords(required any keyVal){
		
		return REReplaceNoCase(arguments.keyVal,getWordRegEx(),getInvalidMarker(),"ALL");
	
	} 
	
		
	
	// logError
	private struct function logError(required struct exScope, string detail=""){
		
		try{
			 WriteLog(type="Error", file=getErrorLogFile(), text="[#arguments.exScope.type#] #arguments.exScope.message# | #arguments.detail#"); 
		}
		catch(exType ex){ 
		    // Log Failured
		}
		
		return local.results;
	} 
	
	
	
	// getFilterableKeys
	private array function getFilterableKeys(required struct scope, required string ignore){
		
		local.keyList = arraynew(1);
		local.ignoreFields = duplicate(getIgnoreFields());
		local.ignoreFields = listappend(local.ignoreFields,arguments.ignore);
		
		for(local.key IN arguments.scope){
			if(!listFindNoCase(local.ignoreFields,local.key)){
				arrayAppend(local.keyList,local.key);
			}
		}
		
		return local.keyList;
	} 
	
	// setWordList
	// Prepares and sets the world list for the regex replacement
	private void function setWordRegEx(required string wordList){
		local.wordRegEx = reEscape(arguments.wordList);
		local.wordRegEx = ListChangeDelims(local.wordRegEx,"|");
		local.wordRegEx = "\b(" & local.wordRegEx & ")(ing|es|ed|s|ey|y|iest|er|ers)?\b";
		
		variables.wordRegEx = local.wordRegEx;
	}
	
	
	private string function getWordRegEx(){
		return variables.wordRegEx;
	}
	
	
	
	
	// Pseudo Response Object
	private struct function getResponse(string org="", string cleanText="", boolean isOffensive=false){
		return {orgText=arguments.org,cleanText=arguments.cleanText,isOffensive=arguments.isOffensive};
	} 
	
		

}
