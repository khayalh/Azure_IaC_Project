param(
    [string]$PathToXml,
    [string]$DatabaseConnectionString
)
$xml = [xml](Get-Content -Path $PathToXml)
$xml.configuration.connectionStrings.ChildNodes.Item(0).connectionstring = $DatabaseConnectionString
$xml.Save($PathToXml)