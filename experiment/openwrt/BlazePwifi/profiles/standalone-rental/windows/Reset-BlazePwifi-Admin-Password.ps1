$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName Microsoft.VisualBasic

function Show-Error([string]$Message) {
    [System.Windows.Forms.MessageBox]::Show($Message, "BlazePwifi Admin Reset", "OK", "Error") | Out-Null
}
function Show-Info([string]$Message) {
    [System.Windows.Forms.MessageBox]::Show($Message, "BlazePwifi Admin Reset", "OK", "Information") | Out-Null
}
function Invoke-NativeCapture {
    param([string]$FilePath,[string[]]$Arguments)
    $old = $ErrorActionPreference
    try {
        $ErrorActionPreference = "Continue"
        $lines = & $FilePath @Arguments 2>&1
        $code = $LASTEXITCODE
        $text = (($lines | ForEach-Object { $_.ToString() }) -join [Environment]::NewLine)
        [pscustomobject]@{ ExitCode=$code; Output=$text }
    } finally {
        $ErrorActionPreference = $old
    }
}
function Prompt-Password {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "BlazePwifi Reset - SSH Password"
    $form.Width = 420
    $form.Height = 175
    $form.StartPosition = "CenterScreen"
    $form.TopMost = $true
    $label = New-Object System.Windows.Forms.Label
    $label.Text = "Enter the router SSH/root password."
    $label.AutoSize = $true
    $label.Left = 18
    $label.Top = 18
    $form.Controls.Add($label)
    $box = New-Object System.Windows.Forms.TextBox
    $box.Left = 18
    $box.Top = 50
    $box.Width = 365
    $box.UseSystemPasswordChar = $true
    $form.Controls.Add($box)
    $ok = New-Object System.Windows.Forms.Button
    $ok.Text = "Continue"
    $ok.Left = 218
    $ok.Top = 86
    $ok.Width = 80
    $ok.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.Controls.Add($ok)
    $cancel = New-Object System.Windows.Forms.Button
    $cancel.Text = "Cancel"
    $cancel.Left = 303
    $cancel.Top = 86
    $cancel.Width = 80
    $cancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.Controls.Add($cancel)
    $form.AcceptButton = $ok
    $form.CancelButton = $cancel
    $form.Add_Shown({$box.Focus()})
    $r = $form.ShowDialog()
    if ($r -ne [System.Windows.Forms.DialogResult]::OK) { return $null }
    return $box.Text
}

$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
$Plink = Join-Path $Here "plink.exe"
if (!(Test-Path $Plink)) {
    Show-Error "plink.exe is missing. Extract the complete BlazePwifi Windows OneClick package first."
    exit 2
}

$gateway = ""
try {
    $gateway = (Get-NetRoute -DestinationPrefix "0.0.0.0/0" -ErrorAction Stop |
        Where-Object {$_.NextHop -and $_.NextHop -ne "0.0.0.0"} |
        Sort-Object RouteMetric |
        Select-Object -First 1 -ExpandProperty NextHop)
} catch {}

$HostName = [Microsoft.VisualBasic.Interaction]::InputBox(
    "Router IP or hostname:" + [Environment]::NewLine + [Environment]::NewLine + "Example: 192.168.1.1",
    "BlazePwifi Admin Reset",
    $gateway
).Trim()
if (!$HostName) { exit 1 }

$SshUser = [Microsoft.VisualBasic.Interaction]::InputBox(
    "SSH username:",
    "BlazePwifi Admin Reset",
    "root"
).Trim()
if (!$SshUser) { exit 1 }

$PortText = [Microsoft.VisualBasic.Interaction]::InputBox(
    "SSH port:",
    "BlazePwifi Admin Reset",
    "22"
).Trim()
[int]$Port = 22
if (![int]::TryParse($PortText,[ref]$Port) -or $Port -lt 1 -or $Port -gt 65535) {
    Show-Error "Invalid SSH port."
    exit 3
}

$Password = Prompt-Password
if ($null -eq $Password -or $Password.Length -eq 0) { exit 1 }

$PwFile = Join-Path $env:TEMP ("blazepwifi-reset-" + [Guid]::NewGuid().ToString("N") + ".pw")
[IO.File]::WriteAllText($PwFile,$Password,[Text.Encoding]::ASCII)
$Password = $null
$HostKeyArgs = @()

