import std/strutils
import std/os

import webui

const 
  html = """
<!DOCTYPE html>
<html>
    <head></head>
    <body>
        <script>
            function loadData() {
                fetch("index.html").then(response => response.text()).then(content => {
                    document.open("text/html");
                    document.write(content);
                    document.close();
                    console.log(content);
                }).catch(error => {
                    console.error(error);
                });
            }
            window.onload = loadData;
        </script>
    </body>
</html>
"""

var counter: int

proc main() =
  let window = newWindow()
  
  window.bind("Button1Click") do (e: Event) -> string:
    echo "Received callback: ", e.getString()
    inc counter

    return """{"label1": "Message from Nim", "label2": "$1"}""" % $counter

  window.rootFolder = currentSourcePath().parentDir()
  
  window.show(html)
  
  wait()

main()