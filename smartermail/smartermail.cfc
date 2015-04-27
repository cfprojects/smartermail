<cfcomponent name="smartermail" displayname="SmarterMail REST Wrapper v1.2">

<!---
SmarterMail REST Wrapper

Written by Joe Danziger (joe@ajaxcf.com).  See the readme for more
details on usage and methods.

Version 1.3 - Released: November 28, 2007
You can now manage domain alias - thanks to Igor Ilyinsky.
Added SmarterMail 4 compatibility - thanks to Rick Germany.
--->

	<cfset variables.ServiceURL = "">
	<cfset variables.AuthUserName = "">
	<cfset variables.AuthPassword = "">
	<cfset variables.DomainName = "">

	<cffunction name="init" access="public" returntype="smartermail" output="false"
				hint="Returns an instance of the CFC initialized.">
		<cfargument name="ServiceURL" type="string" required="true" hint="URL of REST Web Service (without the '/Services/...').">			
		<cfargument name="AuthUserName" type="string" required="true" hint="Username for REST account.">
		<cfargument name="AuthPassword" type="string" required="true" hint="Password for REST account.">
		<cfargument name="DomainName" type="string" required="true" hint="Domain name to administer.">
		
		<cfset variables.ServiceURL = arguments.ServiceURL>
		<cfset variables.AuthUserName = arguments.AuthUserName>
		<cfset variables.AuthPassword = arguments.AuthPassword>
		<cfset variables.DomainName = arguments.DomainName>
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getAliases" access="public" output="false" returntype="array" 
			description="List all aliases.">
	
		<cfhttp method="GET" url="#variables.ServiceURL#/Services/svcAliasAdmin.asmx/GetAliases">
			<cfhttpparam type="Header" name="charset" value="utf-8" />
		    <cfhttpparam type="Header" name="Accept-Encoding" value="deflate;q=0" />
		    <cfhttpparam type="Header" name="TE" value="deflate;q=0" />			
			<cfhttpparam type="formfield" name="AuthUserName" value="#variables.AuthUserName#">
			<cfhttpparam type="formfield" name="AuthPassword" value="#variables.AuthPassword#">
			<cfhttpparam type="formfield" name="DomainName" value="#variables.DomainName#">
		</cfhttp>

		<cfset data = xmlParse(cfhttp.FileContent)>
		<cfset aliases = xmlSearch(data, "//:AliasInfo")>
		
		<!--- create array and insert values from XML --->
		<cfset allAliases = arrayNew(1)>
		<cfloop index="x" from="1" to="#arrayLen(aliases)#">
		   <cfset alias = aliases[x]>
		   <cfset thisAlias = structNew()>
		   <cfset thisAlias.Name = alias.Name.xmlText>
		   <cfset thisAlias.FwdTo = alias.Addresses.string.xmlText>
		   <cfset arrayAppend(allAliases, thisAlias)>   
		</cfloop>

		<cfreturn allAliases>
	</cffunction>

	<cffunction name="getAlias" access="public" output="false" returntype="array" 
			description="Get a specific alias.">
		<cfargument name="AliasName" type="string" required="true">
	
		<cfhttp method="GET" url="#variables.ServiceURL#/Services/svcAliasAdmin.asmx/GetAlias">
			<cfhttpparam type="Header" name="charset" value="utf-8" />
		    <cfhttpparam type="Header" name="Accept-Encoding" value="deflate;q=0" />
		    <cfhttpparam type="Header" name="TE" value="deflate;q=0" />
			<cfhttpparam type="formfield" name="AuthUserName" value="#variables.AuthUserName#">
			<cfhttpparam type="formfield" name="AuthPassword" value="#variables.AuthPassword#">
			<cfhttpparam type="formfield" name="DomainName" value="#variables.DomainName#">
			<cfhttpparam type="formfield" name="AliasName" value="#arguments.AliasName#">
		</cfhttp>

		<cfset data = xmlParse(cfhttp.FileContent)>
		<cfset aliases = xmlSearch(data, "//:string")>
		
		<!--- create array and insert values from XML --->
		<cfset userAliases = arrayNew(1)>
		<cfloop index="x" from="1" to="#arrayLen(aliases)#">
		   <cfset alias = aliases[x]>
		   <cfset thisAlias = structNew()>
		   <cfset thisAlias.Address = alias.XmlText>
		   <cfset arrayAppend(userAliases, thisAlias)>   
		</cfloop>
		
		<cfreturn userAliases>
	</cffunction>
	
	<cffunction name="addAlias" access="public" output="true" returntype="struct" 
			description="Adds an address to an alias.">
		<cfargument name="AliasName" type="string" required="true">
		<cfargument name="Addresses" type="string" required="true">

		<cfhttp method="GET" url="#variables.ServiceURL#/Services/svcAliasAdmin.asmx/AddAlias">
			<cfhttpparam type="Header" name="charset" value="utf-8" />
		    <cfhttpparam type="Header" name="Accept-Encoding" value="deflate;q=0" />
		    <cfhttpparam type="Header" name="TE" value="deflate;q=0" />
			<cfhttpparam type="formfield" name="AuthUserName" value="#variables.AuthUserName#">
			<cfhttpparam type="formfield" name="AuthPassword" value="#variables.AuthPassword#">
			<cfhttpparam type="formfield" name="DomainName" value="#variables.DomainName#">
			<cfhttpparam type="formfield" name="AliasName" value="#arguments.AliasName#">
			<cfloop LIST="#arguments.Addresses#" index="a">
				<cfhttpparam type="formfield" name="Addresses" value="#a#">
			</cfloop>
		</cfhttp>

		<cfset data = xmlParse(cfhttp.FileContent)>
		
		<cfset thisResult = structNew()>
		<cfset thisResult.Result = data.GenericResult.XmlChildren[1].XmlText>
		<cfset thisResult.ResultCode = data.GenericResult.XmlChildren[2].XmlText>
		<cfset thisResult.Message = data.GenericResult.XmlChildren[3].XmlText>
	
		<cfreturn thisResult>
	</cffunction>
	
	<cffunction name="updateAlias" access="public" output="false" returntype="struct" 
			description="Updates an alias to specific addresses.">
		<cfargument name="AliasName" type="string" required="true">
		<cfargument name="Addresses" type="string" required="true">

		<cfhttp method="GET" url="#variables.ServiceURL#/Services/svcAliasAdmin.asmx/UpdateAlias">
			<cfhttpparam type="Header" name="charset" value="utf-8" />
		    <cfhttpparam type="Header" name="Accept-Encoding" value="deflate;q=0" />
		    <cfhttpparam type="Header" name="TE" value="deflate;q=0" />			
			<cfhttpparam type="formfield" name="AuthUserName" value="#variables.AuthUserName#">
			<cfhttpparam type="formfield" name="AuthPassword" value="#variables.AuthPassword#">
			<cfhttpparam type="formfield" name="DomainName" value="#variables.DomainName#">
			<cfhttpparam type="formfield" name="AliasName" value="#arguments.AliasName#">
			<cfloop list="#arguments.Addresses#" index="a">
				<cfhttpparam type="formfield" name="Addresses" value="#a#">
			</cfloop>
		</cfhttp>

		<cfset data = xmlParse(cfhttp.FileContent)>
		
		<cfset thisResult = structNew()>
		<cfset thisResult.Result = data.GenericResult.XmlChildren[1].XmlText>
		<cfset thisResult.ResultCode = data.GenericResult.XmlChildren[2].XmlText>
		<cfset thisResult.Message = data.GenericResult.XmlChildren[3].XmlText>
	
		<cfreturn thisResult>
	</cffunction>
	
	<cffunction name="deleteAlias" access="public" output="false" returntype="struct" 
			description="Deletes an alias.">
		<cfargument name="AliasName" type="string" required="true">

		<cfhttp method="GET" url="#variables.ServiceURL#/Services/svcAliasAdmin.asmx/DeleteAlias">
			<cfhttpparam type="Header" name="charset" value="utf-8" />
		    <cfhttpparam type="Header" name="Accept-Encoding" value="deflate;q=0" />
		    <cfhttpparam type="Header" name="TE" value="deflate;q=0" />			
			<cfhttpparam type="formfield" name="AuthUserName" value="#variables.AuthUserName#">
			<cfhttpparam type="formfield" name="AuthPassword" value="#variables.AuthPassword#">
			<cfhttpparam type="formfield" name="DomainName" value="#variables.DomainName#">
			<cfhttpparam type="formfield" name="AliasName" value="#arguments.AliasName#">
		</cfhttp>

		<cfset data = xmlParse(cfhttp.FileContent)>
		
		<cfset thisResult = structNew()>
		<cfset thisResult.Result = data.GenericResult.XmlChildren[1].XmlText>
		<cfset thisResult.ResultCode = data.GenericResult.XmlChildren[2].XmlText>
		<cfset thisResult.Message = data.GenericResult.XmlChildren[3].XmlText>
	
		<cfreturn thisResult>
	</cffunction>
	
	<cffunction name="getUsers" access="public" output="false" returntype="array" 
			description="Gets all mail users.">

		<cfhttp method="GET" url="#variables.ServiceURL#/Services/svcUserAdmin.asmx/GetUsers">
			<cfhttpparam type="Header" name="charset" value="utf-8" />
		    <cfhttpparam type="Header" name="Accept-Encoding" value="deflate;q=0" />
		    <cfhttpparam type="Header" name="TE" value="deflate;q=0" />			
			<cfhttpparam type="formfield" name="AuthUserName" value="#variables.AuthUserName#">
			<cfhttpparam type="formfield" name="AuthPassword" value="#variables.AuthPassword#">
			<cfhttpparam type="formfield" name="DomainName" value="#variables.DomainName#">
		</cfhttp>

		<cfset data = xmlParse(cfhttp.FileContent)>
		<cfset accounts = xmlSearch(data, "//:UserInfo")>
		
		<!--- create array and insert values from XML --->
		<cfset userAccounts = arrayNew(1)>
		<cfloop index="x" from="1" to="#arrayLen(accounts)#">
		   <cfset account = accounts[x]>
		   <cfset thisAccount = structNew()>
		   <cfset thisAccount.UserName = account.UserName.XmlText>
		   <cfset thisAccount.Password = account.Password.XmlText>
		   <cfset thisAccount.FirstName = account.FirstName.XmlText>
		   <cfset thisAccount.LastName = account.LastName.XmlText>
		   <cfset arrayAppend(userAccounts, thisAccount)>   
		</cfloop>
		
		<cfreturn userAccounts>
	</cffunction>	
	
	<cffunction name="addUser" access="public" output="false" returntype="struct" 
			description="Adds a new mail user.">
		<cfargument name="NewUsername" type="string" required="true">
		<cfargument name="NewPassword" type="string" required="true">
		<cfargument name="FirstName" type="string" required="true">
		<cfargument name="LastName" type="string" required="true">
		<cfargument name="maxMailboxSize" type="numeric" required="false" default="25">
		<cfargument name="IsDomainAdmin" type="string" required="false" default="false">

		<cfhttp method="GET" url="#variables.ServiceURL#/Services/svcUserAdmin.asmx/AddUser2">
			<cfhttpparam type="Header" name="charset" value="utf-8" />
		    <cfhttpparam type="Header" name="Accept-Encoding" value="deflate;q=0" />
		    <cfhttpparam type="Header" name="TE" value="deflate;q=0" />			
			<cfhttpparam type="formfield" name="AuthUserName" value="#variables.AuthUserName#">
			<cfhttpparam type="formfield" name="AuthPassword" value="#variables.AuthPassword#">
			<cfhttpparam type="formfield" name="DomainName" value="#variables.DomainName#">
			<cfhttpparam type="formfield" name="NewUsername" value="#arguments.NewUsername#">
			<cfhttpparam type="formfield" name="NewPassword" value="#arguments.NewPassword#">
			<cfhttpparam type="formfield" name="FirstName" value="#arguments.FirstName#">
			<cfhttpparam type="formfield" name="LastName" value="#arguments.LastName#">
			<cfhttpparam type="formfield" name="IsDomainAdmin" value="#arguments.IsDomainAdmin#">
			<cfhttpparam type="formfield" name="maxMailboxSize" value="#arguments.maxMailboxSize#">
		</cfhttp>

		<cfset data = xmlParse(cfhttp.FileContent)>
		
		<cfset thisResult = structNew()>
		<cfset thisResult.Result = data.GenericResult.XmlChildren[1].XmlText>
		<cfset thisResult.ResultCode = data.GenericResult.XmlChildren[2].XmlText>
		<cfset thisResult.Message = data.GenericResult.XmlChildren[3].XmlText>
	
		<cfreturn thisResult>
	</cffunction>
	
	<cffunction name="deleteUser" access="public" output="false" returntype="struct" 
			description="Deletes a mail user.">
		<cfargument name="UserName" type="string" required="true">

		<cfhttp method="GET" url="#variables.ServiceURL#/Services/svcUserAdmin.asmx/DeleteUser">
			<cfhttpparam type="Header" name="charset" value="utf-8" />
		    <cfhttpparam type="Header" name="Accept-Encoding" value="deflate;q=0" />
		    <cfhttpparam type="Header" name="TE" value="deflate;q=0" />			
			<cfhttpparam type="formfield" name="AuthUserName" value="#variables.AuthUserName#">
			<cfhttpparam type="formfield" name="AuthPassword" value="#variables.AuthPassword#">
			<cfhttpparam type="formfield" name="DomainName" value="#variables.DomainName#">
			<cfhttpparam type="formfield" name="UserName" value="#arguments.UserName#">
		</cfhttp>

		<cfset data = xmlParse(cfhttp.FileContent)>
		
		<cfset thisResult = structNew()>
		<cfset thisResult.Result = data.GenericResult.XmlChildren[1].XmlText>
		<cfset thisResult.ResultCode = data.GenericResult.XmlChildren[2].XmlText>
		<cfset thisResult.Message = data.GenericResult.XmlChildren[3].XmlText>
	
		<cfreturn thisResult>
	</cffunction>	
	
	<cffunction name="getDomainAliases" access="public" output="false" returntype="array" 
			description="Gets all Domain Aliases.">

		<cfhttp method="GET" URL="#variables.ServiceURL#/Services/svcDomainAliasAdmin.asmx/GetAliases">
			<cfhttpparam type="Header" name="charset" value="utf-8" />
		    <cfhttpparam type="Header" name="Accept-Encoding" value="deflate;q=0" />
		    <cfhttpparam type="Header" name="TE" value="deflate;q=0" />			
			<cfhttpparam type="formfield" name="AuthUserName" value="#variables.AuthUserName#">
			<cfhttpparam type="formfield" name="AuthPassword" value="#variables.AuthPassword#">
			<cfhttpparam type="formfield" name="DomainName" value="#variables.DomainName#">
		</cfhttp>

		<cfset data = xmlParse(cfhttp.FileContent)>
		<cfset Domains = xmlSearch(data, "//:string")>
		
		<!--- create array and insert values from XML --->
		<cfset domainNames = arrayNew(1)>
		<cfloop index="x" from="1" to="#arrayLen(Domains)#">
		   <cfset Domain = Domains[x]>
		   <cfset arrayAppend(domainNames, Domain.xmlText)>   
		</cfloop>
				
		<cfreturn domainNames>
	</cffunction>	
	
	<cffunction name="addDomainAlias" access="public" output="false" returntype="struct" 
			description="Adds a new domain alias.">
		<cfargument name="NewDomain" type="string" required="true">

		<cfhttp method="GET" URL="#variables.ServiceURL#/Services/svcDomainAliasAdmin.asmx/AddDomainAlias">
			<cfhttpparam type="Header" name="charset" value="utf-8" />
		    <cfhttpparam type="Header" name="Accept-Encoding" value="deflate;q=0" />
		    <cfhttpparam type="Header" name="TE" value="deflate;q=0" />	
			<cfhttpparam type="formfield" name="AuthUserName" value="#variables.AuthUserName#">
			<cfhttpparam type="formfield" name="AuthPassword" value="#variables.AuthPassword#">
			<cfhttpparam type="formfield" name="DomainName" value="#variables.DomainName#">
			<cfhttpparam type="formfield" name="DomainAliasName" value="#arguments.NewDomain#">
		</cfhttp>

		<cfset data = xmlParse(cfhttp.FileContent)>
		
		<cfset thisResult = structNew()>
		<cfset thisResult.Result = data.GenericResult.XmlChildren[1].XmlText>
		<cfset thisResult.ResultCode = data.GenericResult.XmlChildren[2].XmlText>
		<cfset thisResult.Message = data.GenericResult.XmlChildren[3].XmlText>
	
		<cfreturn thisResult>
	</cffunction>
	
	<cffunction name="deleteDomainAlias" access="public" output="false" returntype="struct" 
			description="Deletes a Domain Alias.">
		<cfargument name="Domain" type="string" required="true">

		<cfhttp method="GET" URL="#variables.ServiceURL#/Services/svcDomainAliasAdmin.asmx/DeleteDomainAlias">
			<cfhttpparam type="Header" name="charset" value="utf-8" />
		    <cfhttpparam type="Header" name="Accept-Encoding" value="deflate;q=0" />
		    <cfhttpparam type="Header" name="TE" value="deflate;q=0" />			
			<cfhttpparam type="formfield" name="AuthUserName" value="#variables.AuthUserName#">
			<cfhttpparam type="formfield" name="AuthPassword" value="#variables.AuthPassword#">
			<cfhttpparam type="formfield" name="DomainName" value="#variables.DomainName#">
			<cfhttpparam type="formfield" name="DomainAliasName" value="#arguments.Domain#">
		</cfhttp>

		<cfset data = xmlParse(cfhttp.FileContent)>
		
		<cfset thisResult = structNew()>
		<cfset thisResult.Result = data.GenericResult.XmlChildren[1].XmlText>
		<cfset thisResult.ResultCode = data.GenericResult.XmlChildren[2].XmlText>
		<cfset thisResult.Message = data.GenericResult.XmlChildren[3].XmlText>
	
		<cfreturn thisResult>
	</cffunction>	
	
</cfcomponent>