import webui

const
  privateHtml = """
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <script src="webui.js"></script>
    <title>Public Network Access Example</title>
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
    <h1>WebUI - Public Network Access Example</h1>
    <br>
    The second public window is configured to be accessible from <br>
    any device in the public network. <br>
    <br>
    Second public window link: <br>
    <h1 id="urlSpan" style="color:#c9913d">...</h1>
    Second public window events: <br>
    <textarea id="Logs" rows="4" cols="50" style="width:80%"></textarea>
    <br>
    <button id="Exit">Exit</button>
  </body>
</html>
"""

  publicHtml = """
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <script src="webui.js"></script>
    <title>Welcome to Public UI</title>
  </head>
  <body>
    <h1>Welcome to Public UI!</h1>
  </body>
</html>
"""

proc main =
  let # Create windows
    private_window = newWindow()
    public_window = newWindow()

  # App
  setTimeout(0) # Wait forever (never timeout)

  # Public Window
  public_window.public = true # Make URL accessible from public networks
  public_window.bind("") do (e: Event): # Bind all events
    if e.eventType == weConnected:
      private_window.run("document.getElementById('Logs').value += 'New connection.\\n';")
    elif e.eventType == weDisconnected:
      private_window.run("document.getElementById('Logs').value += 'Disconnected.\\n';")

  public_window.show(publicHtml, wbNoBrowser) # Set public window HTML
  let public_win_url = public_window.url # Get URL of public window

  # Main Private Window
  private_window.bind("Exit") do (_: Event): # Bind exit button
    exit()

  private_window.show(privateHtml) # Show the window

  # Set URL in the UI
  private_window.run("document.getElementById('urlSpan').innerHTML = '" & public_win_url & "';")

  # Wait until all windows get closed
  wait()

  # Free all memory resources (Optional)
  clean()

main()
