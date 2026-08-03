param(
    [Parameter(Mandatory = $true)]
    [string]$Title,

    [string]$Date = (Get-Date -Format 'yyyy-MM-dd')
)

# Slugify: lowercase, alphanumerics only, spaces to hyphens
$slug = $Title.ToLowerInvariant() -replace "[^a-z0-9\s-]", '' -replace '\s+', '-' -replace '-+', '-'
$slug = $slug.Trim('-')

if (-not $slug) {
    Write-Error "Title produced an empty slug."
    exit 1
}

$path = Join-Path $PSScriptRoot "_posts\$Date-$slug.md"

if (Test-Path $path) {
    Write-Error "Already exists: $path"
    exit 1
}

# Quote for YAML: double-quoted scalar with inner quotes/backslashes escaped
$yamlTitle = '"' + ($Title -replace '\\', '\\' -replace '"', '\"') + '"'

$content = @"
---
layout: post
title: $yamlTitle
date: $Date
description:
tagline:
image: https://blog.eterm.uk/assets/img/
---
# $Title

"@

Set-Content -Path $path -Value $content -Encoding utf8NoBOM
Write-Host "Created $path"
