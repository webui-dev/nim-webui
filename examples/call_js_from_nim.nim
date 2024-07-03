import std/strutils

import webui

const
  html = """
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <script src="/webui.js"></script>
    <title>Call JavaScript from C Example</title>
    <style>
       body {
            font-family: 'Arial', sans-serif;
            color: white;
            background: linear-gradient(to right, #507d91, #1c596f, #022737);
            text-align: center;
            font-size: 18px;
        }
        button, input {
            padding: 10px;
            margin: 10px;
            border-radius: 3px;
            border: 1px solid #ccc;
            box-shadow: 0 3px 5px rgba(0,0,0,0.1);
            transition: 0.2s;
        }
        button {
            background: #3498db;
            color: #fff; 
            cursor: pointer;
            font-size: 16px;
        }
        h1 { text-shadow: -7px 10px 7px rgb(67 57 57 / 76%); }
        button:hover { background: #c9913d; }
        input:focus { outline: none; border-color: #3498db; }
    </style>
  </head>

  <body>
    <h1>WebUI - Call JavaScript from C</h1>
    <br>
    <h1 id="count">0</h1>
    <br>
    <button id="MyButton1">Manual Count</button>
    <br>
    <button id="MyTest" OnClick="AutoTest();">Auto Count (Every 10ms)</button>
    <br>
    <button id="MyButton2">Exit</button>
    <script>
      let count = 0;
      function GetCount() {
        return count;
      }
      function SetCount(number) {
        document.getElementById('count').innerHTML = number;
        count = number;
      }
      function AutoTest(number) {
        setInterval(function(){ webui.call('MyButton1'); }, 10);
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
    else:
      echo "JavaScript Response: ", js.data

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

  # Free all memory resources (Optional)
  clean()

main()
