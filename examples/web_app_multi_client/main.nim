import std/strformat

import webui

# Arrays to hold permanent data
var
  privateInput: array[256, string] # One for each user
  publicInput: string # One for all users
  usersCount: int
  tabCount: int

proc save(e: Event) =
  # Get input value and save it in the array
  privateInput[e.clientId] = e.getString()

proc saveAll(e: Event) =
  # Get input value and save it in the array
  publicInput = e.getString()

  # Update all users
  e.window.run(fmt"document.getElementById('publicInput').value = '{publicInput}';")

proc events(e: Event) =
  # This function gets called every time there is an event

  # Get full web browser cookies
  # this is a port of the C example, which declares,
  # but doesnt use the `cookies` variable
  let cookies {.used.} = e.cookies

  # Static client (Based on web browser cookies)
  let clientId = e.clientId

  # Dynamic client connection ID (Changes on connect/disconnect events)
  let connectionId = e.connectionId

  case e.eventType
  of weConnected:  # New connection
    if users_count < (client_id + 1):  # +1 because it starts from 0
      users_count = client_id + 1

    inc tabCount
  of weDisconnected:  # Disconnection
    if tab_count > 0:
      dec tab_count
  else:
    discard

  # --- Update this current user only

  # status
  e.runClient("document.getElementById('status').innerText = 'Connected!';")

  # userNumber
  e.runClient(fmt"document.getElementById('userNumber').innerText = '{clientId}';")

  # connectionId
  e.runClient(fmt"document.getElementById('connectionNumber').innerText = '{connectionId}';")

  # privateInput
  e.runClient(fmt"document.getElementById('privateInput').value = '{privateInput[clientId]}';")

  # publicInput
  e.runClient(fmt"document.getElementById('publicInput').value = '{publicInput}';")

  # --- Update all connected users

  # userCount
  e.runClient(fmt"document.getElementById('userCount').innerText = '{usersCount}';")

  # tabCount
  e.runClient(fmt"document.getElementById('tabCount').innerText = '{tabCount}';")

proc main() =
  # Allow multi-user connection and cookies
  setConfig({wcMultiClient, wcUseCookies}, true)

  # Create new window
  let window = newWindow()

  # Bind HTML with Nim functions
  window.bind("save", save)
  window.bind("saveAll", saveAll)
  window.bind("exit_app", exit)
  
  # Bind all events
  window.bind("", events)

  # Start server only
  let url = window.startServer("index.html")

  # Open a new page in the default native web browser
  openUrl(url)

  # Wait until all windows get closed
  wait()

  # Free all memory resources (Optional)
  clean()
  
main()
