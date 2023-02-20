#region INFO
<# 
.SYNOPSIS
 
    Get-TeamsAssignedNumbers.ps1 collects assigned phone numbers from all Microsoft Teams.
 
.DESCRIPTION
    Author: Andrew Morpeth
    Contact: https://ucgeek.co/
    
    This script queries Microsoft Teams for assigned numbers and displays in a formatted table with the option to export to CSV. 
    During processing LineURI's are run against a regex pattern to extract the DDI/DID and the extension to a separate column.
    
    This script collects Microsoft Teams objects including:
    Users, Meeting Rooms, Online Application Instances (Resource Accounts)

    This script does not collect objects from on-premises environments even if in hybrid, instead use this script - https://gallery.technet.microsoft.com/office/Lync-Get-All-Assigned-8c1328a0
    
    This script is provided as-is, no warrenty is provided or implied.The author is NOT responsible for any damages or data loss that may occur
    through the use of this script.  Always test before using in a production environment. This script is free to use for both personal and 
    business use, however, it may not be sold or included as part of a package that is for sale. A Service Provider may include this script 
    as part of their service offering/best practices provided they only charge for their time to implement and support.

.RUN INSTRUCTIONS 
    If you haven’t already, you will need to install the Microsoft Teams PowerShell module - https://www.powershellgallery.com/packages/MicrosoftTeams
    Update settings "Settings" at the top of the script
    Run: .\Get-TeamsAssignedNumbers.ps1

    If you dont already have the Microsoft Teams PowerShell module installed, complete the following first:
    Install-Module -Name MicrosoftTeams -Force -AllowClobber

    Update existing Module using:
    Update-Module MicrosoftTeams

.NOTES
    v1.0 - Initial release       
    v1.1 - Now using Microsoft Teams PowerShell module
    v1.2 - Updated now unsupported aspects of the script
#>
#endregion INFO


Connect-MicrosoftTeams

#Settings ##############################
#. "_Settings.ps1" | Out-Null
$FileName = "TeamsAssignedNumbers_" + (Get-Date -Format s).replace(":","-") +".csv"
$FilePath = "D:\Temp\$FileName"
$OutputType = "CSV" #OPTIONS: CSV - Outputs CSV to specified FilePath, CONSOLE - Outputs to console
##############################

$Regex1 = '^(?:tel:)?(?:\+)?(\d+)(?:;ext=(\d+))?(?:;([\w-]+))?$'
$Array1 = @()
#Get Users with LineURI
$UsersLineURI = Get-CsOnlineUser -Filter {LineURI -ne $Null}
if($UsersLineURI -ne $null)
{
    Write-Host "Processing User Numbers"
    foreach($item in $UsersLineURI)
    {                  
        $Matches = @()
        $Item.LineURI -match $Regex1 | out-null
            
        $myObject1 = New-Object System.Object
        $myObject1 | Add-Member -type NoteProperty -name "LineURI" -Value $Item.LineURI
        $myObject1 | Add-Member -type NoteProperty -name "DDI" -Value $Matches[1]
        $myObject1 | Add-Member -type NoteProperty -name "Ext" -Value $Matches[2]
        $myObject1 | Add-Member -type NoteProperty -name "DisplayName" -Value $Item.DisplayName
        $myObject1 | Add-Member -type NoteProperty -name "FirstName" -Value $Item.FirstName
        $myObject1 | Add-Member -type NoteProperty -name "LastName" -Value $Item.LastName
        $myObject1 | Add-Member -type NoteProperty -name "Type" -Value "User"
        $Array1 += $myObject1          
    }
}

#Get meeting room numbers
Write-Host "Updated to MS Teams module. Get-CsMeetingRoom is no longer supported. We are looking for other reliable ways to achieve this. Assigned numbers may therefore be incomplete." -ForegroundColor Red
<#
$MeetingRoomLineURI = Get-CsMeetingRoom -Filter {LineURI -ne $Null}
if($MeetingRoomLineURI -ne $null)
{
	Write-Host "Processing Meeting Room Numbers"
    foreach($Item in $MeetingRoomLineURI)
    {                 
        $Matches = @()
        $Item.LineURI -match $Regex1 | out-null
            
        $myObject1 = New-Object System.Object
        $myObject1 | Add-Member -type NoteProperty -name "LineURI" -Value $Item.LineURI
        $myObject1 | Add-Member -type NoteProperty -name "DDI" -Value $Matches[1]
        $myObject1 | Add-Member -type NoteProperty -name "Ext" -Value $Matches[2]
        $myObject1 | Add-Member -type NoteProperty -name "DisplayName" -Value $Item.DisplayName
        $myObject1 | Add-Member -type NoteProperty -name "Type" -Value "MeetingRoom"
        $Array1 += $myObject1         
    }
}
#>

#Get online resource accounts
$OnlineApplicationInstanceLineURI = Get-CsOnlineApplicationInstance | where {$_.PhoneNumber -ne $Null}
if($OnlineApplicationInstanceLineURI -ne $null)
{
	Write-Host "Processing Online Application Instances (Resource Accounts) Numbers"
    foreach($Item in $OnlineApplicationInstanceLineURI)
    {                 
        $Matches = @()
        $Item.PhoneNumber -match $Regex1 | out-null
            
        $myObject1 = New-Object System.Object
        $myObject1 | Add-Member -type NoteProperty -name "LineURI" -Value $Item.PhoneNumber
        $myObject1 | Add-Member -type NoteProperty -name "DDI" -Value $Matches[1]
        $myObject1 | Add-Member -type NoteProperty -name "Ext" -Value $Matches[2]
        $myObject1 | Add-Member -type NoteProperty -name "DisplayName" -Value $Item.DisplayName
        $myObject1 | Add-Member -type NoteProperty -name "Type" -Value $(if ($item.ApplicationId -eq "ce933385-9390-45d1-9512-c8d228074e07") {"Auto Attendant Resource Account"} elseif ($item.ApplicationId -eq "11cd3e2e-fccb-42ad-ad00-878b93575e07") {"Call Queue Resource Account"} else {"Unknown Resource Account"})
        $Array1 += $myObject1         
    }
}

if($OutputType -eq "CSV")
{
    $Array1 | export-csv $FilePath -NoTypeInformation
    Write-Host "ALL DONE!! Your file has been saved to $FilePath."
}
elseif($OutputType -eq "CONSOLE")
{
    $Array1 | FT -AutoSize -Property LineURI,DDI,Ext,DisplayName,Type
    Write-Host "ALL DONE!!"
}
else
{
    $Array1 | FT -AutoSize -Property LineURI,DDI,Ext,DisplayName,Type
    Write-Host "WARNING: Valid output type not set, defaulted to console."
}
