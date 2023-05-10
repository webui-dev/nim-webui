import webui

# HTML
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
    var js = e.window.script("return document.getElementById(\"MyInput\").value;")

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
