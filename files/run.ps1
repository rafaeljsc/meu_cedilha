Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.DirectoryServices.AccountManagement
[System.Windows.Forms.Application]::EnableVisualStyles()

#CONFIGURANDO APP
$files = $PSScriptRoot
$App = "meuCedilha"
$global:AppDir =  "$env:ProgramFiles\$App"
$checkAppDir = Test-Path $AppDir

if (!$checkAppDir){
    md $AppDir
    '0' > $AppDir\status.txt 
    '#NoTrayIcon
!c::
GetKeyState, state, CapsLock, T
if (state == "D"){
    Send, Ç
}else{
    Send, ç
}
Return' > $AppDir\meuCedilha.ahk
}

$Form                 = New-Object system.Windows.Forms.Form
$Form.ClientSize      = New-Object System.Drawing.Point(400,300)
$Form.text            = "$App, by Canal Alltomatizando"
$Form.TopMost         = $true
$Form.StartPosition   = "CenterScreen"
$Form.MaximizeBox     = $false
$form.FormBorderStyle = "fixeddialog"
$Background           = [system.drawing.image]::FromFile("$files\bg.png")
$form.BackgroundImage = $Background
$Form.BackgroundImageLayout = "None"
$Icon                 = New-Object system.drawing.icon ("$files\ico.ico")
$Form.Icon            = $Icon

$global:statusLabel = New-Object system.Windows.Forms.Label
$statusLabel.text                     = 'Status:'
$statusLabel.AutoSize                 = $false
$statusLabel.Font                     = 'Verdana,14'
$statusLabel.TextAlign = 'MiddleCenter'
$statusLabel.BackColor = 'Transparent'
$statusLabel.Visible = $true

$global:statusValueLabel = New-Object system.Windows.Forms.Label
$statusValueLabel.AutoSize                 = $false
$global:statusValueLabel.Width = 200
$statusValueLabel.Font = New-Object System.Drawing.Font('Verdana', 14, [System.Drawing.FontStyle]::Bold)
$statusValueLabel.TextAlign = 'MiddleCenter'
$statusValueLabel.BackColor = 'Transparent'

$global:actionButton           = New-Object system.Windows.Forms.Button
$actionButton.width     = 90
$actionButton.Height    = 30
$actionButton.location  = New-Object System.Drawing.Point((($Form.ClientSize.Width - $actionButton.Width)/2),(($form.ClientRectangle.Bottom)-50))
$actionButton.Font      = 'Verdana,9'
$actionButton.TextAlign = 'MiddleCenter'
$actionButton.BackColor = 'Transparent'
$actionButton.Enabled = $false

$global:mainGroupBox    = New-Object system.Windows.Forms.Groupbox
$mainGroupBox.height    = 80
$mainGroupBox.width     = 300
$mainGroupBox.location  = New-Object System.Drawing.Point((($Form.ClientSize.Width - $mainGroupBox.Width)/2),($Form.ClientRectangle.Top + 145))
$mainGroupBox.BackColor = 'Transparent'

$global:appDescriptionLabel = New-Object system.Windows.Forms.Label
$appDescriptionLabel.text = 'Pressione "Alt + C" com a ferramenta ativada para digitar um "ç".'
$appDescriptionLabel.AutoSize                 = $false

$appDescriptionLabel.width     = $mainGroupBox.width
$appDescriptionLabel.height    = $mainGroupBox.height

$appDescriptionLabel.location                 = New-Object System.Drawing.Point((($mainGroupBox.ClientSize.Width - $appDescriptionLabel.Width)/2),(($mainGroupBox.Height - $appDescriptionLabel.Height)/2))
$appDescriptionLabel.Font                     = 'Verdana,8'
$appDescriptionLabel.TextAlign = 'MiddleCenter'
$appDescriptionLabel.BackColor = 'Transparent'

$mainGroupBox.Controls.AddRange(@($appDescriptionLabel))

$global:removeAppLabel = New-Object system.Windows.Forms.Label
$removeAppLabel.text                     = "Desinstalar"
$removeAppLabel.AutoSize = $false
$removeAppLabel.width = $Form.ClientSize.Width
$removeAppLabel.location                 = New-Object System.Drawing.Point(-5, (($form.ClientRectangle.Bottom)-20))
$removeAppLabel.Font                     = 'Verdana,8'
$removeAppLabel.TextAlign = 'TopRight'
$removeAppLabel.BackColor = 'Transparent'
$removeAppLabel.ForeColor = 'Blue'
$removeAppLabel.Cursor = 'Hand'
$removeAppLabel.visible = $true

