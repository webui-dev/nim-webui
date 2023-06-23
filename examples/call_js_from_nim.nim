import std/strutils

import webui

const
  html = """
<!DOCTYPE html>
<html>
<head>
  <title>Call JavaScript from Nim Example</title>

  <style>
    body {
      color: white;
      background: #0F2027;
      text-align: center;
      font-size: 16px;
      font-family: sans-serif;
    }
  </style>
</head>
<body>
  <h2>WebUI - Call JavaScript from Nim Example</h2>

  <br>

  <h1 id="MyElementID">Count is ?</h1>

  <br>
  <br>

  <button id="MyButton1">Count</button>

  <br>
  <br>

  <button id="MyButton2">Exit</button>

  <script>
    var count = 0;

    function GetCount() {
      return count;
    }

    function SetCount(number) {
      const MyElement = document.getElementById('MyElementID');
      MyElement.innerHTML = 'Count is ' + number;
      count = number;
    }
  </script>
</body>
</html>
"""

proc main = 
  # Create a window
  let window = newWindow()

  window.bind("MyButton1") do (e: Event):
    # This function gets called every time the user clicks on "MyButton1"

    # Run Javascript and hold the response in `js`
    let js = e.window.script("return GetCount();")

    if js.error:
      echo "JavaScript Error: ", js.data
      return

    # Get the count
    var count = parseInt(js.data)

    # Increment
    inc count

    # Run JavaScript (Quick Way)
    e.window.run("SetCount($1);" % $count)

  window.bind("MyButton2") do (_: Event):
    exit()

  # Show the window
  window.show(html) # webui_show_browser(my_window, my_html, Chrome);

  # Wait until all windows get closed
  wait()

main()
