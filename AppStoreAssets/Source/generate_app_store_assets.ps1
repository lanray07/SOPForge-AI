param(
    [string]$OutputRoot = (Join-Path $PSScriptRoot '..')
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$root = Resolve-Path $OutputRoot
$iphoneDir = Join-Path $root 'Screenshots/iPhone_6_9'
$ipadDir = Join-Path $root 'Screenshots/iPad_13'
$iconDir = Join-Path $root 'AppIcon'

New-Item -ItemType Directory -Force -Path $iphoneDir | Out-Null
New-Item -ItemType Directory -Force -Path $ipadDir | Out-Null
New-Item -ItemType Directory -Force -Path $iconDir | Out-Null

function ColorFromHex([string]$hex) {
    $value = $hex.TrimStart('#')
    [System.Drawing.Color]::FromArgb(
        255,
        [Convert]::ToInt32($value.Substring(0, 2), 16),
        [Convert]::ToInt32($value.Substring(2, 2), 16),
        [Convert]::ToInt32($value.Substring(4, 2), 16)
    )
}

function New-Font([float]$size, [System.Drawing.FontStyle]$style = [System.Drawing.FontStyle]::Regular) {
    New-Object System.Drawing.Font -ArgumentList @('Segoe UI', $size, $style, ([System.Drawing.GraphicsUnit]::Pixel))
}

function Draw-RoundedRect($g, [float]$x, [float]$y, [float]$w, [float]$h, [float]$r, $brush, $pen = $null) {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $r * 2
    $path.AddArc($x, $y, $d, $d, 180, 90)
    $path.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
    $path.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
    $path.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
    $path.CloseFigure()
    if ($brush) { $g.FillPath($brush, $path) }
    if ($pen) { $g.DrawPath($pen, $path) }
    $path.Dispose()
}

function Draw-Text($g, [string]$text, [float]$x, [float]$y, [float]$w, [float]$h, $font, $brush, [string]$align = 'Near') {
    $format = New-Object System.Drawing.StringFormat
    $format.Alignment = [System.Drawing.StringAlignment]::$align
    $format.LineAlignment = [System.Drawing.StringAlignment]::Near
    $format.Trimming = [System.Drawing.StringTrimming]::EllipsisWord
    $format.FormatFlags = [System.Drawing.StringFormatFlags]::LineLimit
    $rect = New-Object System.Drawing.RectangleF $x, $y, $w, $h
    $g.DrawString($text, $font, $brush, $rect, $format)
    $format.Dispose()
}

function Draw-PhoneFrame($g, [float]$x, [float]$y, [float]$w, [float]$h, [hashtable]$screen) {
    $black = New-Object System.Drawing.SolidBrush (ColorFromHex '#111827')
    $white = New-Object System.Drawing.SolidBrush (ColorFromHex '#FFFFFF')
    $light = New-Object System.Drawing.SolidBrush (ColorFromHex '#F3F5F9')
    Draw-RoundedRect $g $x $y $w $h 58 $black
    Draw-RoundedRect $g ($x + 18) ($y + 18) ($w - 36) ($h - 36) 42 $white
    Draw-RoundedRect $g ($x + ($w / 2) - 76) ($y + 26) 152 32 16 $black
    $sx = $x + 42
    $sy = $y + 82
    $sw = $w - 84
    $accent = New-Object System.Drawing.SolidBrush (ColorFromHex '#3158F4')
    $purple = New-Object System.Drawing.SolidBrush (ColorFromHex '#7A4CE0')
    $green = New-Object System.Drawing.SolidBrush (ColorFromHex '#0F8B62')
    $charcoal = New-Object System.Drawing.SolidBrush (ColorFromHex '#111827')
    $muted = New-Object System.Drawing.SolidBrush (ColorFromHex '#667085')
    $card = New-Object System.Drawing.SolidBrush (ColorFromHex '#F7F8FB')
    $titleFont = New-Font 34 ([System.Drawing.FontStyle]::Bold)
    $bodyFont = New-Font 22
    $smallFont = New-Font 18
    Draw-Text $g $screen.Title $sx $sy $sw 90 $titleFont $charcoal
    Draw-Text $g $screen.Subtitle $sx ($sy + 66) $sw 80 $bodyFont $muted
    $cy = $sy + 170
    foreach ($item in $screen.Cards) {
        Draw-RoundedRect $g $sx $cy $sw 130 18 $card
        $dotBrush = switch ($item.Tint) {
            'purple' { $purple }
            'green' { $green }
            default { $accent }
        }
        Draw-RoundedRect $g ($sx + 26) ($cy + 30) 68 68 18 $dotBrush
        Draw-Text $g $item.Title ($sx + 118) ($cy + 28) ($sw - 150) 35 $bodyFont $charcoal
        Draw-Text $g $item.Body ($sx + 118) ($cy + 66) ($sw - 150) 46 $smallFont $muted
        $cy += 154
    }
    $titleFont.Dispose(); $bodyFont.Dispose(); $smallFont.Dispose()
}

function Draw-iPadFrame($g, [float]$x, [float]$y, [float]$w, [float]$h, [hashtable]$screen) {
    $black = New-Object System.Drawing.SolidBrush (ColorFromHex '#111827')
    $white = New-Object System.Drawing.SolidBrush (ColorFromHex '#FFFFFF')
    Draw-RoundedRect $g $x $y $w $h 48 $black
    Draw-RoundedRect $g ($x + 26) ($y + 26) ($w - 52) ($h - 52) 30 $white
    $sx = $x + 74
    $sy = $y + 78
    $sw = $w - 148
    $accent = New-Object System.Drawing.SolidBrush (ColorFromHex '#3158F4')
    $purple = New-Object System.Drawing.SolidBrush (ColorFromHex '#7A4CE0')
    $green = New-Object System.Drawing.SolidBrush (ColorFromHex '#0F8B62')
    $charcoal = New-Object System.Drawing.SolidBrush (ColorFromHex '#111827')
    $muted = New-Object System.Drawing.SolidBrush (ColorFromHex '#667085')
    $card = New-Object System.Drawing.SolidBrush (ColorFromHex '#F7F8FB')
    $titleFont = New-Font 48 ([System.Drawing.FontStyle]::Bold)
    $bodyFont = New-Font 28
    $smallFont = New-Font 22
    Draw-Text $g $screen.Title $sx $sy $sw 96 $titleFont $charcoal
    Draw-Text $g $screen.Subtitle $sx ($sy + 88) $sw 70 $bodyFont $muted
    $cy = $sy + 190
    $colW = ($sw - 24) / 2
    $i = 0
    foreach ($item in $screen.Cards) {
        $cx = $sx + (($i % 2) * ($colW + 24))
        if ($i -gt 0 -and $i % 2 -eq 0) { $cy += 184 }
        Draw-RoundedRect $g $cx $cy $colW 160 18 $card
        $dotBrush = switch ($item.Tint) {
            'purple' { $purple }
            'green' { $green }
            default { $accent }
        }
        Draw-RoundedRect $g ($cx + 28) ($cy + 34) 78 78 18 $dotBrush
        Draw-Text $g $item.Title ($cx + 130) ($cy + 32) ($colW - 160) 45 $bodyFont $charcoal
        Draw-Text $g $item.Body ($cx + 130) ($cy + 80) ($colW - 160) 54 $smallFont $muted
        $i++
    }
    $titleFont.Dispose(); $bodyFont.Dispose(); $smallFont.Dispose()
}

function New-Screenshot([string]$path, [int]$width, [int]$height, [string]$headline, [string]$subhead, [hashtable]$screen, [bool]$iPad) {
    $bmp = New-Object System.Drawing.Bitmap $width, $height
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    $rect = New-Object System.Drawing.Rectangle 0, 0, $width, $height
    $bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush $rect, (ColorFromHex '#F7F9FF'), (ColorFromHex '#EEF0FF'), 45
    $g.FillRectangle($bg, $rect)
    $accent = New-Object System.Drawing.SolidBrush (ColorFromHex '#3158F4')
    $charcoal = New-Object System.Drawing.SolidBrush (ColorFromHex '#111827')
    $muted = New-Object System.Drawing.SolidBrush (ColorFromHex '#5D6778')
    $brandFont = New-Font ([Math]::Round($width * 0.032)) ([System.Drawing.FontStyle]::Bold)
    $headlineFont = New-Font ([Math]::Round($width * 0.068)) ([System.Drawing.FontStyle]::Bold)
    $subFont = New-Font ([Math]::Round($width * 0.030))
    $margin = [Math]::Round($width * 0.085)
    Draw-Text $g 'SOPForge AI' $margin ([Math]::Round($height * 0.055)) ($width - ($margin * 2)) 60 $brandFont $accent
    Draw-Text $g $headline $margin ([Math]::Round($height * 0.095)) ($width - ($margin * 2)) ([Math]::Round($height * 0.13)) $headlineFont $charcoal
    Draw-Text $g $subhead $margin ([Math]::Round($height * 0.225)) ($width - ($margin * 2)) ([Math]::Round($height * 0.07)) $subFont $muted
    if ($iPad) {
        Draw-iPadFrame $g ([Math]::Round($width * 0.13)) ([Math]::Round($height * 0.36)) ([Math]::Round($width * 0.74)) ([Math]::Round($height * 0.56)) $screen
    } else {
        Draw-PhoneFrame $g ([Math]::Round($width * 0.20)) ([Math]::Round($height * 0.37)) ([Math]::Round($width * 0.60)) ([Math]::Round($height * 0.56)) $screen
    }
    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose(); $bmp.Dispose(); $bg.Dispose(); $accent.Dispose(); $charcoal.Dispose(); $muted.Dispose(); $brandFont.Dispose(); $headlineFont.Dispose(); $subFont.Dispose()
}

$screens = @(
    @{
        File='01-dashboard.png'
        Headline='Build clear SOPs in minutes'
        Subhead='Turn messy team processes into reusable operating documents.'
        Screen=@{
            Title='Dashboard'
            Subtitle='Quick actions for operations teams'
            Cards=@(
                @{Title='Generate SOP'; Body='Purpose, scope, steps and sign-off'; Tint='blue'},
                @{Title='Create Checklist'; Body='Opening, closing and inspection flows'; Tint='green'},
                @{Title='Training Guide'; Body='Role-specific learning plans'; Tint='purple'}
            )
        }
    },
    @{
        File='02-sop-generator.png'
        Headline='Capture every process detail'
        Subhead='Add tools, safety notes, quality standards and tone before generation.'
        Screen=@{
            Title='Generate SOP'
            Subtitle='Process details'
            Cards=@(
                @{Title='Task name'; Body='Weekly site inspection'; Tint='blue'},
                @{Title='Safety notes'; Body='PPE, hazards and escalation steps'; Tint='purple'},
                @{Title='Quality standards'; Body='Supervisor review and completion checks'; Tint='green'}
            )
        }
    },
    @{
        File='03-voice-to-sop.png'
        Headline='Dictate rough notes'
        Subhead='Voice-to-SOP cleans spoken instructions into an editable draft.'
        Screen=@{
            Title='Voice-to-SOP'
            Subtitle='Record or type process notes'
            Cards=@(
                @{Title='Record'; Body='Capture staff explanations on site'; Tint='purple'},
                @{Title='Convert'; Body='Generate a clear SOP draft'; Tint='blue'},
                @{Title='Edit'; Body='Review before saving or sharing'; Tint='green'}
            )
        }
    },
    @{
        File='04-checklists-training.png'
        Headline='Standardize daily work'
        Subhead='Create checklists and training guides for repeatable team workflows.'
        Screen=@{
            Title='Checklist Builder'
            Subtitle='Templates for field and office work'
            Cards=@(
                @{Title='Opening Checklist'; Body='Start each shift with clarity'; Tint='green'},
                @{Title='Safety Procedure'; Body='Capture risk controls and review'; Tint='purple'},
                @{Title='Training Guide'; Body='Step-by-step learning and quiz notes'; Tint='blue'}
            )
        }
    },
    @{
        File='05-library-pdf.png'
        Headline='Save, edit and export PDFs'
        Subhead='Keep documents offline-friendly and share polished PDFs with supervisors.'
        Screen=@{
            Title='Saved Documents'
            Subtitle='Search, duplicate, edit and export'
            Cards=@(
                @{Title='Site Opening SOP'; Body='Version 1 - Cleaning Company'; Tint='blue'},
                @{Title='Inspection Checklist'; Body='7 checklist items'; Tint='green'},
                @{Title='New Hire Guide'; Body='Role-specific training plan'; Tint='purple'}
            )
        }
    }
)

foreach ($screen in $screens) {
    New-Screenshot (Join-Path $iphoneDir $screen.File) 1290 2796 $screen.Headline $screen.Subhead $screen.Screen $false
    New-Screenshot (Join-Path $ipadDir $screen.File) 2048 2732 $screen.Headline $screen.Subhead $screen.Screen $true
}

Copy-Item -Force (Join-Path $root '../SOPForgeAI/Resources/Assets.xcassets/AppIcon.appiconset/Icon-1024.png') (Join-Path $iconDir 'app-icon-1024.png')

Write-Output "Generated App Store assets in $root"
