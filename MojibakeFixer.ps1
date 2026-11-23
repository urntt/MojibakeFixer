# Mojibake Fixer - Windows PowerShell 5.1 and later.
# This app only changes text in memory. It never overwrites source files.

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

$script:encodings = @(
    [pscustomobject]@{ Name = 'Western European (Windows-1252)'; Page = 1252 },
    [pscustomobject]@{ Name = 'Latin-1 (ISO-8859-1)'; Page = 28591 },
    [pscustomobject]@{ Name = 'Chinese Simplified (GBK)'; Page = 936 },
    [pscustomobject]@{ Name = 'Japanese (Shift-JIS)'; Page = 932 },
    [pscustomobject]@{ Name = 'Korean (CP949)'; Page = 949 },
    [pscustomobject]@{ Name = 'Chinese Traditional (Big5)'; Page = 950 },
    [pscustomobject]@{ Name = 'Cyrillic (Windows-1251)'; Page = 1251 },
    [pscustomobject]@{ Name = 'Central European (Windows-1250)'; Page = 1250 }
)
$script:utf8 = New-Object System.Text.UTF8Encoding($false, $true)

function Get-StrictEncoding([int] $codePage) {
    return [System.Text.Encoding]::GetEncoding(
        $codePage,
        (New-Object System.Text.EncoderExceptionFallback),
        (New-Object System.Text.DecoderExceptionFallback)
    )
}

function Convert-Text([string] $inputText, [int] $codePage, [bool] $repair) {
    $otherEncoding = Get-StrictEncoding $codePage
    if ($repair) {
        # Undo: original UTF-8 bytes -> wrongly decoded with another encoding.
        $bytes = $otherEncoding.GetBytes($inputText)
        return $script:utf8.GetString($bytes)
    }
    else {
        # Simulate: original Unicode text -> UTF-8 bytes -> decoded incorrectly.
        $bytes = $script:utf8.GetBytes($inputText)
        return $otherEncoding.GetString($bytes)
    }
}

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Mojibake Fixer - Repair or Make Garbled Text'
$form.StartPosition = 'CenterScreen'
$form.ClientSize = New-Object System.Drawing.Size(850, 655)
$form.MinimumSize = New-Object System.Drawing.Size(780, 625)
$form.BackColor = [System.Drawing.Color]::FromArgb(248, 249, 251)
$form.Font = New-Object System.Drawing.Font('Segoe UI', 10)

$title = New-Object System.Windows.Forms.Label
$title.Text = 'Mojibake Fixer'
$title.Font = New-Object System.Drawing.Font('Segoe UI', 16, [System.Drawing.FontStyle]::Bold)
$title.Location = New-Object System.Drawing.Point(18, 12)
$title.Size = New-Object System.Drawing.Size(450, 36)
$form.Controls.Add($title)

$subtitle = New-Object System.Windows.Forms.Label
$subtitle.Text = 'Paste text below. Repair = garbled to normal; Reverse = normal to garbled.'
$subtitle.Location = New-Object System.Drawing.Point(19, 48)
$subtitle.Size = New-Object System.Drawing.Size(800, 25)
$subtitle.Anchor = 'Top,Left,Right'
$form.Controls.Add($subtitle)

$inputLabel = New-Object System.Windows.Forms.Label
$inputLabel.Text = 'INPUT'
$inputLabel.Location = New-Object System.Drawing.Point(19, 80)
$inputLabel.Size = New-Object System.Drawing.Size(300, 23)
$form.Controls.Add($inputLabel)

$inputBox = New-Object System.Windows.Forms.TextBox
$inputBox.Multiline = $true
$inputBox.AcceptsReturn = $true
$inputBox.AcceptsTab = $true
$inputBox.ScrollBars = 'Vertical'
$inputBox.WordWrap = $true
$inputBox.Font = New-Object System.Drawing.Font('Segoe UI', 11)
$inputBox.Location = New-Object System.Drawing.Point(18, 104)
$inputBox.Size = New-Object System.Drawing.Size(814, 153)
$inputBox.Anchor = 'Top,Left,Right'
$form.Controls.Add($inputBox)

