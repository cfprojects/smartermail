<cfset ServiceURL = "*** URL OF WEB SERVICES (WITHOUT THE '/Services/...') ***">
<cfset AuthUserName = "*** DOMAIN ADMIN ACCOUNT ***">
<cfset AuthPassword = "*** DOMAIN ADMIN PASSWORD ***">
<cfset DomainName = "*** YOUR DOMAIN NAME ***">

<cfset smartermail = createObject("component","smartermail").init(ServiceURL,AuthUserName,AuthPassword,DomainName)>

<cfif isDefined("form.addUser")>
	<cfset didItWork = smartermail.addUser(form.UserName,form.Password,form.FirstName,form.LastName)>
	<cfif didItWork.result>SUCCESS! Account Added<cfelse>ERROR! <cfoutput>#didItWork.message#</cfoutput></cfif>
<cfelseif isDefined("url.deleteUser")>
	<cfset didItWork = smartermail.deleteUser(url.deleteUser)>
	<cfif didItWork.result>SUCCESS! Account '<cfoutput>#url.deleteUser#</cfoutput>' Removed<cfelse>ERROR! <cfoutput>#didItWork.message#</cfoutput></cfif>
</cfif>

<!--- LIST ALL ACCOUNTS --->
<cfset allAccounts = smartermail.getUsers()>
<cfoutput>
<h1>List All Accounts</h1>
<table cellpadding="2" cellspacing="0" border="1">
<cfloop from="1" to="#arrayLen(allAccounts)#" index="i">
<tr><td>#allAccounts[i].UserName#</td><td>#allAccounts[i].FirstName#</td><td>#allAccounts[i].LastName#</td><td><a href="#cgi.script_name#?deleteUser=#urlEncodedFormat(allAccounts[i].UserName)#" onclick="return confirm('Are you sure you wish to delete the user \'#allAccounts[i].UserName#\'?');">Delete User</a></td></tr>
</cfloop>
</table><br />
<form action="#cgi.script_name#" method="post">
Username: <input type="text" name="UserName" size="30" /><br />
Password: <input type="text" name="Password" size="30" /><br />
First Name: <input type="text" name="FirstName" size="30" /><br />
Last Name: <input type="text" name="LastName" size="30" /><br />
<input type="submit" name="addUser" value="Add User Account" />
</form>
</cfoutput>
