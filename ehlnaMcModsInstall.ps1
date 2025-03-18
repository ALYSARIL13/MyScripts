#Variables
$downloadUrl = "https://maven.fabricmc.net/net/fabricmc/fabric-installer/1.0.1/fabric-installer-1.0.1.jar"
$installer = ".\fabric-installer.jar"
$textInstallJava = "Instala Java version 21 o superior para continuar."
$textUpdateJava = "Puedes obtener la version actualizada de Java desde este enlace:`nhttps://www.oracle.com/java/technologies/downloads"
$retryText = "Tras la instalacion, reinicia tu equipo y vuelve a ejecutar este script."
$mcLocation = "$env:APPDATA\.minecraft"
$modsLocation = "$env:APPDATA\.minecraft\mods"
$temp = "$env:APPDATA\temp"
[Version]$minJavaVer = "21.0"
$userSel = "No"

#modList
$modPackUrl = "https://p-def1.pcloud.com/cBZ4plVWiZxkwFxf7ZZZzyiIXkZ2ZZEpXZkZm98RHZyFZH8ZuYZ9HZqzZMLZ8JZO0ZGZW8ZoHZ7zZqYZ1zZ0sR85ZlBMCfm67PEh8UV6iEyfBl5RyrFsV/mods.zip"
$modPackFile = "mods.zip"

#Welcome
Function Start-McScript{
    $title = "Script de instalacion automatica de Mods para servidor Ehlna - Cobblemon"
    $question = "ATENCION: Este script eliminara otros mods que tengas intalados actualmente.`nEsta seguro que desea continuar?"
    $choices  = '&Si', '&No'
    $decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
    if ($decision -eq 0) {
        Check-Requirements
    } else {
        Write-Host -ForegroundColor Red 'Ejecucion cancelada!'
    }
}

Function Write-Done{
    Write-Host -ForegroundColor Cyan " Completado!"
}

#Function to install game
Function Install-GameMods{
    #Creating game directory
    New-Item -ItemType Directory -Path "$temp" -Force
    Set-Location -Path $temp

    #Downloading Minecraft Launcher
    Write-Host -ForegroundColor Green "Descargando el instalador de Minecraft-Fabric..." -NoNewline
    Invoke-WebRequest -Uri $downloadUrl -OutFile $installer
    Write-Done
    Write-Host -ForegroundColor Green "Instalando el lanzador Fabric 1.21.1..."
    java -jar $installer client -dir $mcLocation -mcversion "1.21.1" -noprofile
    Write-Done

    #Download mods
    if(!(Test-Path $modsLocation)){
        New-Item -ItemType Directory -Path $modsLocation -Force
    }else{
        Remove-Item -Path "$modsLocation\*" -Recurse -Force
    }

    try{
        Write-Host -ForegroundColor Green "Descargando paquete de mods..." -NoNewline
        Invoke-WebRequest -Uri $modPackUrl -OutFile "$modsLocation\$modPackFile"
        Write-Done
        Write-Host -ForegroundColor Green "Extrayendo mods..." -NoNewline
        Expand-Archive -Path "$modsLocation\$modPackFile" -DestinationPath $modsLocation -Force
        Write-Done
        Write-Host -ForegroundColor Cyan "Instalacion completada!"
    }catch{
        Write-Error -Message "`nERROR: No se pudo descargar el paquete de mods."
    }
}


Function Check-Requirements{
    #check if java is installed
    Write-Host -ForegroundColor Green "Verificando instalacion de Java..." -NoNewline
    Try{
        [Version]$javaVersion = (java --version).Split(" ")[1]
    }catch{
        Write-Error -Message "Java no esta instalado. $textInstallJava"
        Write-host -ForegroundColor Green "$textUpdateJava"
        Write-host "$retryText"
    }

    if($javaVersion -ge $minJavaVer){
        Write-Done
        Install-GameMods
    }else{
        Write-Warning -Message "`nTu version de Java esta desactualizado. Desinstala tu Java e $textInstallJava"
        Write-host -ForegroundColor Green "$textUpdateJava"
        Write-host "$retryText"
    }
}

Start-McScript