$encodingLabel = New-Object System.Windows.Forms.Label
$encodingLabel.Text = 'Encoding it was wrongly read as:'
$encodingLabel.Location = New-Object System.Drawing.Point(19, 274)
$encodingLabel.Size = New-Object System.Drawing.Size(300, 22)
$form.Controls.Add($encodingLabel)

$encodingBox = New-Object System.Windows.Forms.ComboBox
$encodingBox.DropDownStyle = 'DropDownList'
$encodingBox.Location = New-Object System.Drawing.Point(18, 298)
$encodingBox.Size = New-Object System.Drawing.Size(276, 29)
foreach ($entry in $script:encodings) { [void]$encodingBox.Items.Add($entry.Name) }
$encodingBox.SelectedIndex = 0
$form.Controls.Add($encodingBox)

$fixButton = New-Object System.Windows.Forms.Button
$fixButton.Text = 'Repair text'
$fixButton.Location = New-Object System.Drawing.Point(309, 297)
$fixButton.Size = New-Object System.Drawing.Size(114, 33)
$form.Controls.Add($fixButton)

$reverseButton = New-Object System.Windows.Forms.Button
$reverseButton.Text = 'Reverse'
$reverseButton.Location = New-Object System.Drawing.Point(434, 297)
$reverseButton.Size = New-Object System.Drawing.Size(100, 33)
$form.Controls.Add($reverseButton)

$tryButton = New-Object System.Windows.Forms.Button
$tryButton.Text = 'Try common fixes...'
$tryButton.Location = New-Object System.Drawing.Point(546, 297)
$tryButton.Size = New-Object System.Drawing.Size(180, 33)
$form.Controls.Add($tryButton)

$outputLabel = New-Object System.Windows.Forms.Label
$outputLabel.Text = 'RESULT (editable)'
$outputLabel.Location = New-Object System.Drawing.Point(19, 345)
$outputLabel.Size = New-Object System.Drawing.Size(300, 23)
$form.Controls.Add($outputLabel)

$outputBox = New-Object System.Windows.Forms.TextBox
$outputBox.Multiline = $true
$outputBox.AcceptsReturn = $true
$outputBox.AcceptsTab = $true
$outputBox.ScrollBars = 'Vertical'
$outputBox.WordWrap = $true
$outputBox.Font = New-Object System.Drawing.Font('Segoe UI', 11)
$outputBox.Location = New-Object System.Drawing.Point(18, 370)
$outputBox.Size = New-Object System.Drawing.Size(814, 178)
$outputBox.Anchor = 'Top,Bottom,Left,Right'
$form.Controls.Add($outputBox)

$useButton = New-Object System.Windows.Forms.Button
$useButton.Text = 'Use result as input'
$useButton.Location = New-Object System.Drawing.Point(18, 567)
$useButton.Size = New-Object System.Drawing.Size(165, 34)
$useButton.Anchor = 'Bottom,Left'
$form.Controls.Add($useButton)

$copyButton = New-Object System.Windows.Forms.Button
$copyButton.Text = 'Copy result'
$copyButton.Location = New-Object System.Drawing.Point(193, 567)
$copyButton.Size = New-Object System.Drawing.Size(132, 34)
$copyButton.Anchor = 'Bottom,Left'
$form.Controls.Add($copyButton)

$saveButton = New-Object System.Windows.Forms.Button
$saveButton.Text = 'Save result as .txt'
$saveButton.Location = New-Object System.Drawing.Point(335, 567)
$saveButton.Size = New-Object System.Drawing.Size(174, 34)
$saveButton.Anchor = 'Bottom,Left'
$form.Controls.Add($saveButton)