try {
    $base = @("-ssh","-P",$Port.ToString(),"-batch","-pwfile",$PwFile)
    $probe = Invoke-NativeCapture $Plink ($base + @("$SshUser@$HostName","echo BLAZE_SSH_OK"))

    if ($probe.ExitCode -ne 0) {
        $m = [regex]::Match($probe.Output,'(?im)(ssh-[A-Za-z0-9@._+-]+|ecdsa-[A-Za-z0-9@._+-]+)\s+\d+\s+SHA256:[A-Za-z0-9+/=]+')
        if (!$m.Success) {
            Write-Host $probe.Output
            Show-Error "SSH connection failed. Check router IP, SSH username/password and SSH service."
            exit 4
        }
        $fingerprint = $m.Value.Trim()
        $msg = "First connection to this router." + [Environment]::NewLine + [Environment]::NewLine +
               "SSH host key:" + [Environment]::NewLine + $fingerprint + [Environment]::NewLine + [Environment]::NewLine +
               "Trust this router?"
        $choice = [System.Windows.Forms.MessageBox]::Show(
            $msg,
            "BlazePwifi Admin Reset",
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Question
        )
        if ($choice -ne [System.Windows.Forms.DialogResult]::Yes) { exit 5 }
        $HostKeyArgs = @("-hostkey",$fingerprint)
        $probe = Invoke-NativeCapture $Plink ($base + $HostKeyArgs + @("$SshUser@$HostName","echo BLAZE_SSH_OK"))
        if ($probe.ExitCode -ne 0 -or $probe.Output -notmatch "BLAZE_SSH_OK") {
            Write-Host $probe.Output
            Show-Error "SSH authentication failed after host-key verification."
            exit 6
        }
    } elseif ($probe.Output -notmatch "BLAZE_SSH_OK") {
        Show-Error "SSH connected but did not return the expected response."
        exit 6
    }

    Write-Host "SSH connection OK." -ForegroundColor Green
    Write-Host "Resetting BlazePwifi admin account..." -ForegroundColor Cyan

    $remote = @'
set -eu
STATE=/etc/blazepwifi/state
USERS="$STATE/admin-users.tsv"
SESS=/tmp/blazepwifi/admin-sessions.tsv
FAIL=/tmp/blazepwifi/auth-failures.tsv

[ -d /etc/blazepwifi ] || {
  echo "ERROR: BlazePwifi is not installed." >&2
  exit 20
}

mkdir -p "$STATE" /tmp/blazepwifi
touch "$USERS"

PASS=admin
ROUNDS=2048
SALT="$(printf '%s|%s|reset-admin' "$(date +%s)" "$$" | sha256sum | awk '{print $1}' | cut -c1-16)"

sha256i() {
  p="$1"; s="$2"; r="$3"
  v="$(printf '%s|%s|%s' "$s" "$p" "$s" | sha256sum | awk '{print $1}')"
  i=1
  while [ "$i" -lt "$r" ]; do
    v="$(printf '%s|%s|%s' "$v" "$p" "$s" | sha256sum | awk '{print $1}')"
    i=$((i+1))
  done
  printf '%s' "$v"
}

HASH="$(sha256i "$PASS" "$SALT" "$ROUNDS")"
TMP="$STATE/.admin-users.reset.$$"
awk -F '\t' '$1!="admin"{print}' "$USERS" > "$TMP"
printf 'admin\tadmin\tsha256i\t%s\t%s\t%s\t0\n' "$SALT" "$HASH" "$ROUNDS" >> "$TMP"
chmod 600 "$TMP"
mv "$TMP" "$USERS"

: > "$SESS"
: > "$FAIL"
chmod 600 "$SESS" "$FAIL"

CHECK="$(sha256i admin "$SALT" "$ROUNDS")"
STORED="$(awk -F '\t' '$1=="admin"{print $5; exit}' "$USERS")"
[ "$CHECK" = "$STORED" ] || {
  echo "ERROR: password reset self-verification failed." >&2
  exit 21
}

printf 'admin\n' > /etc/blazepwifi/INITIAL_ADMIN_PASSWORD
chmod 600 /etc/blazepwifi/INITIAL_ADMIN_PASSWORD
sync

echo "BLAZE_RESET_OK"
echo "Username: admin"
echo "Password: admin"
'@

    $result = Invoke-NativeCapture $Plink ($base + $HostKeyArgs + @("$SshUser@$HostName",$remote))
    Write-Host $result.Output
    if ($result.ExitCode -ne 0 -or $result.Output -notmatch "BLAZE_RESET_OK") {
        Show-Error "Password reset failed. Review the console output."
        exit 7
    }

    $done = "BlazePwifi administrator reset complete." + [Environment]::NewLine + [Environment]::NewLine +
            "Username: admin" + [Environment]::NewLine + "Password: admin"
    Show-Info $done
    exit 0
}
finally {
    if (Test-Path $PwFile) {
        try { [IO.File]::WriteAllText($PwFile,("0"*128)) } catch {}
        Remove-Item -Force $PwFile -ErrorAction SilentlyContinue
    }
}
