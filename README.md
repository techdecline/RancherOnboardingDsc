# RancherOnboardingDsc
Powershell DSC Resource for onboarding Windows Server System into Rancher

# DSC Resources
## RancherOnboarding
### Parameters
|Parameter|Attribute|DataType|Description|Allowed Values|
|---------|---------|--------|-----------|--------------|
|CaChecksum|Write|string|Certificate Authority Checksum of Cluster to join||
|DesiredRancherAgentVersion|Write|String|Rancher Agent Image Version||
|RancherUrl|Key|String|Cluster  to join||
|DockerName|NotConfigurable|String|Name of currently installed Docker Runtime||
|Ensure|Write|String|Desired State|Absent,Present|
|ConfiguredRancherAgentVersion|Write|String|Current Rancher Agent Version||
|Label|Write|string[]|Labels to add to the container||

### Description
Powershell DSC Resource for onboarding Windows Server System into Rancher