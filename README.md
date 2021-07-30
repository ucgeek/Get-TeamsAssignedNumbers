# Get-TeamsAssignedNumbers
This script queries Microsoft Teams for assigned numbers and displays in a formatted table with the option to export to CSV.      

During processing LineURI's are run against a regex pattern to extract the DDI/DID and the extension to a separate column.          

This script collects Microsoft Teams objects including: Users, Meeting Rooms, Online Application Instances (Resource Accounts)      

This script does not collect objects from on-premises environments even if in hybrid, instead use this script - https://github.com/ucgeek/get-sfb-lync-assigned-numbers
