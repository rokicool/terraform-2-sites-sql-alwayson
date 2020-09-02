# Create OU for placing SQL Servers
New-ADOrganizationalUnit -Name "SQLServers" -Path "DC=ALWAYSON,DC=AZURE"

Move-ADObject -Identity "CN=win-one-sql,CN=Computers,DC=alwayson,DC=azure" -TargetPath "OU=SQLServers,DC=alwayson,DC=azure" 
Move-ADObject -Identity "CN=win-two-sql,CN=Computers,DC=alwayson,DC=azure" -TargetPath "OU=SQLServers,DC=alwayson,DC=azure" 
