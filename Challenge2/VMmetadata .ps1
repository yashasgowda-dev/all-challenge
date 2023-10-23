$accessvmmetadata=Invoke-WebRequest -Headers @{"Metadata"="true"} -Method GET -Proxy $Null -Uri "http://169.254.169.254/metadata/instance?api-version=2021-01-01"
$accessvmmetadata.Content
$accessvmmetadata.Content| ConvertFrom-Json | ConvertTo-Json -Depth 6