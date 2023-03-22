import webui

# HTML
const loginHtml = """
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

    <input type="password" id="MyInput" OnKeyUp="document.getElementById('err').innerHTML='&nbsp;';" autocomplete="off">

    <br>
    <h3 id="err" style="color: #dbdd52">&nbsp;</h3>
    <br>

    <button id="CheckPassword">Check Password</button> - <button id="Exit">Exit</button>
  </body>
</html>
"""

const dashboardHtml = """
<!DOCTYPE html>
<html>
  <head>
    <title>Dashboard</title>

    <style>
      body {
        color: white;
        background: #0F2027;
        background: -webkit-linear-gradient(to right, #4e99bb, #2c91b5, #07587a);
        background: linear-gradient(to right, #4e99bb, #2c91b5, #07587a);
        text-align: center;
        font-size: 18px;
        font-family: sans-serif;
      }
    </style>
  </head>

  <body>
    <h1>Welcome !</h1>

    <br>
    <br>

    <button id="Exit">Exit</button>
  </body>
</html>
"""

proc main =
  # Create a window
  let window = newWindow()
  
  window.bind("CheckPassword") do (e: Event): # Check the password function

    # This function gets called every time the user clicks on "MyButton1"

    var js = newScript(
      "return document.getElementById(\"MyInput\").value;",
      10
    )

    # Run the JavaScript on the UI (Web Browser)
    e.window.script(js)

    # Check if there is any JavaScript error
    if js.result.error:
      echo "JavaScript Error: ", js.result.data
      return

    # Get the password
    let password = js.result.data

    # Check the password
    if password == "123456":
      # Correct password

      echo "Password is correct."
      e.window.show(dashboardHtml)
    else:
      # Wrong password

      echo "Wrong password: ", password

      js.script = "document.getElementById('err').innerHTML = 'Sorry. Wrong password';"
      e.window.script(js)

  window.bind("Exit") do (_: Event):
    # Close all opened windows
    
    webui.exit()

  # Show the window
  if not window.show(loginHtml, BrowserChrome):  # Run the window on Chrome
    window.show(loginHtml, BrowserAny)           # If not, run on any other installed web browser

  # Wait until all windows get closed
  wait()

main()
