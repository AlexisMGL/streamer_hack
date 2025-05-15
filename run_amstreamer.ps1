# run_amstreamer.ps1

<#
  Ce script démarre Chrome en mode headless pour charger votre URL,
  puis « rafraîchit » automatiquement la page toutes les 60 secondes
  en redémarrant le process headless. Ainsi, dès que votre connexion
  revient, une nouvelle instance chargera la page.
#>

# 1) Localisation de l’exécutable Chrome
$possiblePaths = @(
    "$Env:ProgramFiles\Google\Chrome\Application\chrome.exe",
    "$Env:ProgramFiles(x86)\Google\Chrome\Application\chrome.exe",
    "$Env:LocalAppData\Google\Chrome\Application\chrome.exe"
)
$chrome = $possiblePaths | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $chrome) {
    Write-Error "Google Chrome introuvable. Veuillez vérifier le chemin ou installer Chrome."
    exit 1
}

# 2) Arguments pour le mode headless
$arguments = @(
    "--headless"
    "--disable-gpu"
    "--remote-debugging-port=9222"
    "https://s330tools.netlify.app/amstreamer/"
)

# Fonction pour (re)-lancer Chrome headless et stocker le Process
function Start-Streamer {
    param()
    if ($global:proc -and -not $global:proc.HasExited) {
        # Nettoyage de l’ancienne instance
        Stop-Process -Id $global:proc.Id -Force -ErrorAction SilentlyContinue
    }
    $global:proc = Start-Process -FilePath $chrome -ArgumentList $arguments -WindowStyle Hidden -PassThru
    Write-Host "info: Chrome headless sur (PID $($proc.Id)) a $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
}

# 3) Démarrage initial
Start-Streamer

# 4) Boucle infinie : toutes les 60 secondes, on « rafraîchit » par un redémarrage
while ($true) {
    Start-Sleep -Seconds 60
    Write-Host "info: Rafraichissement à $(Get-Date -Format 'HH:mm:ss')"
    Start-Streamer
}

# Notes :
# - Pour interrompre le script : Ctrl+C dans votre console PowerShell.
# - Vous pouvez ajuster l’intervalle en modifiant la valeur de -Seconds.
