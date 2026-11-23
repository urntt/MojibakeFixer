MOJIBAKE FIXER - Windows
=============================================

1. Extract this ZIP to a folder.
2. Double-click START_Mojibake_Fixer.bat.
3. Paste the garbled text into INPUT.
4. Click "Repair text". The default Western European (Windows-1252)
   encoding often works for strings like "ä½ å¥½".
5. If it doesn't look right, select another encoding, or click
   "Try common fixes..." to preview other lossless possibilities.
6. For the opposite direction, paste normal text and click "Reverse".
7. Click "Use result as input" to process text another time.
8. Copy or save the result as UTF-8 text.

How it works:
  Repair:  garbled text -> wrongly used encoding -> original UTF-8 bytes
           -> correct Unicode text.
  Reverse: normal text -> UTF-8 bytes -> wrongly decoded text.

The app does not call any online service and does not alter original files.
It only handles recoverable encoding mix-ups (mojibake). Missing characters,
replacement signs (�), or deleted data may make full recovery impossible.

This runs with the Windows PowerShell and Windows Forms included in Windows.
If your organization blocks PowerShell scripts, ask your administrator.
