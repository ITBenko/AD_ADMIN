# Import Active Directory module
Import-Module ActiveDirectory

# Output CSV file paths and names
$usersCsvFilePath = "C:\change\path\AD_Users.csv"
$groupsCsvFilePath = "C:\change\path\AD_Groups.csv"
$ousCsvFilePath = "C:\change\path\AD_OUs.csv"

# Export AD Users to CSV
Get-ADUser -Filter * -Properties SamAccountName,Name,UserPrincipalName,Enabled,Description,DistinguishedName |
    Export-Csv -Path $usersCsvFilePath -NoTypeInformation

# Export AD Groups to CSV
Get-ADGroup -Filter * |
    Select-Object SamAccountName, Name, GroupCategory, GroupScope, Description, DistinguishedName |
    Export-Csv -Path $groupsCsvFilePath -NoTypeInformation

# Export AD Organizational Units to CSV
Get-ADOrganizationalUnit -Filter * |
    Select-Object Name, DistinguishedName |
    Export-Csv -Path $ousCsvFilePath -NoTypeInformation

Write-Host "Export completed. The CSV files have been saved to:"
Write-Host "Users: $usersCsvFilePath"
Write-Host "Groups: $groupsCsvFilePath"
Write-Host "OUs: $ousCsvFilePath"
