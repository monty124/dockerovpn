#converts synology json export to something useful to use in docker command line

[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | out-null
$initialDirectory = $($(Get-Location).Path)
$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$OpenFileDialog.initialDirectory = $initialDirectory
$OpenFileDialog.filter = "All files (*.json)| *.json"
$OpenFileDialog.ShowDialog() | Out-Null
$fileName = $OpenFileDialog.filename

$JsonContent = Get-Content $filename | ConvertFrom-Json 
#name
$name = "--name=$($JsonContent.name)"

#privelidged
If ($JsonContent.privileged.ToString() -eq "True") {
    $priviledged = "--privileged "
}

#restart policy
If ($JsonContent.enable_restart_policy.ToString() -eq "True") {
    $restart = "--restart always"
}
else {
    $restart = "--restart unless-stopped"
}

#image
$image = "$($JsonContent.image)"

#network and ports
If ($JsonContent.use_host_network.ToString() -eq "True") {
    $network = "--net=host"
}
else {
    If ($JsonContent.enable_publish_all_ports.ToString() -eq "False") {
        ForEach ($port in $JsonContent.port_bindings) {
            $network += "-p $($port.container_port):$($port.host_port)/$($port.type) "
        }
    }
    If ($JsonContent.enable_publish_all_ports.ToString() -eq "True") {
        $network = "--publish-all=true"
    }
}
#volumes
If ($JsonContent.volume_bindings.count -ne 0) {
    ForEach ($volume in $JsonContent.volume_bindings) {
        If ($volume.mount_point -match "resolv.conf") {
            $flag = 1
            write-host
            write-host "[WARNING] - resolv.conf mount point has been replaced with --dns"
            write-host
        }
        else {
            $vols += "-v $($volume.host_volume_file.Replace("/docker","/volume1/docker")):$($volume.mount_point):$($volume.type) "
        }
    }
}


#env variables
If ($JsonContent.env_variables.count -ne 0) {
    ForEach ($envs in $JsonContent.env_variables) {
        switch ($($envs.key.ToString())) {
            HOME { }
            LANG { }
            LANGUAGE { }
            PATH { }
            TERM { }
            XDG_CONFIG_HOME { }
            default { $env += "-e `"$($envs.key)=$($envs.value)`" " }
        }
    }
}

#build
write-host "docker run -d \"
Write-Host $name "\"
If (![string]::IsNullOrEmpty($priviledged)) {
    Write-Host $priviledged "\"
}
Write-Host $restart "\"
Write-Host $network "\"
If (![string]::IsNullOrEmpty($env)) {
    Write-Host $env "\"
}
If (![string]::IsNullOrEmpty($vols)) {
    Write-Host $vols "\"
}
If (![string]::IsNullOrEmpty($flag)) {
    Write-Host "--dns 1.1.1.1 \"
}
Write-Host $image




