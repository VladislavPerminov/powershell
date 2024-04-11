#activer hyper-v
enabled-WindowsOptionalFeature -Online -FeatureName Microsoft-hyper-v-all
#verifier les cartes réseaux 
Get-NetAdapter
#création d'un switch externe
New-VMSwitch -name Externe -NetAdapterName WI-FI
#création de switch privé
New-VMSwitch -name MPIO1 -SwitchType Private
New-VMSwitch -name MPIO2 -SwitchType Private
New-VMSwitch -name Pulsation -SwitchType Private  
#création de switch interne 
New-VMSwitch -name Interne -SwitchType Internal



#Création d'une VM ( Master)

New-VM -Name Master -MemoryStartupBytes 6GB -Path c:\hyper-v\Master -NewVHDPath C:\Hyper-V\Master\Master.vhdx -Generation 2 -SwitchName interne -NewVHDSizeBytes 200GB
#Activer les services d'invité (tools)
Enable-VMIntegrationService -VMName Master -Name Interface*
#modifier le nombre de CPU
Set-VM -Name Master -ProcessorCount 2
#desactiver le point de control ( désactiver le snapshot)
Set-VM -Name Master -CheckpointType Disabled



#Procedure pour le sysprep (enlever les parametres specifique à une machine en vue de le deployer ou de le cloner )
cd C:\windows\system32\sysprep
taper .\sysprep.exe /generalize /oobe /shutdown
ou 
C:\windows\system32\sysprep\sysprep.exe /generalize /oobe /shutdown


#mettre disque de Master en lecture seul (Read Only)
#creation de disque de différenciation à partir d'un Parent

New-VHD -Path C:\Hyper-V\Hote-01\Hote-01.vhdx -ParentPath c:\hyper-v\master\master.vhdx -Differencing
New-VHD -Path C:\Hyper-V\Hote-02\Hote-02.vhdx -ParentPath c:\hyper-v\master\master.vhdx -Differencing
New-VHD -Path C:\Hyper-V\Hote-03\Hote-03.vhdx -ParentPath c:\hyper-v\master\master.vhdx -Differencing
New-VHD -Path C:\Hyper-V\DC-01\DC-01.vhdx -ParentPath c:\hyper-v\master\master.vhdx -Differencing

#creation de VMs à partir de disque de differenciation 
New-VM -Name Hote-03 -MemoryStartupBytes 6GB -Path c:\hyper-v\Hote-03 -VHDPath C:\Hyper-V\Hote-03\Hote-03.vhdx -Generation 2 -SwitchName interne
New-VM -Name Hote-02 -MemoryStartupBytes 6GB -Path c:\hyper-v\Hote-02 -VHDPath C:\Hyper-V\Hote-02\Hote-02.vhdx -Generation 2 -SwitchName interne
New-VM -Name Hote-01 -MemoryStartupBytes 6GB -Path c:\hyper-v\Hote-01 -VHDPath C:\Hyper-V\Hote-01\Hote-01.vhdx -Generation 2 -SwitchName interne
New-VM -Name DC-01 -MemoryStartupBytes 6GB -Path c:\hyper-v\DC-01 -VHDPath C:\Hyper-V\DC-01\DC-01.vhdx -Generation 2 -SwitchName interne
Enable-VMIntegrationService -VMName DC-01, Hote-01, hote-02, hote-03 -Name Interface*
Set-VM -Name DC-01, Hote-01, hote-02, hote-03 -ProcessorCount 2
Set-VM -Name DC-01, Hote-01, hote-02, hote-03 -CheckpointType Disabled
