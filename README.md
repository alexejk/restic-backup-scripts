# Helper Restic backup scripts

This is a very basic set of [Restic](https://restic.net/) backup scripts that I use for consistent backups between multiple machines.

## Installation

Link or copy corresponding script `restic-backup.(ps1|sh)` in a `~/bin/`.

Hint to Windows users - symbolic links can be created like this in powershell:

```powershell
New-Item -Path ~\bin\restic-backup.ps1 -ItemType SymbolicLink -Value ~\path-to-this-repo\restic-backup.ps1 
```

Put configurations (from `sample-config/restic`) into `~/.config/restic`

### Assumptions

Scripts assume a few things described below. If any of the assumptions, do not match your needs - adjust this in scripts.

* Location of Restic binary:
  * On Windows: `C:\Windows\System32\restic.exe`
  * On Linux: `/usr/bin/restic`
* Location of configuration files is `~/.config/restic`
* On every backup we perform purges and keep following snapshots:
  * 7 Daily
  * 4 Weekly
  * 12 Monthly
  * 7 Yearly
* Backup is performed every 2 hours from the time user logs in. This is assumed to be a sane default for incremental backups. Adjust the value in systemd or task scheduler accordingly.

## Configuration

Configuration folder contains:

* Environment file (`env.conf`) used by scripts and also Systemd Units (if on Linux)
* Includes file (`includes.txt`) - file having a set of paths with potential wildcards of items to backup
* Excludes file (`excludes.txt`) - a file with a set of exclude patterns similar to `.gitignore` files.
* Password file `password` (put your repository password here) - this is used as `--password-file` for restic
* Repository file `repository` (put your repository path) - this is used as `--repository-file` for restic

If using authentication for a REST server, make sure entire `repository` file value is URL-encoded (specifically basic authentication segment).

## Scheduling

**Linux**
On Linux systems that run Systemd - you could use user scoped unit files found in `sample-config/systemd` folder.

**Windows**
On Windows systems - use Task Scheduler to setup executions of the script. You can import from `sample-config/task-scheduler` folder. Make sure to edit the command line (replace `YOUR_USER` with your username) before import or from GUI.

## Logging

**Linux**
On Linux system, it's assumed that systemd journal will be taking care of the logging of output.

**Windows**
On Windows systems, Powershell script accepts a `-Log` flag which will attempt to create (may need admin privileges to create initial application entry) a new Log application for Event Viewer and all different steps of the execution will be logged as separate events.

## Disclaimer & Contribution

These scripts are provided 'as-is' with no warranty. They have been only tested on my machines and are suitable for my purpose. You are free to modify these scripts in any way you see fit.

Feel free to contribute back any improvements to these scripts and/or documentation.
