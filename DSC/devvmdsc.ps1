Configuration Main
{

    Param ( [string] $nodeName,
            [string]$certfilelocation,
            [string] $Thumbprint,
            [PSCredential]$certcredential
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName xCertificate
    Import-DscResource -ModuleName CertificateDsc
    Import-DscResource -ModuleName xWebAdministration


    Node $AllNodes.NodeName
    {
        WindowsFeature InstallWebServer {
            Ensure = "Present"
            Name   = "Web-Server"
        }
        WindowsFeature WebManagementConsole {
            Name   = "Web-Mgmt-Console"
            Ensure = "Present"
        }
        WindowsFeature WebManagementService {
            Name   = "Web-Mgmt-Service"
            Ensure = "Present"
        }
        Script DownloadWebDeploy {
            TestScript = {
                Test-Path "C:\WindowsAzure\WebDeploy_amd64_en-US.msi"
            }
            SetScript  = {
                $source = "https://download.microsoft.com/download/0/1/D/01DC28EA-638C-4A22-A57B-4CEF97755C6C/WebDeploy_amd64_en-US.msi"
                $dest = "C:\WindowsAzure\WebDeploy_amd64_en-US.msi"
                Invoke-WebRequest $source -OutFile $dest
            }
            GetScript  = { @{Result = "DownloadWebDeploy" } }
            DependsOn  = "[WindowsFeature]InstallWebServer"
        }
        Package InstallWebDeploy {
            Ensure    = "Present"  
            Path      = "C:\WindowsAzure\WebDeploy_amd64_en-US.msi"
            Name      = "Microsoft Web Deploy 3.6"
            ProductId = "6773A61D-755B-4F74-95CC-97920E45E696"
            Arguments = "ADDLOCAL=ALL"
            DependsOn = @("[Script]DownloadWebDeploy", "[WindowsFeature]WebManagementService")
        }
        Service StartWebDeploy {                    
            Name        = "WMSVC"
            StartupType = "Automatic"
            State       = "Running"
            DependsOn   = "[Package]InstallWebDeploy"
        } 
        Package UrlRewrite {
            #Install URL Rewrite module for IIS
            DependsOn = "[WindowsFeature]InstallWebServer"
            Ensure    = "Present"
            Name      = "IIS URL Rewrite Module 2"
            Path      = "https://download.microsoft.com/download/C/9/E/C9E8180D-4E51-40A6-A9BF-776990D8BCA9/rewrite_amd64.msi"
            Arguments = "/quiet"
            ProductId = "08F0318A-D113-4CF0-993E-50F191D397AD"
        }
        File ArtifactsFolder {
            Type            = "Directory"
            DestinationPath = "C:\Cert"
            Ensure          = "Present"
        }   
        xRemoteFile DownloadPackage {            	
            DestinationPath = "C:\Cert\selfsignedcert.pfx"
            Uri             = $certfilelocation
            MatchSource     = $true
            DependsOn       = "[File]ArtifactsFolder" 
        }
        xWebsite DefaultSite {
            Ensure       = "Present"
            Name         = "Default Web Site"
            State        = "Stopped"
            PhysicalPath = "C:\inetpub\wwwroot"
            DependsOn    = "[WindowsFeature]InstallWebServer"
        }
        xPfxImport ImportPfxCert {
            Thumbprint = "$Thumbprint"
            Path       = "C:\Cert\selfsignedcert.pfx"
            Credential = $certcredential
            Location   = 'LocalMachine'
            Store      = "WebHosting"
            DependsOn  = '[xRemoteFile]DownloadPackage'
        }
        # Create the new Website with HTTP and HTTPS
        xWebsite NewWebsite {
            Ensure          = "Present"
            Name            = "prodvm.westeurope.cloudapp.azure.com"
            State           = "Started"
            PhysicalPath    = "C:\inetpub\wwwroot"
            DependsOn       = @("[WindowsFeature]InstallWebServer", "[xPfxImport]ImportPfxCert")
            BindingInfo     = @(
                MSFT_xWebBindingInformation {
                    Protocol              = "HTTPS"
                    Port                  = 443
                    HostName              = "prodvm.westeurope.cloudapp.azure.com"
                    CertificateThumbprint = "$Thumbprint"
                    CertificateStoreName  = "WebHosting"
                }
                MSFT_xWebBindingInformation {
                    Protocol = "HTTP" 
                    Port     = "80"
                    HostName = "prodvm.westeurope.cloudapp.azure.com"
                }
            )
        }
        LocalConfigurationManager {
            CertificateId = "$Thumbprint"
        }
    }
}