function buttonAndStatusText {
    $global:status = Get-Content $AppDir\status.txt
    if ($status -eq 0){
        $actionButton.text = 'Ativar'
        $statusValueLabel.text = 'Desativado'
        $statusValueLabel.ForeColor = 'red'
        $statusLabel.location                 = New-Object System.Drawing.Point((($Form.ClientSize.Width - $statusLabel.Width)/2 - 60),($form.ClientRectangle.top + 100))
        $statusValueLabel.location                 = New-Object System.Drawing.Point((($Form.ClientSize.Width - $statusValueLabel.Width)/2 + 60),($form.ClientRectangle.top + 100))


    }else{
        $actionButton.text = 'Desativar'
        $statusValueLabel.text = 'Ativado'
        $statusValueLabel.ForeColor = 'green'
        $statusLabel.location                 = New-Object System.Drawing.Point((($Form.ClientSize.Width - $statusLabel.Width)/2 - 50),($form.ClientRectangle.top + 100))
        $statusValueLabel.location                 = New-Object System.Drawing.Point((($Form.ClientSize.Width - $statusValueLabel.Width)/2 + 50),($form.ClientRectangle.top + 100))
    }
}


function checkAhk {
    buttonAndStatusText
    [System.Windows.Forms.Application]::DoEvents()
    
    $checkAHK1 = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | ? {$_.displayname -like '*AutoHotkey*'}
    $checkAHK2 = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | ? {$_.displayname -like '*AutoHotkey*'}

    #INSTALANDO AHK
    if (!$checkAHK1 -and !$checkAHK2){
        iwr -UseBasicParsing https://www.mediafire.com/file_premium/95688q2rwtzf6dv/ahk.exe/file -OutFile $AppDir\ahk.exe
        start $AppDir\ahk.exe /s -Wait
    
        if (!$?){
            $msg = [System.Windows.Forms.MessageBox]::Show("Não foi possível realizar o download e instalação do AutoHotKey, complemento necessário para a primeira execução do meuCedilha.`n`nVerifique se o computador está conectado à internet e tente novamente", 'Canal Alltomatizando - meuCedilha', 'Ok', 'Warning')
            $form.Close()
        }else{
            $actionButton.Enabled = $true
        }
    }else{
            $actionButton.Enabled = $true
    }
}

function mainAction {
    if ($actionButton.Text -eq 'Ativar'){
        start $AppDir\meuCedilha.ahk
        New-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run' -Name "meuCedilha" -Value "$AppDir\meuCedilha.ahk" -Force
        '1' > $AppDir\status.txt
        buttonAndStatusText
        $msg = [System.Windows.Forms.MessageBox]::Show("Ativação realizada com sucesso!`n`nDigite ""Alt + C"" para fazer o cedilha.", 'Canal Alltomatizando - meuCedilha', 'Ok', 'Information')

    }else{
        taskkill /im autohotkey.exe /f
        Remove-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run' -Name "meuCedilha" -Force
        '0' > $AppDir\status.txt
        buttonAndStatusText
        $msg = [System.Windows.Forms.MessageBox]::Show("Automação desativada.`n`n""Alt + C"" não irá digitar mais o cedilha.", 'Canal Alltomatizando - meuCedilha', 'Ok', 'Information')

    }
}

function removeApp {
        [System.Windows.Forms.Application]::DoEvents()
        Remove-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'meuCedilha' -Force
        taskkill /im 'autohotkey.exe' /f
        Start-Process $AppDir\ahk.exe -ArgumentList '/S /uninstall' -Wait
        if($?){
            $msg = [System.Windows.Forms.MessageBox]::Show("Todos os arquivos e complementos referentes ao meuCedilha foram removidos com sucesso!", 'Canal Alltomatizando - meuCedilha', 'Ok', 'Information') 
            [void]$Form.Close() 
        }
        
        rd $AppDir -Confirm:$false -Recurse -Force
}


$Form.Controls.AddRange(@($statusLabel, $statusValueLabel, $mainGroupBox, $actionButton, $removeAppLabel))

$Form.add_shown({checkAhk})
$actionButton.add_click({mainAction})
$removeAppLabel.add_click({removeApp})

$form.ShowDialog()