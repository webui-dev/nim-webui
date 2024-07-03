import webui

# HTML
const html = """
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <script src="/webui.js"></script>
    <title>WebUI 2 - Nim Example</title>

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
    <h1>WebUI 2 - Nim Example</h1>
    
    <br>

    <input type="password" id="MyInput">

    <br>
    <br>

    <button id="MyButton1">Check Password</button> - <button id="MyButton2">Exit</button>
  </body>
</html>
"""

proc main =
  # Create a window
  let window = newWindow()
  
  window.bind("MyButton1") do (e: Event): # Check the password function

    # This function gets called every time the user clicks on "MyButton1"

    # Run the JavaScript on the UI (Web Browser)
    var js = e.window.script("return document.getElementById('MyInput').value;")

    # Check if there is any JavaScript error
    if js.error:
      echo "JavaScript Error: ", js.data
      return

    # Get the password
    let password = js.data
    echo "Password: ", password

    # Check the password
    if password == "123456":
      # Correct password

      discard e.window.script("alert('Good. Password is correct.')")
    else:
      # Wrong password

      discard e.window.script("alert('Sorry. Wrong password.')")

  window.bind("MyButton2") do (_: Event):
    # Close all opened windows
    
    webui.exit()

  # Show the window
  window.show(html)

  # Wait until all windows get closed
  wait()

main()
