# KQLParser
KQL Json Parser for the Log Analytics and Application Insights API

# Description
This function will parse the results of a KQL query returned from the Log Analytics  and the Application Insights APIs dated Oct 2017 or later. When returning the data from the API you should use Invoke-WebRequest and pass the information from the ‘Content’ property.

# Install
You can install this module from the [PowerShell Gallery](https://www.powershellgallery.com/packages/KQLParser)
```PowerShell
Install-Module -Name KQLParser
```

# API
Refer to each solution API documentation for details on getting your return data

[Application Insights REST API](https://dev.applicationinsights.io)

[Azure Log Analytics REST API](https://dev.loganalytics.io/)
