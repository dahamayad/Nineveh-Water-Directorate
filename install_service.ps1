<#
Install script for WaterZummar service.
Usage (run as Administrator PowerShell):
  .\install_service.ps1

What it does:
  - Installs pywin32 if missing
  - Installs the Python Windows service defined in `service_wrapper.py`
  - Starts the service

Notes:
  - Run PowerShell as Administrator.
  - If you prefer `nssm` or Scheduled Task, see README.md.
#>

function Ensure-Admin {
    $current = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($current)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Error "This script must be run as Administrator. Close PowerShell and re-open as Administrator."
        exit 1
    }
}

Ensure-Admin

Write-Host "Installing pywin32 (if needed)..."
python -m pip install --upgrade pip
python -m pip install pywin32

Write-Host "Registering service (may require a moment)..."
python service_wrapper.py install

Write-Host "Starting service..."
python service_wrapper.py start

Write-Host "Service installed and started. Use `python service_wrapper.py stop` or `python service_wrapper.py remove` to stop/remove."
