#converts synology json export to something useful to use with docker-compose

[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | out-null
$initialDirectory = $($(Get-Location).Path)
$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$OpenFileDialog.initialDirectory = $initialDirectory
$OpenFileDialog.filter = "All files (*.json)| *.json"
$OpenFileDialog.ShowDialog() | Out-Null
$fileName = $OpenFileDialog.filename

$JsonContent = Get-Content $filename | ConvertFrom-Json 
#name
$name = "$($JsonContent.name)"

#privelidged
If ($JsonContent.privileged.ToString() -eq "True") {
    $priviledged = "true"
}

#restart policy
If ($JsonContent.enable_restart_policy.ToString() -eq "True") {
    $restart = "always"
}
else {
    $restart = "unless-stopped"
}

#image
$image = "$($JsonContent.image)"

#network and ports
If ($JsonContent.use_host_network.ToString() -eq "True") {
    $network = "host"
}
else {
    If ($JsonContent.enable_publish_all_ports.ToString() -eq "False") {
        ForEach ($port in $JsonContent.port_bindings) {
            $ports += "- $($port.container_port):$($port.host_port)/$($port.type);"
        }
        $network = "bridge"
    }
    If ($JsonContent.enable_publish_all_ports.ToString() -eq "True") {
        #there is no supported publish all ports in docker-compose (standards anyone)? so bind to host then .. urgh ffs
        $network = "host"
    }
}
#volumes
If ($JsonContent.volume_bindings.count -ne 0) {
    ForEach ($volume in $JsonContent.volume_bindings) {
        If ($volume.mount_point -match "resolv.conf") {
            $flag = 1
            write-host
            write-host "[WARNING] - resolv.conf mount point has been replaced with dns"
            write-host
        }
        else {
            $hostside = $volume.host_volume_file -Replace "^/", "/volume1/"
            $vols += "- $($hostside):$($volume.mount_point):$($volume.type);"
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
            default { $env += "- `"$($envs.key)=$($envs.value)`";" }
        }
    }
}

#build yml
$outfile = "$([System.IO.Path]::GetFileNameWithoutExtension($fileName)).yml"
Set-Content -Path $outfile -Value "---" 
Add-Content -Path $outfile -Value "version: ""2"""
Add-Content -Path $outfile -Value "services:"
Add-Content -Path $outfile -Value "  $($name):"
Add-Content -Path $outfile -Value "    image: $($image)"
Add-Content -Path $outfile -Value "    container_name: $($name)"
Add-Content -Path $outfile -Value "    network_mode: $($network)"
If (![string]::IsNullOrEmpty($priviledged)) {
    Add-Content -Path $outfile -Value "    priviledged: $($priviledged)"
}
If (![string]::IsNullOrEmpty($flag)) {
    Add-Content -Path $outfile -Value "    dns:"
    Add-Content -Path $outfile -Value "      - 1.1.1.1"
}
If (![string]::IsNullOrEmpty($env)) {
    Add-Content -Path $outfile -Value "    environment:"
    $envs = $env.Split(";")
    ForEach ($item in $envs) {
        If (!([string]::IsNullOrWhiteSpace($item))) {
            Add-Content -Path $outfile -Value "      $($item)"
        }
    }
}
If (![string]::IsNullOrEmpty($vols)) {
    Add-Content -Path $outfile -Value "    volumes:"
    $vol = $vols.Split(";")
    ForEach ($item in $vol) {
        If (!([string]::IsNullOrWhiteSpace($item))) {
            Add-Content -Path $outfile -Value "      $($item)"
        }
    }
}
If (![string]::IsNullOrEmpty($ports)) {
    Add-Content -Path $outfile -Value "    ports:"
    $port = $ports.Split(";")
    ForEach ($item in $port) {
        If (!([string]::IsNullOrWhiteSpace($item))) {
            Add-Content -Path $outfile -Value "      $($item)"
        }
    }
}
Add-Content -Path $outfile -Value "    restart: $($restart)"

