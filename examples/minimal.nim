import webui

let window = newWindow() # Create a new Window
window.show("<html><head><script src='webui.js'></script></head> Hello World ! </html>") # Show the window with html content

wait() # Wait until the window gets closed