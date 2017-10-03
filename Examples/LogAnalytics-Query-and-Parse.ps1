# Get the Access Token for authentication
Function Get-AccessToken
{
    Param (
        [parameter(Mandatory=$true)]$tenantId,
        [parameter(Mandatory=$true)]$ClientID,
        [parameter(Mandatory=$true)]$ClientSecret
    )
    $TokenEndpoint = "https://login.windows.net/$tenantId/oauth2/token"
    $ARMResource = "https://management.core.windows.net/";

    $Body = @{
            'resource'= $ARMResource
            'client_id' = $ClientID
            'grant_type' = 'client_credentials'
            'client_secret' = $ClientSecret
    }

    $params = @{
        ContentType = 'application/x-www-form-urlencoded'
        Headers = @{'accept'='application/json'}
        Body = $Body
        Method = 'Post'
        URI = $TokenEndpoint
    }

    $token = Invoke-RestMethod @params

    Return $token
}

# Invoke the Web Request to perform the query
Function New-OMSLogSearch
{
    Param (
        [parameter(Mandatory=$true)][Guid]$ClientID,
        [parameter(Mandatory=$true)][string]$ClientSecret,
        [parameter(Mandatory=$true)][Guid]$tenantId,
        [parameter(Mandatory=$true)][Guid]$SubscriptionId,
        [parameter(Mandatory=$true)][string]$ResourceGroup,
        [parameter(Mandatory=$true)][string]$Workspace,
        [parameter(Mandatory=$true)][string]$Query
    )
    $token = Get-AccessToken -tenantId $tenantId -ClientID $ClientID -ClientSecret $ClientSecret
	$apiVersion = "2017-01-01-preview"
    $SubscriptionURI = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$($ResourceGroup)/providers/Microsoft.OperationalInsights/workspaces/$($Workspace)/api/query?api-version=$apiVersion"
	
    $json = ConvertTo-Json @{"timespan"="PT12H";query=$Query} # Timespan Last 12 hours
  
    $body = ([System.Text.Encoding]::UTF8.GetBytes($json))
    $params = @{
        Headers = @{'Content-Type'='application/json';
                    'authorization'="Bearer $($Token.access_token)"
                    'Prefer'='response-v1=true'}
        Body = $Body
        Method = 'Post'
        URI = $SubscriptionURI
    }

    try{$return = Invoke-WebRequest @params}
    catch {$errorCatch = $_; $errorCatch | FL * -f}

    Return $return
}

# Enter your information
$ClientID       = '' # App Registration ID
$ClientSecret   = '' # Key from App Registration
$tenantId       = '' # Your Azure tenant ID
$SubscriptionId = '' # Your Azure Subscription ID
$ResourceGroup  = '' # The resource group that contains your Log Analytics instance
$Workspace      = '' # The name of your Log Analytics instance

# The query to run
$Query = 'AzureActivity | summarize count() by Category'

# Get the query results
$LogSearch = New-OMSLogSearch -ClientID $ClientID -ClientSecret $ClientSecret -tenantId $TenantId -SubscriptionId $SubscriptionId -ResourceGroup $ResourceGroup -Workspace $Workspace -Query $Query

# Parse the results of the query
$logs = ConvertFrom-LogAnalyticsJson $LogSearch.Content
$logs