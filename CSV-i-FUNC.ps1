# Import Active Directory module
Import-Module ActiveDirectory

# Function to create AD groups
function Create-ADGroup {
    param(
        [string]$Name,
        [string]$Description,
        [string]$DistinguishedName,
        [string]$GroupCategory,
        [string]$GroupScope
    )

    if (-not (Get-ADGroup -Filter { Name -eq $Name })) {
        New-ADGroup -Name $Name `
                    -Description $Description `
                    -Path $DistinguishedName `
                    -GroupCategory $GroupCategory `
                    -GroupScope $GroupScope
    }
}

# Function to create AD Organizational Units (OUs)
function Create-ADOU {
    param(
        [string]$Name,
        [string]$DistinguishedName
    )

    if (-not (Get-ADOrganizationalUnit -Filter { Name -eq $Name })) {
        New-ADOrganizationalUnit -Name $Name -Path $DistinguishedName
    }
}

# Function to add members to a group
function Add-MemberToGroup {
    param(
        [string]$GroupName,
        [string]$MemberDistinguishedName
    )

    # Get the group object from Active Directory
    $group = Get-ADGroup -Filter { Name -eq $GroupName }

    if ($group) {
        Add-ADGroupMember -Identity $group -Members $MemberDistinguishedName
    } else {
        Write-Host "Group '$GroupName' not found in Active Directory."
    }
}

# Import AD Users from CSV
$usersCsvFilePath = "C:\change\path\AD_Users.csv" #Path to change
$usersData = Import-Csv -Path $usersCsvFilePath

foreach ($user in $usersData) {
    # Create AD User
    New-ADUser -SamAccountName $user.SamAccountName `
               -UserPrincipalName $user.UserPrincipalName `
               -Name $user.Name `
               -Enabled $user.Enabled `
               -Description $user.Description `
               -Path $user.DistinguishedName -PassThru
}

# Import AD Groups from CSV
$groupsCsvFilePath = "C:\change\path\AD_Groups.csv" #Path to change
$groupsData = Import-Csv -Path $groupsCsvFilePath

foreach ($group in $groupsData) {
    # Create AD Group
    Create-ADGroup -Name $group.Name `
                   -Description $group.Description `
                   -DistinguishedName $group.DistinguishedName `
                   -GroupCategory $group.GroupCategory `
                   -GroupScope $group.GroupScope
}

# Import AD Organizational Units from CSV
$ousCsvFilePath = "C:\change\path\AD_OUs.csv" #Path to change
$ousData = Import-Csv -Path $ousCsvFilePath

foreach ($ou in $ousData) {
    # Create AD OU
    Create-ADOU -Name $ou.Name `
                -DistinguishedName $ou.DistinguishedName
}

# Import group membership from the Users CSV
$usersData | ForEach-Object {
    if ($_.MemberOf) {
        $groups = $_.MemberOf -split ";"
        foreach ($group in $groups) {
            $group = $group.Trim()
            Add-MemberToGroup -GroupName $group `
                              -MemberDistinguishedName $_.DistinguishedName
        }
    }
}

Write-Host "AD object import completed."
