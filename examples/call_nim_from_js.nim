import webui

const html = """
<!DOCTYPE html>
<html>
  <head>
    <title>Call Nim from JavaScript Example</title>

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
    <h2>WebUI - Call Nim from JavaScript Example</h2>

    <p>Call Nim function with arguments (<em>See the logs in your terminal</em>)</p>
    
    <br>
    
    <button onclick="webui.call('One', 'Hello');">Call Nim function one</button>
    
    <br>
    <br>
    
    <button onclick="webui.call('Two', 2023);">Call Nim function two</button>
    
    <br>
    <br>
    
    <button onclick="webui.call('Three', true);">Call Nim function three</button>
    
    <br>
    <br>

    <button onclick="webui.call('RawBinary', new Uint8Array([0x41, 0x42, 0x43]));">Call Nim RawBinary function</button>
    
    <br>
    <br>

    <p>Call Nim function four and wait for the result</p>
    
    <br>

    <button onclick="MyJS();">Call Nim function four</button>

    <br>
    <br>

    <input type="text" id="MyInput" value="2">

    <script>
      function MyJS() {
        const MyInput = document.getElementById('MyInput');
        const number = MyInput.value;
        webui.call('Four', number).then((response) => {
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
    # JavaScript: webui.call('One', 'Hello');

    let str = e.getString()
    echo "function_one: ", str # Hello

  window.bind("Two") do (e: Event):
    # JavaScript: webui.call('Two', 2023);

    let number = e.getInt()
    echo "function_two: ", number # 2023

  window.bind("Three") do (e: Event):
    # JavaScript: webui.call('Three', true);

    let status = e.getBool()
    echo "function_three: ", status # true/false

  window.bind("Four") do (e: Event) -> int:
    # JavaScript: const result = webui.call('Four', 2);

    result = e.getInt() * 2
    echo "function_four: ", result # 4

    # result is sent back to Javascript for you

  window.bind("RawBinary") do (e: Event):
    # JavaScript:
    # webui.call('MyID_RawBinary', new Uint8Array([0x42, 0x43, 0x44]));

    let 
      raw = e.data
      len = e.size

    echo "function_raw_binary: ", len, " bytes"
    echo "function_raw_binary: ", raw

  # Show the window
  window.show(html)

  # Wait until all windows get closed
  wait()

main()
