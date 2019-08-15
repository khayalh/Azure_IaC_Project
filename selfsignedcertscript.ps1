param (
    [Parameter(Mandatory=$true)]
    [string]$exportedcertdestinationpath,
    [Parameter(Mandatory=$true)]
    [string]$certdnsname,
    [Parameter(Mandatory=$true)]
    [securestring]$CertPass
)
$cert=New-SelfSignedCertificate -DnsName $certdnsname -CertStoreLocation "cert:\LocalMachine\My"
Export-PfxCertificate -Cert $cert -FilePath $exportedcertdestinationpath -Password $CertPass
Write-Output ""
Write-Host $cert.Thumbprint