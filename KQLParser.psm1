Function Parse-LogAnalyticsJson 
{   
    [CmdletBinding()]
    [OutputType([Object])]
    Param (
        [parameter(Mandatory=$true)]
        [object]$table
    )
    
    $ds = new-object System.Data.DataSet
    $ds.Tables.Add("tblTemp")

    Foreach($column in $table.columns)
    {
        try{[void]$ds.Tables["tblTemp"].Columns.Add($column.name,[type]$("System.$($column.type)"))}
        catch{[void]$ds.Tables["tblTemp"].Columns.Add($column.ColumnName,[string])}
    }

    Foreach($row in $table.rows)
    {
        $ds.Tables["tblTemp"].Rows.Add($row) | Out-Null
    }


    $ds.Tables["tblTemp"]
}

Function ConvertFrom-LogAnalyticsJson
{
<#
.SYNOPSIS
    Use to parse the result JSON from a KQL query returned from the Log Analytics API

.DESCRIPTION
    This function will parse the results of a KQL query returned from the Log Analytics API dated Oct 2017 or later. 
    When returning the data from the API you should use Invoke-WebRequest and pass the information from the ‘Content’ property
	
.PARAMETER JSON
    The JSON string returned by the API

.NOTES
    This function was written using the “2017-01-01-preview” API with the property ‘”Prefer”:”response-v1=true”’ 
    in the header to simulate the response that will be present once the “2017-10-01” API, as soon as it is released.

    For details on how to get this return data refer to the Log Analytics REST API documentation at https://dev.loganalytics.io/
#>   
    [CmdletBinding()]
    [OutputType([Object])]
    Param (
        [parameter(Mandatory=$true)]
        [string]$JSON
    )

    $results = ConvertFrom-LogAnalyticsJson $JSON
    $output = @()
    if(@($results.Tables).count -gt 1)
    {
        Foreach($table in $results.Tables)
        {
            $tableOut = Parse-LogAnalyticsJson $table
            $output += New-Object psobject -Property @{Table=$table.TableName;Data=$tableOut}
        }
    }
    else
    {
        $output = Parse-LogAnalyticsJson $results.Tables
    }
    $output
}

Function Parse-AppInsightsJson 
{   
    [CmdletBinding()]
    [OutputType([Object])]
    Param (
        [parameter(Mandatory=$true)]
        [object]$table
    )
    
    $ds = new-object System.Data.DataSet
    $ds.Tables.Add("tblTemp")

    Foreach($column in $table.columns)
    {
        try{[void]$ds.Tables["tblTemp"].Columns.Add($column.ColumnName,[type]$("System.$($column.DataType)"))}
        catch{[void]$ds.Tables["tblTemp"].Columns.Add($column.ColumnName,[string])}
    }

    Foreach($row in $table.rows)
    {
        $ds.Tables["tblTemp"].Rows.Add($row) | Out-Null
    }


    $ds.Tables["tblTemp"]
}

Function ConvertFrom-AppInsightsJson
{
<#
.SYNOPSIS
    Use to parse the result JSON from a KQL query returned from the Application Insights API

.DESCRIPTION
    This function will parse the results of a KQL query returned from the Application Insights API dated Oct 2017 or later. 
    When returning the data from the API you should use Invoke-WebRequest and pass the information from the ‘Content’ property
	
.PARAMETER JSON
    The JSON string returned by the API

.NOTES
    For details on how to get this return data refer to the Application Insights REST API documentation at https://dev.applicationinsights.io

#> 
    [CmdletBinding()]
    [OutputType([Object])]
    Param (
        [parameter(Mandatory=$true)]
        [string]$JSON
    )

    $results = ConvertFrom-Json $JSON
    $output = @()
    if(@($results.Tables).count -gt 1)
    {
        Foreach($table in $results.Tables)
        {
            $tableOut = Parse-AppInsightsJson $table
            $output += New-Object psobject -Property @{Table=$table.TableName;Data=$tableOut}
        }
    }
    else
    {
        $output = Parse-AppInsightsJson $results.Tables
    }
    $output
}



Export-ModuleMember ConvertFrom-LogAnalyticsJson, ConvertFrom-AppInsightsJson