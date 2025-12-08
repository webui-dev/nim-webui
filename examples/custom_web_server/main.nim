
import webui

proc main =
  # Create new windows
  let window = newWindow()

  # Bind all events
  window.bind("") do (e: Event):
    # This function gets called every time
    # there is an event

    case e.eventType
    of WebuiEvent.weConnected:
      echo "Connected"
    of WebuiEvent.weDisconnected:
      echo "Disconnected"
    of WebuiEvent.weMouseClick:
     echo "Click"
    of WebuiEvent.weNavigation:
      let url = e.getString()
      echo "Starting navigation to: ", url

      # Because we used `window.bind("")`
      # WebUI will block all `href` link clicks and sent here instead.
      # We can then control the behavior of links as needed.

      e.window.navigate(url)
    else: 
      discard

  # Bind HTML elements with Nim function
  window.bind("my_backend_func") do (e: Event):
    let
      number1 = e.getInt(0)
      number2 = e.getInt(1)
      number3 = e.getInt(2)

    echo "my_backend_func 1: ", number1 # 123
    echo "my_backend_func 2: ", number2 # 456
    echo "my_backend_func 3: ", number3 # 789

  # Set web server network port WebUI should use
  # this means `webui.js` will be available at:
  # http://localhost:8081/webui.js
  window.port = 8081

  # Show a new window and show our custom web server
  # Assuming the custom web server is running on port
  # 8080... 
  window.show("http://localhost:8080")

  # Wait until all windows get closed
  wait()

  # Free all memory resources (Optional)
  clean()

main()