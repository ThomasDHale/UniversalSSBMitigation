##############################################################
# Enable CVE-2018-3939 'Speculative Store Bypass' mitigation #
##############################################################

# Create two DWORD registry keys in the path
# HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management
# called
# FeatureSettingsOverride = 8
# and
# FeatureSettingsOverrideMask = 3

# Path
$RegKeyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"

# If path does not exist, create it
if (!(Test-Path $RegKeyPath))
{
 Write-Host "Creating registry path $($RegKeyPath)."
 New-Item -Path $RegKeyPath -Force | Out-Null
}

###################
# Common Settings #
###################

# FeatureSettingsOverrideMask
$RegKeyName = "FeatureSettingsOverrideMask"
$RegKeyValue = 3

# Create DWORD
New-ItemProperty -Path $RegKeyPath -Name $RegKeyName -Value $RegKeyValue -PropertyType DWORD -Force | Out-Null

###############################
# What processor do you have? #
###############################

# Get CPU Manufacturer
$cpuManufacturer = (Get-CimInstance Win32_Processor).Manufacturer

if ($cpuManufacturer -eq "AuthenticAMD") {
    #####################
    # AMD Registry Keys #
    #####################

    # FeatureSettingsOverride
    $RegKeyName = "FeatureSettingsOverride"
    $RegKeyValue = 72

    # Create DWORD
    New-ItemProperty -Path $RegKeyPath -Name $RegKeyName -Value $RegKeyValue -PropertyType DWORD -Force | Out-Null
}
elseif ($cpuManufacturer -eq "GenuineIntel") {
    #######################
    # Intel Registry Keys #
    #######################

    # FeatureSettingsOverride
    $RegKeyName = "FeatureSettingsOverride"
    $RegKeyValue = 8

    # Create DWORD
    New-ItemProperty -Path $RegKeyPath -Name $RegKeyName -Value $RegKeyValue -PropertyType DWORD -Force | Out-Null
}

######################################
# Are you a workstation or a server? #
######################################

# Path
$RegKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Virtualization"

# If path does not exist, create it
if (!(Test-Path $RegKeyPath))
{
 Write-Host "Creating registry path $($RegKeyPath)."
 New-Item -Path $RegKeyPath -Force | Out-Null
}

$productType = (Get-CimInstance Win32_OperatingSystem).ProductType

if ($productType -eq "1") {
    exit
}
elseif ($productType -eq "2" -or $productType -eq "3") {
    ##############################
    # Intel Server Registry Keys #
    ##############################

    # FeatureSettingsOverride
    $RegKeyName = "MinVmVersionForCpuBasedMitigations"
    $RegKeyValue = "1.0"

    # Create DWORD
    New-ItemProperty -Path $RegKeyPath -Name $RegKeyName -Value $RegKeyValue -PropertyType String -Force | Out-Null
}