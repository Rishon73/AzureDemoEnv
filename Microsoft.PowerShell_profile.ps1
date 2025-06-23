function Tri-show()
{
Write-Host "Script directory: $PSScriptRoot

	Helping functions to make our lives slightly easier (v2024.2.b 06/23/2025)
-----------------------------------------------------------------------------------
Tri-launch-LocalDEXAgent
Tri-Start-OSVEnvironment
Tri-launch-TriServeWebMonitor
Tri-delete-Tosca-lock-file [-force]
Tri-launch-Tosca
Tri-launch-Tosca-license-configuration
Tri-launch-vision-ai-agent
Tri-launch-di-report-viewer
Tri-launch-E2G-agent [-personalAgent] [-liveView]
Tri-launch-sim-agent
"
}

function Tri-launch-LocalDEXAgent() {
	$dexExe = $env:TRICENTIS_DEX_AGENT_HOME+"ToscaDistributionAgent.exe"
	$WorkingDirectory = "$env:USERPROFILE\temp"
	if (-not (Test-Path -Path $WorkingDirectory)){New-Item -ItemType Directory -Path $WorkingDirectory}
	Start-Process -FilePath $dexExe -WorkingDirectory $WorkingDirectory -NoNewWindow
}

function Tri-Start-OSVEnvironment() {
	# Get all environments
	$GetEnvironmentsURL = "http://localhost:18080/api/v1/environments"
	$response = Invoke-RestMethod -Method Get -Uri $GetEnvironmentsURL
	echo "Response from get all envs: $response"

	# Find the 'OSV' environment
	$envs = $response.value.data
	$env = $envs | Where-Object { $_.name -eq "OSV" }
	echo "Found env.: $env"

	# Start the selected environment
	$StartEnvURL = "http://localhost:18080/api/v1/environments/"+$env.id+"/start"
	$response = Invoke-RestMethod -Method Post -Uri $StartEnvURL
	echo "Response from Start Env.: $response":
}

function Tri-launch-TriServeWebMonitor() {
	## Start the Triserve WebServer Processes
	if ((hostname).substring(7,3) -ge 232)	{
		# for 2023.2 and higher
		$devopsPackagePath = "C:\TriServe\TriServeWebMonitor"
	} else {
		# for 2023.1
		$devopsPackagePath = "C:\DevOpsPackage\TriServeWebMonitor"
	}
	echo "DevOps Package path is: $devopsPackagePath"
	start-process -FilePath "$devopsPackagePath\launchTriserv.bat" -WorkingDirectory $devopsPackagePath
}

function Tri-delete-Tosca-lock-file {
	param (
        [switch]$force
    )
	[bool]$delFile = 0

	$lockFile = get-lock-file-name

	# check if there's a lock file
	if (Test-Path $lockFile) {
		# check if Tosca is running
		$toscaProcess = Get-Process | Where {$_.Name -eq "ToscaCommander"}
		if ($toscaProcess -eq $null) {
			[bool]$delFile = 1
		}
		# if -force switch is true ignore user's input
		elseif ($force){
			[bool]$delFile = 1
		}
		else {
			# Tosca is open - confirm the user wants to remove the lock file
			$userAnswer = Read-Host -Prompt "Tosca is running , are you sure you want to delete the lock file? Select y | n"
			if ($userAnswer -ieq "y") {
				[bool]$delFile = 1
			}
			else {
				Write-Host "Exiting without deleting the lock file"
			}
		}
	}
	if ($delFile) {
		write-host "deleting file: "$lockFile
		Remove-Item $lockFile
	}
}

function Tri-launch-Tosca() {
	$directory = $env:TRICENTIS_HOME -replace "Settings", "ToscaCommander"
	Start-Process -FilePath "$directory\ToscaCommander.exe"
}

function Tri-launch-Tosca-license-configuration() {
	 Start-Process -FilePath "C:\Program Files (x86)\TRICENTIS\Tosca Testsuite\Licensing\ToscaLicenseConfiguration.exe" -NoNewWindow
}

function Tri-launch-vision-ai-agent() {
	start-process -FilePath "C:\Program Files (x86)\TRICENTIS\Tosca Testsuite\Vision AI\Agent\vision-ai-agent.exe"
}

function Tri-launch-di-report-viewer()
{
	start-process -FilePath "$env:TRICENTIS_DI_HOME\tools\Tricentis.DataIntegrity.Report.Viewer.exe"
}

function Tri-env-start() {
	Tri-delete-Tosca-lock-file
	Tri-launch-Tosca-license-configuration
	Tri-Start-OSVEnvironment
	Tri-launch-LocalDEXAgent
	Tri-launch-TriServeWebMonitor
	#Tri-launch-Tosca
}

function get-lock-file-name() {
	$userProvile = $env:USERPROFILE
	$lockFile = ""

	switch -Wildcard ( hostname ) 	{
		'satosca242*' {
			Write-Host 'satosca242'
			$lockFile = "$userProvile\Tosca_Projects\Workspaces\tosca_24_2_core_repository\tosca_24_2_core_repository.tws.txt"
		}
		'satosca241*' {
			Write-Host 'satosca241'
			$lockFile = "$userProvile\Tosca_Projects\Workspaces\tosca_24_1_core_repository\tosca_24_1_core_repository.tws.txt"

		}
		'satosca232*' {
			Write-Host 'satosca232'
			$lockFile = "$userProvile\Tosca_Projects\Tosca2023.2\tosca_core_repository_v2023-2\tosca_core_repository_v2023-2.tws.txt"

		}
		'satosca231*' {
			Write-Host 'satosca231'
			$lockFile = "$userProvile\Tosca_Projects\Tosca2023.1\tosca_core_repository_v2023-1\tosca_core_repository_v2023-1.tws.txt"
		}
		default {
			Write-Information 'something else'
		}
	}
	return $lockFile
}

function Tri-launch-E2G-agent()
{
	param ( 
		[switch]$liveView, 
		[switch]$personalAgent
	)
	$agentName = (hostname)+"-"+$env:USERNAME
	$commandString = "launcher agent --keepdisplayon --tenant presales --agentId $agentName --characteristics GEO:AMS SAName:$env:USERNAME"
	if (-Not $personalAgent) { $commandString += " --shared"}
	if ($liveView) { $commandString += " --liveview"}

		echo $commandString
		Invoke-Expression $commandString
}

function Tri-launch-sim-agent()
{
	Write-Host "...assuming the file is in the Download folder..."
	$userProvile = $env:USERPROFILE
	$filePath = "$userProvile\Downloads\Tricentis.Simulator.Agent.exe"

	start-process -FilePath filePath
}