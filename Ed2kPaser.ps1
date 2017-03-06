Function Touch-File
{
    $file = $args[0]
    if($file -eq $null) {
        throw "No filename supplied"
    }

    if(Test-Path $file)
    {
        (Get-ChildItem $file).LastWriteTime = Get-Date
    }
    else
    {
        Set-Content $null -LiteralPath $file -Encoding Byte
    }
}

<#
	.SYNOPSIS
		Fix a string to accord with the valid Windows directory / file name.

	.DESCRIPTION
		Windows file system reserved some special characters such as /, |, \, ?, ", *, :, <, >, ..
		And sould not use device file names such as CON, PRN, AUX, CLOCK$, NUL, COM1, COM2, COM3, 
		COM4, COM5, COM6, COM7, COM8, COM9, LPT1, LPT2, LPT3, LPT4, LPT5, LPT6, LPT7, LPT8, and LPT9.

	.PARAMETER  fsName
		The inputed directory / file name.

	.EXAMPLE
		Get-ValidFileSystemName 'abc*def/ghi?jkl'

	.EXAMPLE
		'abc*def/ghi?jkl', 'CON.NUL' | Get-ValidFileSystemName

	.INPUTS
		System.String

	.OUTPUTS
		System.String

	.NOTES
		Be care of the limitation of the max length of full file name by file system.

	.LINK
		about_functions_advanced

	.LINK
		about_comment_based_help
#>
function Get-ValidFileSystemName
{
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[string]$FileSystemName
	)
	
	process{
		$deviceFiles = 'CON', 'PRN', 'AUX', 'CLOCK$', 'NUL', 'COM1', 'COM2', 'COM3', 'COM4', 'COM5', 'COM6', 'COM7', 'COM8', 'COM9', 'LPT1', 'LPT2', 'LPT3', 'LPT4', 'LPT5', 'LPT6', 'LPT7', 'LPT8', 'LPT9'
		$fileName = [System.IO.Path]::GetFileNameWithoutExtension($FileSystemName)
		$extension = [System.IO.Path]::GetExtension($FileSystemName)
		if ($extension.StartsWith('.'))
		{
			$extension = $extension.Substring(1)
		}
		
		if ($deviceFiles -contains $fileName)
		{
			$fileName = "_$fileName"
		}
		
		if ($deviceFiles -contains $extension)
		{
			$extension = "_$extension"	
		}
		
		if ($extension -eq '')
		{
			$FileSystemName = "$fileName$extension"
		}
		else
		{
			$FileSystemName = "$fileName.$extension"	
		}
		
		$FileSystemName = $FileSystemName -creplace '[\\/|?"*:<>\x00\x1F\t\r\n]', '.'
		return $FileSystemName
	}
}

#dir \\htpc\f$\sharevideo\Android深入浅出 | % {Touch-File $_.Name}

#'CON.NUL', 'CON', 'nul' | Get-ValidFileSystemName
#return

$json = (gc ed2k.json -Encoding 'UTF8') -join "`n" | ConvertFrom-Json
$rootFolder = $json.title | Get-ValidFileSystemName
md $rootFolder
$json.folders | % {
    $folderName = $_.name | Get-ValidFileSystemName
    $fileNames = $_.files | Get-ValidFileSystemName

    md (Join-Path $rootFolder $folderName)
    foreach ($fileName in $fileNames) {
		$newPath = Join-Path $rootFolder $folderName
        $newPath = Join-Path $newPath $fileName
        mv -LiteralPath $fileName $newPath
        # -WhatIf
    }
}