import webui

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
        text-align: center; 
        font-size: 18px; 
        font-family: sans-serif;
      }
    </style>
  </head>

  <body>
    <h2>WebUI 2 - Nim Example</h2>

    <p>Call Nim function with arguments (See log in the console)</p><br>
    <button OnClick="webui_fn('One', 'Hello');">Call Nim function one</button><br><br>
    <button OnClick="webui_fn('Two', 2023);">Call Nim function two</button><br><br>
    <button OnClick="webui_fn('Three', true);">Call Nim function three</button><br><br>
    <p>Call Nim function four and wait for the result</p>
    
    <br>

    <button OnClick="MyJS();">Call Nim function four</button>

    <br>
    <br>

    <input type="text" id="MyInput" value="2">

    <script>
      function MyJS() {
        const MyInput = document.getElementById('MyInput');
        const number = MyInput.value;
        webui_fn('Four', number).then((response) => {
          MyInput.value = response;
        });
      }
    </script>
  </body>
</html>
"""

proc main =
  # Create a window
  let window = newWindow()

  window.bind("One") do (e: Event):
    # JavaScript: webui_fn('One', 'Hello');

    let str = e.getString()
    echo "function_one: ", str # Hello

  window.bind("Two") do (e: Event):
    # JavaScript: webui_fn('Two', 2023);

    let number = e.getInt()
    echo "function_two: ", number # 2023

  window.bind("Three") do (e: Event):
    # JavaScript: webui_fn('Three', true);

    let status = e.getBool()
    echo "function_three: ", status # true/false

  window.bind("Four") do (e: Event) -> int:
    # JavaScript: const result = webui_fn('Four', 2);

    result = e.getInt() * 2
    echo "function_four: ", result # 4

    # result is sent back to Javascript for you

  # Show the window
  window.show(html)

  # Wait until all windows get closed
  wait()

main()