$clearButton = New-Object System.Windows.Forms.Button
$clearButton.Text = 'Clear both'
$clearButton.Location = New-Object System.Drawing.Point(520, 567)
$clearButton.Size = New-Object System.Drawing.Size(120, 34)
$clearButton.Anchor = 'Bottom,Left'
$form.Controls.Add($clearButton)

$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = 'Tip: For text like Ã¤Â½Â , click Repair more than once (use result as input).'
$statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(70, 78, 90)
$statusLabel.Location = New-Object System.Drawing.Point(18, 614)
$statusLabel.Size = New-Object System.Drawing.Size(814, 28)
$statusLabel.Anchor = 'Bottom,Left,Right'
$form.Controls.Add($statusLabel)

function Show-ConversionError($errorRecord) {
    $statusLabel.Text = 'Could not convert using that encoding. Try Latin-1 or Try common fixes.'
    [System.Windows.Forms.MessageBox]::Show(
        "That encoding cannot convert this text without losing information.`r`n`r`nTry another encoding or 'Try common fixes'.`r`n`r`nDetails: $($errorRecord.Exception.Message)",
        'Conversion not possible', 'OK', 'Information'
    ) | Out-Null
}

$fixButton.Add_Click({
    try {
        $entry = $script:encodings[$encodingBox.SelectedIndex]
        $outputBox.Text = Convert-Text $inputBox.Text $entry.Page $true
        $statusLabel.Text = 'Repaired with ' + $entry.Name + '. Check whether the result looks correct.'
    }
    catch { Show-ConversionError $_ }
})

$reverseButton.Add_Click({
    try {
        $entry = $script:encodings[$encodingBox.SelectedIndex]
        $outputBox.Text = Convert-Text $inputBox.Text $entry.Page $false
        $statusLabel.Text = 'Simulated UTF-8 being read as ' + $entry.Name + '.'
    }
    catch { Show-ConversionError $_ }
})

$useButton.Add_Click({
    $inputBox.Text = $outputBox.Text
    $statusLabel.Text = 'Result moved to input. You can apply another conversion.'
})

$copyButton.Add_Click({
    if ($outputBox.Text.Length -gt 0) {
        [System.Windows.Forms.Clipboard]::SetText($outputBox.Text)
        $statusLabel.Text = 'Result copied to clipboard.'
    }
})

$saveButton.Add_Click({
    if ($outputBox.Text.Length -eq 0) { return }
    $dialog = New-Object System.Windows.Forms.SaveFileDialog
    $dialog.Title = 'Save result as UTF-8 text'
    $dialog.Filter = 'Text files (*.txt)|*.txt|All files (*.*)|*.*'
    $dialog.FileName = 'recovered-text.txt'
    if ($dialog.ShowDialog($form) -eq [System.Windows.Forms.DialogResult]::OK) {
        try {
            [System.IO.File]::WriteAllText($dialog.FileName, $outputBox.Text, (New-Object System.Text.UTF8Encoding($false)))
            $statusLabel.Text = 'Saved UTF-8 text to ' + $dialog.FileName
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Save failed', 'OK', 'Error') | Out-Null
        }
    }
    $dialog.Dispose()
})

$clearButton.Add_Click({
    $inputBox.Clear()
    $outputBox.Clear()
    $statusLabel.Text = 'Cleared.'
})

