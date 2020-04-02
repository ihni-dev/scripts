function Check-If-Admin-Session {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}
 
function Install-Packages {
    Print-Message-With-Interval "**********Installing chocolatey**********"
    Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

    Refresh-Environment
    
    Print-Message-With-Interval "**********Installing git**********"
    choco upgrade -y git.install --package-parameters="'/GitAndUnixToolsOnPath'"
    
    Print-Message-With-Interval "**********Installing node.js**********"
    choco upgrade nodejs.install -y

    Print-Message-With-Interval "**********Installing docker desktop**********"
    Enable-WindowsOptionalFeature -Online -FeatureName containers -All -norestart
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -norestart
    choco upgrade docker-desktop -y
    
    Print-Message-With-Interval "**********Installing vs code**********"
    choco upgrade vscode -y
    
    Print-Message-With-Interval "**********Installing Google Chrome**********"
    choco upgrade googlechrome -y
    
    Print-Message-With-Interval "**********Installing PgAmind 4**********"
    choco upgrade pgadmin4 -y
    
    Print-Message-With-Interval "**********Installing MySql Workbench**********"
    choco upgrade mysql.workbench -y
    
    Print-Message-With-Interval "**********Installing SSMS**********"
    choco upgrade ssms -y
    
    Print-Message-With-Interval "**********Installing github desktop**********"
    choco upgrade github-desktop -y

    Refresh-Environment
    
    Print-Message-With-Interval "**********Installing angular cli**********"
    npm install -y -g @angular/cli
}

function Print-Message-With-Interval {
    param( [string]$Message )
    Interval
    Write-Output $Message
    Interval
}

function Refresh-Environment {
    Write-Output "Refreshing environment variables. If rest of the scritp fails, restart elevated shell and rerun script."
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

function Interval {
    Write-Output "`n`n`n`n`n"
}

function Confirm-Install {
    $title = "Setup Qoutation Development Environment"
    $message = "
Welcome to automated developement environment setup script.
Following software will be installed:
    - chocholatey package manager @latest
    - git @latest
    - node.js @latest
    - docker desktop @latest-stable
    - visual studio code @latest
    - Google Chrome @latest
    - PgAdmin 4 @latest
    - mySql Workbench @latest
    - SSMS @latest
    - github dekstop @latest
    with npm:
    - angular cli @latest
It will also enable following windows features:
    - containers
    - Hyper-V
Default directories and settings will be chosen. If you have some/all software already installed they will update or will be omitted."

    $choices  = '&Install', '&Exit'
    return $Host.UI.PromptForChoice($title, $message, $choices, 1)
}

function Confirm-Reboot {
    $title = "Reboot confirmation"
    $message = "
You need to restart your computer. Please save your work and close all running apllications."

    $choices  = '&Restart now', '&Not now'
    return $Host.UI.PromptForChoice($title, $message, $choices, 1)
}

############################## Script start ##############################

if (-Not (Check-If-Admin-Session)) {
    Write-Output "You must run this script in an elevated command shell, using 'Run as Administator'"
    Exit
}

$decision = Confirm-Install

if ($decision -eq 0) {
    Install-Packages
} else {
    Exit
}

$decision = Confirm-Reboot

if ($decision -eq 0) {
    Restart-Computer -Confirm:$true
} else {
    Exit
}