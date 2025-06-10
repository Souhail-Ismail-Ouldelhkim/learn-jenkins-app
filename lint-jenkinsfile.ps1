param (
    [string]$JenkinsfilePath = "C:\Users\lenovo\Desktop\JenkinsFormationUdemy\learn-jenkins-app\Jenkinsfile"
)

# Authentification
$username = "Souhail_Ismail-Ouldelhkim"
$token = "11c1dfc1a7f5ecfa14b6c9c06875ffd582"
$authHeader = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${username}:${token}"))

# Vérification du fichier Jenkinsfile
if (!(Test-Path $JenkinsfilePath)) {
    Write-Error "Jenkinsfile introuvable à : $JenkinsfilePath"
    exit 1
}

# Lire le fichier en UTF-8 brut
$rawContent = Get-Content -Path $JenkinsfilePath -Raw -Encoding UTF8

# Echappement du contenu pour JSON brut
$escaped = $rawContent -replace '\\', '\\\\' -replace '"', '\"' -replace "`r?`n", '\n'

# Construction manuelle du JSON
$jsonBody = "{ `"jenkinsfile`": `"$escaped`" }"

# Récupération du crumb
try {
    $crumbResponse = Invoke-RestMethod -Uri "http://localhost:8080/crumbIssuer/api/json" `
        -Headers @{ Authorization = $authHeader }
}
catch {
    Write-Error "Erreur lors de la récupération du crumb : $_"
    exit 1
}

# Appel à l'API Jenkins
try {
    $headers = @{
        Authorization = $authHeader
        "Content-Type" = "application/json"
        "$($crumbResponse.crumbRequestField)" = $crumbResponse.crumb
    }

    $response = Invoke-RestMethod -Uri "http://localhost:8080/pipeline-model-converter/validate" `
        -Method Post `
        -Headers $headers `
        -Body $jsonBody

    if ($response.status -eq "ok") {
        Write-Host "Jenkinsfile valide !"
        Write-Host "Message : $($response.data.message)"
    } else {
        Write-Warning "Echec de validation : $($response.data.message)"
        $response | ConvertTo-Json -Depth 5
    }
}
catch {
    Write-Error "Erreur lors de l'appel à Jenkins : $_"
}
