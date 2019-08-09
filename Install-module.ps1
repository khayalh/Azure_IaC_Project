$Modules = @('xPSDesiredStateConfiguration','xCertificate','xWebAdministration' , 'CertificateDsc')
foreach ($Module in $Modules) {
    if (!(Get-Module $Module)) {
        Install-Module -Verbose $Module -Force
    }
}