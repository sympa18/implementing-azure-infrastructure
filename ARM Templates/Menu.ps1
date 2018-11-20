$title = @"
_____           _           _     _____          _   _____                      __ 
|  __ \         (_)         | |   |  __ \        | | |  __ \                    / _|
| |__) | __ ___  _  ___  ___| |_  | |__) |___  __| | | |  | |_      ____ _ _ __| |_ 
|  ___/ '__/ _ \| |/ _ \/ __| __| |  _  // _ \/ _` | | |  | \ \ /\ / / _` | '__|  _|
| |   | | | (_) | |  __/ (__| |_  | | \ \  __/ (_| | | |__| |\ V  V / (_| | |  | |  
|_|   |_|  \___/| |\___|\___|\__| |_|  \_\___|\__,_| |_____/  \_/\_/ \__,_|_|  |_|  
               _/ |                                                                 
              |__/                                                                  
"@

Write-Host $title`n`n -ForegroundColor Green
$test = $true
$opt = @{
    1 = "2 x Resource Groups, 3 x VNET, VNET Peering, Linux machines"
    2 = "2 x Resource Groups, 3 x VNET, VNET Peering, Windows machines"
    3 = "2 x Resource Groups, 2 x VNET, VM Scale Set w/ web server, Traffic Manager - Linux"
    4 = "2 x Resource Groups, 2 x VNET, VM Scale Set w/ web server, Traffic Manager - Windows"
}

$opt.GetEnumerator() | Sort-Object Key | ForEach-Object {Write-Host "$($_.Key)`)   $($_.Value)" -ForegroundColor Magenta}

[int]$choice = Read-Host "Choose Deployment"

if (!($opt.ContainsKey($choice))) {
    Write-Host "Invalid"
    exit;
}

if ($test) {
    switch ($choice) {
        1 {
            .\1\Deploy.ps1
            Write-Host "Deployment Complete" -ForegroundColor Green
        }
        2 {
            .\2\Deploy.ps1
            Write-Host "Deployment Complete" -ForegroundColor Green 
        }
        3 {
            .\3\Deploy.ps1
            Write-Host "Deployment Complete" -ForegroundColor Green
        }
        4 {
            .\4\Deploy.ps1
            Write-Host "Deployment Complete" -ForegroundColor Red
        }
    }
}

