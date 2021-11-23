#!/usr/bin/env powershell
##
# Restic backup script performing basic operations of reading environment file and pruning older targets
#
#

param([switch]$Log)

$RESTIC_BIN = 'c:\Windows\System32\restic.exe'
$CFG_DIR = '~\.config\restic'

$self = Split-Path -Leaf $PSCommandPath
$log_name = 'Restic Backup'
$log_parameters = @{
    'LogName'  = $log_name
    'Source'  = $self
}

if ($Log.IsPresent) {
    if (![System.Diagnostics.EventLog]::SourceExists($log_name)) {
        New-EventLog @log_parameters
    }
}

# Read environment configuration
$vars = Get-Content "$CFG_DIR\env.conf" | Out-String | ConvertFrom-StringData
foreach ($key in $vars.Keys) {
    New-Variable -Name $key -Value $vars.$key
}

# Make sure path's are expanded
$includes = Resolve-Path $CFG_DIR\includes.txt
$excludes = Resolve-Path $CFG_DIR\excludes.txt

$exec_backup = {
    Write-Output "--- Running backup command ---"

    # Run backup
    & $RESTIC_BIN backup `
                    --files-from $includes `
                    --exclude-file $excludes 2>&1
}

$exec_forget = {
    Write-Output "--- Running cleanup command ---"

    # Remove snapshots according to policy
    # If run cron more frequently, might add --keep-hourly 24
    & $RESTIC_BIN forget `
                    --keep-daily 7 `
                    --keep-weekly 4 `
                    --keep-monthly 12 `
                    --keep-yearly 7 2>&1

}

$exec_prune = {
    Write-Output "--- Running prune command ---"

    # Remove unneeded data from the repository
    & $RESTIC_BIN prune 2>&1
}
$exec_check = {
    Write-Output "--- Running integrity check command ---"

    # Check the repository for errors
    & $RESTIC_BIN check 2>&1
}

if ($Log.IsPresent) {
    # Execution with capture

    $backup_log = $log_parameters + @{
        'EventId' = 1001
        'Message' = & $exec_backup | Out-String
    }
    Write-EventLog @backup_log

    $forget_log = $log_parameters + @{
        'EventId' = 1002
        'Message' = & $exec_forget | Out-String
    }
    Write-EventLog @forget_log

    $prune_log = $log_parameters + @{
        'EventId' = 1003
        'Message' = & $exec_prune | Out-String
    }
    Write-EventLog @prune_log

    $check_log = $log_parameters + @{
        'EventId' = 1004
        'Message' = & $exec_check | Out-String
    }
    Write-EventLog @check_log

} else {
    # Standard execution with no special capture
    & $exec_backup
    & $exec_forget
    & $exec_prune
    & $exec_check
}


# Done