$tryButton.Add_Click({
    if ($inputBox.Text.Length -eq 0) {
        $statusLabel.Text = 'Paste some garbled text into Input first.'
        return
    }

    $variants = New-Object 'System.Collections.Generic.List[object]'
    $seen = New-Object 'System.Collections.Generic.HashSet[string]'
    for ($i = 0; $i -lt $script:encodings.Count; $i++) {
        $entry = $script:encodings[$i]
        try {
            $candidate = Convert-Text $inputBox.Text $entry.Page $true
            if ($candidate -ne $inputBox.Text -and $seen.Add($candidate)) {
                [void]$variants.Add([pscustomobject]@{
                    Name = $entry.Name
                    Text = $candidate
                    Index = $i
                })
            }
        }
        catch { } # Skip conversions that cannot preserve all data.
    }

    if ($variants.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show(
            'No lossless UTF-8 recovery was found among the common encodings. The text may have lost bytes or may use a different encoding.',
            'No candidate found', 'OK', 'Information'
        ) | Out-Null
        return
    }

    $chooser = New-Object System.Windows.Forms.Form
    $chooser.Text = 'Possible repairs - choose the one that looks right'
    $chooser.StartPosition = 'CenterParent'
    $chooser.ClientSize = New-Object System.Drawing.Size(720, 470)
    $chooser.MinimumSize = New-Object System.Drawing.Size(600, 400)
    $chooser.Font = New-Object System.Drawing.Font('Segoe UI', 10)
    $chooser.Tag = $variants

    $chooseLabel = New-Object System.Windows.Forms.Label
    $chooseLabel.Text = 'Different encodings may produce different results. Select one to preview:'
    $chooseLabel.Location = New-Object System.Drawing.Point(15, 15)
    $chooseLabel.Size = New-Object System.Drawing.Size(670, 26)
    $chooseLabel.Anchor = 'Top,Left,Right'
    $chooser.Controls.Add($chooseLabel)

    $chooseList = New-Object System.Windows.Forms.ListBox
    $chooseList.Location = New-Object System.Drawing.Point(15, 48)
    $chooseList.Size = New-Object System.Drawing.Size(690, 120)
    $chooseList.Anchor = 'Top,Left,Right'
    foreach ($v in $variants) { [void]$chooseList.Items.Add($v.Name) }
    $chooser.Controls.Add($chooseList)

    $preview = New-Object System.Windows.Forms.TextBox
    $preview.Multiline = $true
    $preview.ScrollBars = 'Vertical'
    $preview.WordWrap = $true
    $preview.ReadOnly = $true
    $preview.Font = New-Object System.Drawing.Font('Segoe UI', 11)
    $preview.Location = New-Object System.Drawing.Point(15, 183)
    $preview.Size = New-Object System.Drawing.Size(690, 222)
    $preview.Anchor = 'Top,Bottom,Left,Right'
    $chooser.Controls.Add($preview)

    $selectButton = New-Object System.Windows.Forms.Button
    $selectButton.Text = 'Use selected repair'
    $selectButton.Location = New-Object System.Drawing.Point(525, 420)
    $selectButton.Size = New-Object System.Drawing.Size(180, 32)
    $selectButton.Anchor = 'Bottom,Right'
    $chooser.Controls.Add($selectButton)

    # Store related controls on the components so their event handlers
    # don't depend on nested PowerShell variable scopes.
    $chooseList.Tag = $preview
    $chooseList.Add_SelectedIndexChanged({
        $options = $this.FindForm().Tag
        if ($this.SelectedIndex -ge 0) {
            $this.Tag.Text = [string]$options[$this.SelectedIndex].Text
        }
    })

    $selectButton.Tag = @{
        List = $chooseList
        Dialog = $chooser
        Encoding = $encodingBox
        Output = $outputBox
        Status = $statusLabel
    }
    $selectButton.Add_Click({
        $c = $this.Tag
        if ($c.List.SelectedIndex -ge 0) {
            $choice = $c.Dialog.Tag[$c.List.SelectedIndex]
            $c.Encoding.SelectedIndex = [int]$choice.Index
            $c.Output.Text = [string]$choice.Text
            $c.Status.Text = 'Chosen repair: ' + $choice.Name
            $c.Dialog.Close()
        }
    })

    $chooseList.SelectedIndex = 0
    [void]$chooser.ShowDialog($form)
    $chooser.Dispose()
})

[void]$form.ShowDialog()
$form.Dispose()
