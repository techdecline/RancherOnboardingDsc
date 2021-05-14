enum Ensure { 
    Absent
    Present
}

[DscResource()]
class RancherOnboarding {
    [DscProperty(Key)]
    [String]$RancherUrl

    [DscProperty(NotConfigurable)]
    [String]$OnboardingState

    [DscProperty(Mandatory=$false)]
    [String]$Ensure = 'Present'

    [DscProperty(Mandatory)]
    [PSCredential]$TokenCredential

    [DscProperty(NotConfigurable)]
    [String]$ConfiguredRancherAgentVersion

    [DscProperty(Mandatory)]
    [String]$DesiredRancherAgentVersion

    [DscProperty(Mandatory)]
    [String]$CaChecksum

    [DscProperty(Mandatory=$false)]
    [String[]]$Label

    # Gets the resource's current state.
    [RancherOnboarding] Get() {
        try {
            get-command docker
        }
        catch [System.Management.Automation.CommandNotFoundException] {
            Write-Warning "Missing Docker"
            $this.OnboardingState = 'Absent'
            return $this
        }

        $rancherAgentImageArr = docker images | Where-Object {$_ -match "^rancher/rancher-agent*"}
        if ($rancherAgentImageArr) {
            $this.OnboardingState = "Present"
            $this.ConfiguredRancherAgentVersion = ($rancherAgentImageArr[0]-split "\s+")[1] -replace "^v"
        }
        else {
            $this.OnboardingState = "Absent"
        }

        return $this
    }
    
    # Sets the desired state of the resource.
    [void] Set() {
        Write-Verbose "Desired State is: $($this.Ensure)"
        switch ($this.Ensure) {
            "Absent" {
                throw "Not yet implemented"

            }
            "Present" {
                Write-Verbose "Will add node to rancher"
                $clearPassword = $this.TokenCredential.GetNetworkCredential().Password
                $containerPullArgs = "pull rancher/rancher-agent:v$($this.DesiredRancherAgentVersion)"
                $cmdLine = "docker run -v c:\:c:\host rancher/rancher-agent:v$($this.DesiredRancherAgentVersion) bootstrap --server $($this.RancherUrl) --token $($clearPassword) --ca-checksum $($this.CaChecksum) --worker"
                $this.Label | ForEach-Object {
                    Write-Verbose "Adding Label: $_"
                    $cmdLine = $cmdLine + " --label $_"
                }
                Write-Verbose "Appending iex to run command"
                $cmdLine = $cmdLine + ' | invoke-expression'
                $cmdLine
                Write-Verbose "Pulling container rancher-agent"
                Start-Process -FilePath (get-command docker.exe).Source -ArgumentList $containerPullArgs -Wait -NoNewWindow
                
                Write-Verbose "Rancher Onboarding Command will be: $cmdLine" 
                Invoke-Expression -Command $cmdLine
            }
        }
    }
    
    # Tests if the resource is in the desired state.
    [bool] Test() {
        try {
            $rancherAgentState = $this.Get()   
        }
        catch {
            Write-Warning "$($error[0].exception.Message)"
            return $false
        }
        if ($rancherAgentState.OnboardingState -eq $this.Ensure) {
            Write-Verbose "Rancher is configured correctly"
            return $true
        }
        else {
            return $false
        }
    }
}