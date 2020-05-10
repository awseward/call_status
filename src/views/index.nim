#? stdtmpl(subsChar = '$', metaChar = '#')
#
#import assetsFile
#
#let css = assetsFile.getAsset("public/style.css")
#
#proc renderIndex*(left: string, right: string): string =
##  result = ""
<!DOCTYPE html>
<html>
  <head>
    <title>Call Status</title>
    <style type="text/css">${css}</style>
  </head>
  <body>
    <div class="main-wrapper">
      ${left}
      ${right}
    </div>
  </body
</html>
#end proc
