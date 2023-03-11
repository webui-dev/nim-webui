import ../webui

const html = """
<!DOCTYPE html>
<html>
  <head>
    <title>WebUI 2 - Nim Example</title>
    <style>
      body {
        color: white; 
        background: #0F2027;
        background: -webkit-linear-gradient(to right, #2C5364, #203A43, #0F2027);
        background: linear-gradient(to right, #2C5364, #203A43, #0F2027);
        text-align: center; font-size: 18px; font-family: sans-serif;
      }
    </style>
  </head>

  <body>
    <h2>WebUI 2 - Nim Example</h2>

    <p>Call Nim function with arguments (See log in the Windows console)</p><br>
    <button OnClick="webui_fn('One', 'Hello');">Call Nim function one</button><br><br>
    <button OnClick="webui_fn('Two', 2022);">Call Nim function two</button><br><br>
    <button OnClick="webui_fn('Three', true);">Call Nim function three</button><br><br>
    <p>Call Nim function four, and wait for the result</p>
    <br>
    <button OnClick="MyJS();">Call Nim function four</button>
    <br>
    <br>
    <input type="text" id="MyInput" value="2">
    <script>
        function MyJS() {
            const number = document.getElementById('MyInput').value;
            var result = webui_fn('Four', number);
            document.getElementById('MyInput').value = result;
        }
    </script>
  </body>
</html>
"""

proc main =
  let window = newWindow()

  window.bind("One") do (e: Event):
    let str = e.getString()

    echo "function_one: ", str

  window.bind("Two") do (e: Event):
    let number = e.getInt()
    
    echo "function_two: ", number

  window.bind("Three") do (e: Event):
    let status = e.getBool()
    
    echo "function_three: ", status

  window.bind("Four") do (e: Event) -> int:
    var number = e.getInt()
    number *= 2
    
    echo "function_four: ", number

    return number

  if not window.show(html, BrowserChrome):  # Run the window on Chrome
    window.show(html, BrowserAny)           # If not, run on any other installed web browser

  wait()

main()