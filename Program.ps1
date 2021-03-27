$GeneralTestsInputs = Import-PowerShellDataFile -Path (Join-Path -Path (Get-Item $PSScriptRoot).FullName -ChildPath "Config.psd1")

#Path to your Ghostscript EXE
$tool = $GeneralTestsInputs.GhostScriptPath

#Directory containing the PDF files that will be converted
$inputDir = $GeneralTestsInputs.InputPDFsFolder

#Output path where converted PDF files will be stored
$outputDirPDF = $GeneralTestsInputs.OutputConvertedPDFsFolder

#Output path where the TIF files will be saved
$outputDir = $GeneralTestsInputs.OutputTIFFFolder

if (-Not(Test-Path $outputDirPDF)) {
    New-Item -ItemType Directory -Path $outputDirPDF | Out-Null
}

if (-Not(Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
}

$pdfs = Get-Childitem $inputDir | Where-Object {$_.Extension -match "pdf"}

$tiff = $outputDir + ('_{0:yyyyMMdd}_{0:HHmmss}' -f (Get-Date)) + ".tiff"

$param = "-sOutputFile=" + "'" + $tiff + "'"

$command = "& '$tool' -q -dNOPAUSE -dBATCH -sDEVICE=tiffg4 $param -r500"

foreach($pdf in $pdfs)
{ 
    'Processing ' + $pdf.Name + '...'

    $command = $command + " " + "'" + $pdf.FullName + "'"
    $command | Out-Default
}

Invoke-Expression $command

foreach($pdf in $pdfs)
{
    Move-Item $pdf.FullName $outputDirPDF
}