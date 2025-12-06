include ./bindings_include.nim

const
  WEBUI_VERSION* = "2.5.0-beta.4" ##
                               ##   WebUI Library
                               ##   https://webui.me
                               ##   https://github.com/webui-dev/webui
                               ##   Copyright (c) 2020-2025 Hassan Draga.
                               ##   Licensed under MIT License.
                               ##   All rights reserved.
                               ##   Canada.
                               ##

const
  WEBUI_MAX_IDS* = (256)        ##  Max windows, servers and threads

const
  WEBUI_MAX_ARG* = (16)         ##  Max allowed argument's index

##  Dynamic Library Exports

# when defined(_WIN32) and (defined(_MSC_VER) or defined(__TINYC__)):
#   when not defined(WEBUI_EXPORT):
#     discard
# else:
#   discard
# # when defined(_MSC_VER):
#   const
#     strdup* = _strdup
# ##  -- C STD ---------------------------
# 
# ##  -- Windows -------------------------
# 
# # when defined(_WIN32):
#   when not defined(CGO):
#     when defined(__GNUC__) or defined(__TINYC__):
#       discard
#   const
#     WEBUI_GET_CURRENT_DIR* = _getcwd
#     WEBUI_FILE_EXIST* = _access
#     WEBUI_POPEN* = _popen
#     WEBUI_PCLOSE* = _pclose
#     WEBUI_MAX_PATH* = MAX_PATH
# ##  -- Linux ---------------------------
# 
# # when defined(__linux__):
#   const
#     WEBUI_GET_CURRENT_DIR* = getcwd
#     WEBUI_FILE_EXIST* = access
#     WEBUI_POPEN* = popen
#     WEBUI_PCLOSE* = pclose
#     WEBUI_MAX_PATH* = PATH_MAX
# ##  -- Apple ---------------------------
# 
# # when defined(__APPLE__):
#   const
#     WEBUI_GET_CURRENT_DIR* = getcwd
#     WEBUI_FILE_EXIST* = access
#     WEBUI_POPEN* = popen
#     WEBUI_PCLOSE* = pclose
#     WEBUI_MAX_PATH* = PATH_MAX
type
  webui_browser* = enum         ##  -- Enums ---------------------------
    NoBrowser = 0,              ##  0. No web browser
    AnyBrowser = 1,             ##  1. Default recommended web browser
    Chrome,                   ##  2. Google Chrome
    Firefox,                  ##  3. Mozilla Firefox
    Edge,                     ##  4. Microsoft Edge
    Safari,                   ##  5. Apple Safari
    Chromium,                 ##  6. The Chromium Project
    Opera,                    ##  7. Opera Browser
    Brave,                    ##  8. The Brave Browser
    Vivaldi,                  ##  9. The Vivaldi Browser
    Epic,                     ##  10. The Epic Browser
    Yandex,                   ##  11. The Yandex Browser
    ChromiumBased,            ##  12. Any Chromium based browser
    Webview                   ##  13. WebView (Non-web-browser)


type
  webui_runtime* = enum
    None = 0,                   ##  0. Prevent WebUI from using any runtime for .js and .ts files
    Deno,                     ##  1. Use Deno runtime for .js and .ts files
    NodeJS,                   ##  2. Use Nodejs runtime for .js files
    Bun                       ##  3. Use Bun runtime for .js and .ts files


type
  webui_event* = enum
    WEBUI_EVENT_DISCONNECTED = 0, ##  0. Window disconnection event
    WEBUI_EVENT_CONNECTED,    ##  1. Window connection event
    WEBUI_EVENT_MOUSE_CLICK,  ##  2. Mouse click event
    WEBUI_EVENT_NAVIGATION,   ##  3. Window navigation event
    WEBUI_EVENT_CALLBACK      ##  4. Function call event


type ##  Control if `webui_show()`, `webui_show_browser()` and
    ##  `webui_show_wv()` should wait for the window to connect
    ##  before returns or not.
    ##
    ##  Default: True
  webui_config* = enum
    show_wait_connection = 0, ##  Control if WebUI should block and process the UI events
                           ##  one a time in a single thread `True`, or process every
                           ##  event in a new non-blocking thread `False`. This updates
                           ##  all windows. You can use `webui_set_event_blocking()` for
                           ##  a specific single window update.
                           ##
                           ##  Default: False
    ui_event_blocking, ##  Automatically refresh the window UI when any file in the
                      ##  root folder gets changed.
                      ##
                      ##  Default: False
    folder_monitor, ##  Allow multiple clients to connect to the same window,
                   ##  This is helpful for web apps (non-desktop software),
                   ##  Please see the documentation for more details.
                   ##
                   ##  Default: False
    multi_client, ##  Allow or prevent WebUI from adding `webui_auth` cookies.
                 ##  WebUI uses these cookies to identify clients and block
                 ##  unauthorized access to the window content using a URL.
                 ##  Please keep this option to `True` if you want only a single
                 ##  client to access the window content.
                 ##
                 ##  Default: True
    use_cookies, ##  If the backend uses asynchronous operations, set this
                ##  option to `True`. This will make webui wait until the
                ##  backend sets a response using `webui_return_x()`.
    asynchronous_response


type
  webui_event_t* {.bycopy.} = object ##  -- Structs -------------------------
    window*: csize_t           ##  The window object number
    event_type*: csize_t       ##  Event type
    element*: cstring          ##  HTML element ID
    event_number*: csize_t     ##  Internal WebUI
    bind_id*: csize_t          ##  Bind ID
    client_id*: csize_t        ##  Client's unique ID
    connection_id*: csize_t    ##  Client's connection ID
    cookies*: cstring
    ##  Client's full cookies

  webui_logger_level* = enum
    WEBUI_LOGGER_LEVEL_DEBUG = 0, ##  0. All logs with all details
    WEBUI_LOGGER_LEVEL_INFO,  ##  1. Only general logs
    WEBUI_LOGGER_LEVEL_ERROR  ##  2. Only fatal error logs


proc webui_new_window*(): csize_t
  ##  -- Definitions ---------------------
  ##
  ##  @brief Create a new WebUI window object.
  ##
  ##  @return Returns the window number.
  ##
  ##  @example size_t myWindow = webui_new_window();
  ##
proc webui_new_window_id*(window_number: csize_t): csize_t
  ##
  ##  @brief Create a new webui window object using a specified window number.
  ##
  ##  @param window_number The window number (should be > 0, and < WEBUI_MAX_IDS)
  ##
  ##  @return Returns the same window number if success.
  ##
  ##  @example size_t myWindow = webui_new_window_id(123);
  ##
proc webui_get_new_window_id*(): csize_t
  ##
  ##  @brief Get a free window number that can be used with
  ##  `webui_new_window_id()`.
  ##
  ##  @return Returns the first available free window number. Starting from 1.
  ##
  ##  @example size_t myWindowNumber = webui_get_new_window_id();
  ##
proc webui_bind*(window: csize_t; element: cstring;
                `func`: proc (e: ptr webui_event_t)): csize_t
  ##
  ##  @brief Bind an HTML element and a JavaScript object with a backend function. Empty
  ##  element name means all events.
  ##
  ##  @param window The window number
  ##  @param element The HTML element / JavaScript object
  ##  @param func The callback function
  ##
  ##  @return Returns a unique bind ID.
  ##
  ##  @example webui_bind(myWindow, "myFunction", myFunction);
  ##
proc webui_set_context*(window: csize_t; element: cstring; context: pointer)
  ##
  ##  @brief Use this API after using `webui_bind()` to add any user data to it that can be
  ##  read later using `webui_get_context()`.
  ##
  ##  @param window The window number
  ##  @param element The HTML element / JavaScript object
  ##  @param context Any user data
  ##
  ##  @example
  ##  webui_bind(myWindow, "myFunction", myFunction);
  ##
  ##  webui_set_context(myWindow, "myFunction", myData);
  ##
  ##  void myFunction(webui_event_t* e) {
  ##    void* myData = webui_get_context(e);
  ##  }
  ##
proc webui_get_context*(e: ptr webui_event_t): pointer
  ##
  ##  @brief Get user data that is set using `webui_set_context()`.
  ##
  ##  @param e The event struct
  ##
  ##  @return Returns user data pointer.
  ##
  ##  @example
  ##  webui_bind(myWindow, "myFunction", myFunction);
  ##
  ##  webui_set_context(myWindow, "myFunction", myData);
  ##
  ##  void myFunction(webui_event_t* e) {
  ##    void* myData = webui_get_context(e);
  ##  }
  ##
proc webui_get_best_browser*(window: csize_t): csize_t
  ##
  ##  @brief Get the recommended web browser ID to use. If you
  ##  are already using one, this function will return the same ID.
  ##
  ##  @param window The window number
  ##
  ##  @return Returns a web browser ID.
  ##
  ##  @example size_t browserID = webui_get_best_browser(myWindow);
  ##
proc webui_show*(window: csize_t; content: cstring): bool
  ##
  ##  @brief Show a window using embedded HTML, or a file. If the window is already
  ##  open, it will be refreshed. This will refresh all windows in multi-client mode.
  ##
  ##  @param window The window number
  ##  @param content The HTML, URL, Or a local file
  ##
  ##  @return Returns True if showing the window is successed.
  ##
  ##  @example webui_show(myWindow, "<html>...</html>"); |
  ##  webui_show(myWindow, "index.html"); | webui_show(myWindow, "http://...");
  ##
proc webui_show_client*(e: ptr webui_event_t; content: cstring): bool
  ##
  ##  @brief Show a window using embedded HTML, or a file. If the window is already
  ##  open, it will be refreshed. Single client.
  ##
  ##  @param e The event struct
  ##  @param content The HTML, URL, Or a local file
  ##
  ##  @return Returns True if showing the window is successed.
  ##
  ##  @example webui_show_client(e, "<html>...</html>"); |
  ##  webui_show_client(e, "index.html"); | webui_show_client(e, "http://...");
  ##
proc webui_show_browser*(window: csize_t; content: cstring; browser: csize_t): bool
  ##
  ##  @brief Same as `webui_show()`. But using a specific web browser.
  ##
  ##  @param window The window number
  ##  @param content The HTML, Or a local file
  ##  @param browser The web browser to be used
  ##
  ##  @return Returns True if showing the window is successed.
  ##
  ##  @example webui_show_browser(myWindow, "<html>...</html>", Chrome); |
  ##  webui_show(myWindow, "index.html", Firefox);
  ##
proc webui_start_server*(window: csize_t; content: cstring): cstring
  ##
  ##  @brief Same as `webui_show()`. But start only the web server and return the URL.
  ##  No window will be shown.
  ##
  ##  @param window The window number
  ##  @param content The HTML, Or a local file
  ##
  ##  @return Returns the url of this window server.
  ##
  ##  @example const char* url = webui_start_server(myWindow, "/full/root/path");
  ##
proc webui_show_wv*(window: csize_t; content: cstring): bool
  ##
  ##  @brief Show a WebView window using embedded HTML, or a file. If the window is already
  ##  open, it will be refreshed. Note: Win32 need `WebView2Loader.dll`.
  ##
  ##  @param window The window number
  ##  @param content The HTML, URL, Or a local file
  ##
  ##  @return Returns True if showing the WebView window is successed.
  ##
  ##  @example webui_show_wv(myWindow, "<html>...</html>"); | webui_show_wv(myWindow,
  ##  "index.html"); | webui_show_wv(myWindow, "http://...");
  ##
proc webui_set_kiosk*(window: csize_t; status: bool)
  ##
  ##  @brief Set the window in Kiosk mode (Full screen).
  ##
  ##  @param window The window number
  ##  @param status True or False
  ##
  ##  @example webui_set_kiosk(myWindow, true);
  ##
proc webui_set_custom_parameters*(window: csize_t; params: cstring)
  ##
  ##  @brief Add a user-defined web browser's CLI parameters.
  ##
  ##  @param window The window number
  ##  @param params Command line parameters
  ##
  ##  @example webui_set_custom_parameters(myWindow, "--remote-debugging-port=9222");
  ##
proc webui_set_high_contrast*(window: csize_t; status: bool)
  ##
  ##  @brief Set the window with high-contrast support. Useful when you want to
  ##  build a better high-contrast theme with CSS.
  ##
  ##  @param window The window number
  ##  @param status True or False
  ##
  ##  @example webui_set_high_contrast(myWindow, true);
  ##
proc webui_set_resizable*(window: csize_t; status: bool)
  ##
  ##  @brief Sets whether the window frame is resizable or fixed.
  ##  Works only on WebView window.
  ##
  ##  @param window The window number
  ##  @param status True or False
  ##
  ##  @example webui_set_resizable(myWindow, true);
  ##
proc webui_is_high_contrast*(): bool
  ##
  ##  @brief Get OS high contrast preference.
  ##
  ##  @return Returns True if OS is using high contrast theme
  ##
  ##  @example bool hc = webui_is_high_contrast();
  ##
proc webui_browser_exist*(browser: csize_t): bool
  ##
  ##  @brief Check if a web browser is installed.
  ##
  ##  @return Returns True if the specified browser is available
  ##
  ##  @example bool status = webui_browser_exist(Chrome);
  ##
proc webui_wait*()
  ##
  ##  @brief Wait until all opened windows get closed.
  ##
  ##  @example webui_wait();
  ##
proc webui_close*(window: csize_t)
  ##
  ##  @brief Close a specific window only. The window object will still exist.
  ##  All clients.
  ##
  ##  @param window The window number
  ##
  ##  @example webui_close(myWindow);
  ##
proc webui_minimize*(window: csize_t)
  ##
  ##  @brief Minimize a WebView window.
  ##
  ##  @param window The window number
  ##
  ##  @example webui_minimize(myWindow);
  ##
proc webui_maximize*(window: csize_t)
  ##
  ##  @brief Maximize a WebView window.
  ##
  ##  @param window The window number
  ##
  ##  @example webui_maximize(myWindow);
  ##
proc webui_close_client*(e: ptr webui_event_t)
  ##
  ##  @brief Close a specific client.
  ##
  ##  @param e The event struct
  ##
  ##  @example webui_close_client(e);
  ##
proc webui_destroy*(window: csize_t)
  ##
  ##  @brief Close a specific window and free all memory resources.
  ##
  ##  @param window The window number
  ##
  ##  @example webui_destroy(myWindow);
  ##
proc webui_exit*()
  ##
  ##  @brief Close all open windows. `webui_wait()` will return (Break).
  ##
  ##  @example webui_exit();
  ##
proc webui_set_root_folder*(window: csize_t; path: cstring): bool
  ##
  ##  @brief Set the web-server root folder path for a specific window.
  ##
  ##  @param window The window number
  ##  @param path The local folder full path
  ##
  ##  @example webui_set_root_folder(myWindow, "/home/Foo/Bar/");
  ##
proc webui_set_browser_folder*(path: cstring)
  ##
  ##  @brief Set custom browser folder path.
  ##
  ##  @param path The browser folder path
  ##
  ##  @example webui_set_browser_folder("/home/Foo/Bar/");
  ##
proc webui_set_default_root_folder*(path: cstring): bool
  ##
  ##  @brief Set the web-server root folder path for all windows. Should be used
  ##  before `webui_show()`.
  ##
  ##  @param path The local folder full path
  ##
  ##  @example webui_set_default_root_folder("/home/Foo/Bar/");
  ##
proc webui_set_close_handler_wv*(window: csize_t;
                                close_handler: proc (window: csize_t): bool)
  ##
  ##  @brief Set a callback to catch the close event of the WebView window.
  ##  Must return `false` to prevent the close event, `true` otherwise.
  ##
  ##  @example
  ##  bool myCloseEvent(size_t window) {
  ##     // Prevent WebView window close event
  ##     return false;
  ##  }
  ##  webui_set_close_handler(myWindow, myCloseEvent);
  ##
proc webui_set_file_handler*(window: csize_t; handler: proc (filename: cstring;
    length: ptr cint): pointer)
  ##
  ##  @brief Set a custom handler to serve files. This custom handler should
  ##  return full HTTP header and body.
  ##  This deactivates any previous handler set with `webui_set_file_handler_window`
  ##
  ##  @param window The window number
  ##  @param handler The handler function: `void myHandler(const char* filename,
  ##  int* length)`
  ##
  ##  @example webui_set_file_handler(myWindow, myHandlerFunction);
  ##
proc webui_set_file_handler_window*(window: csize_t; handler: proc (window: csize_t;
    filename: cstring; length: ptr cint): pointer)
  ##
  ##  @brief Set a custom handler to serve files. This custom handler should
  ##  return full HTTP header and body.
  ##  This deactivates any previous handler set with `webui_set_file_handler`
  ##
  ##  @param window The window number
  ##  @param handler The handler function: `void myHandler(size_t window, const char* filename,
  ##  int* length)`
  ##
  ##  @example webui_set_file_handler_window(myWindow, myHandlerFunction);
  ##
proc webui_interface_set_response_file_handler*(window: csize_t; response: pointer;
    length: cint)
  ##
  ##  @brief Use this API to set a file handler response if your backend need async
  ##  response for `webui_set_file_handler()`.
  ##
  ##  @param window The window number
  ##  @param response The response buffer
  ##  @param length The response size
  ##
  ##  @example webui_interface_set_response_file_handler(myWindow, buffer, 1024);
  ##
proc webui_is_shown*(window: csize_t): bool
  ##
  ##  @brief Check if the specified window is still running.
  ##
  ##  @param window The window number
  ##
  ##  @example webui_is_shown(myWindow);
  ##
proc webui_set_timeout*(second: csize_t)
  ##
  ##  @brief Set the maximum time in seconds to wait for the window to connect.
  ##  This effect `show()` and `wait()`. Value of `0` means wait forever.
  ##
  ##  @param second The timeout in seconds
  ##
  ##  @example webui_set_timeout(30);
  ##
proc webui_set_icon*(window: csize_t; icon: cstring; icon_type: cstring)
  ##
  ##  @brief Set the default embedded HTML favicon.
  ##
  ##  @param window The window number
  ##  @param icon The icon as string: `<svg>...</svg>`
  ##  @param icon_type The icon type: `image/svg+xml`
  ##
  ##  @example webui_set_icon(myWindow, "<svg>...</svg>", "image/svg+xml");
  ##
proc webui_encode*(str: cstring): cstring
  ##
  ##  @brief Encode text to Base64. The returned buffer need to be freed.
  ##
  ##  @param str The string to encode (Should be null terminated)
  ##
  ##  @return Returns the base64 encoded string
  ##
  ##  @example char* base64 = webui_encode("Foo Bar");
  ##
proc webui_decode*(str: cstring): cstring
  ##
  ##  @brief Decode a Base64 encoded text. The returned buffer need to be freed.
  ##
  ##  @param str The string to decode (Should be null terminated)
  ##
  ##  @return Returns the base64 decoded string
  ##
  ##  @example char* str = webui_decode("SGVsbG8=");
  ##
proc webui_free*(`ptr`: pointer)
  ##
  ##  @brief Safely free a buffer allocated by WebUI using `webui_malloc()`.
  ##
  ##  @param ptr The buffer to be freed
  ##
  ##  @example webui_free(myBuffer);
  ##
proc webui_malloc*(size: csize_t): pointer
  ##
  ##  @brief Safely allocate memory using the WebUI memory management system. It
  ##  can be safely freed using `webui_free()` at any time.
  ##
  ##  @param size The size of memory in bytes
  ##
  ##  @example char* myBuffer = (char*)webui_malloc(1024);
  ##
proc webui_memcpy*(dest: pointer; src: pointer; count: csize_t)
  ##
  ##  @brief Copy raw data.
  ##
  ##  @param dest Destination memory pointer
  ##  @param src Source memory pointer
  ##  @param count Bytes to copy
  ##
  ##  @example webui_memcpy(myBuffer, myData, 64);
  ##
proc webui_send_raw*(window: csize_t; function: cstring; raw: pointer; size: csize_t)
  ##
  ##  @brief Safely send raw data to the UI. All clients.
  ##
  ##  @param window The window number
  ##  @param function The JavaScript function to receive raw data: `function
  ##  myFunc(myData){}`
  ##  @param raw The raw data buffer
  ##  @param size The raw data size in bytes
  ##
  ##  @example webui_send_raw(myWindow, "myJavaScriptFunc", myBuffer, 64);
  ##
proc webui_send_raw_client*(e: ptr webui_event_t; function: cstring; raw: pointer;
                           size: csize_t)
  ##
  ##  @brief Safely send raw data to the UI. Single client.
  ##
  ##  @param e The event struct
  ##  @param function The JavaScript function to receive raw data: `function
  ##  myFunc(myData){}`
  ##  @param raw The raw data buffer
  ##  @param size The raw data size in bytes
  ##
  ##  @example webui_send_raw_client(e, "myJavaScriptFunc", myBuffer, 64);
  ##
proc webui_set_hide*(window: csize_t; status: bool)
  ##
  ##  @brief Set a window in hidden mode. Should be called before `webui_show()`.
  ##
  ##  @param window The window number
  ##  @param status The status: True or False
  ##
  ##  @example webui_set_hide(myWindow, True);
  ##
proc webui_set_size*(window: csize_t; width: cuint; height: cuint)
  ##
  ##  @brief Set the window size.
  ##
  ##  @param window The window number
  ##  @param width The window width
  ##  @param height The window height
  ##
  ##  @example webui_set_size(myWindow, 800, 600);
  ##
proc webui_set_minimum_size*(window: csize_t; width: cuint; height: cuint)
  ##
  ##  @brief Set the window minimum size.
  ##
  ##  @param window The window number
  ##  @param width The window width
  ##  @param height The window height
  ##
  ##  @example webui_set_minimum_size(myWindow, 800, 600);
  ##
proc webui_set_position*(window: csize_t; x: cuint; y: cuint)
  ##
  ##  @brief Set the window position.
  ##
  ##  @param window The window number
  ##  @param x The window X
  ##  @param y The window Y
  ##
  ##  @example webui_set_position(myWindow, 100, 100);
  ##
proc webui_set_center*(window: csize_t)
  ##
  ##  @brief Centers the window on the screen. Works better with
  ##  WebView. Call this function before `webui_show()` for better results.
  ##
  ##  @param window The window number
  ##
  ##  @example webui_set_center(myWindow);
  ##
proc webui_set_profile*(window: csize_t; name: cstring; path: cstring)
  ##
  ##  @brief Set the web browser profile to use. An empty `name` and `path` means
  ##  the default user profile. Need to be called before `webui_show()`.
  ##
  ##  @param window The window number
  ##  @param name The web browser profile name
  ##  @param path The web browser profile full path
  ##
  ##  @example webui_set_profile(myWindow, "Bar", "/Home/Foo/Bar"); |
  ##  webui_set_profile(myWindow, "", "");
  ##
proc webui_set_proxy*(window: csize_t; proxy_server: cstring)
  ##
  ##  @brief Set the web browser proxy server to use. Need to be called before `webui_show()`.
  ##
  ##  @param window The window number
  ##  @param proxy_server The web browser proxy_server
  ##
  ##  @example webui_set_proxy(myWindow, "http://127.0.0.1:8888");
  ##
proc webui_get_url*(window: csize_t): cstring
  ##
  ##  @brief Get current URL of a running window.
  ##
  ##  @param window The window number
  ##
  ##  @return Returns the full URL string
  ##
  ##  @example const char* url = webui_get_url(myWindow);
  ##
proc webui_open_url*(url: cstring)
  ##
  ##  @brief Open an URL in the native default web browser.
  ##
  ##  @param url The URL to open
  ##
  ##  @example webui_open_url("https://webui.me");
  ##
proc webui_set_public*(window: csize_t; status: bool)
  ##
  ##  @brief Allow a specific window address to be accessible from a public network.
  ##
  ##  @param window The window number
  ##  @param status True or False
  ##
  ##  @example webui_set_public(myWindow, true);
  ##
proc webui_navigate*(window: csize_t; url: cstring)
  ##
  ##  @brief Navigate to a specific URL. All clients.
  ##
  ##  @param window The window number
  ##  @param url Full HTTP URL
  ##
  ##  @example webui_navigate(myWindow, "http://domain.com");
  ##
proc webui_navigate_client*(e: ptr webui_event_t; url: cstring)
  ##
  ##  @brief Navigate to a specific URL. Single client.
  ##
  ##  @param e The event struct
  ##  @param url Full HTTP URL
  ##
  ##  @example webui_navigate_client(e, "http://domain.com");
  ##
proc webui_clean*()
  ##
  ##  @brief Free all memory resources. Should be called only at the end.
  ##
  ##  @example
  ##  webui_wait();
  ##  webui_clean();
  ##
proc webui_delete_all_profiles*()
  ##
  ##  @brief Delete all local web-browser profiles folder. It should be called at the
  ##  end.
  ##
  ##  @example
  ##  webui_wait();
  ##  webui_delete_all_profiles();
  ##  webui_clean();
  ##
proc webui_delete_profile*(window: csize_t)
  ##
  ##  @brief Delete a specific window web-browser local folder profile.
  ##
  ##  @param window The window number
  ##
  ##  @example
  ##  webui_wait();
  ##  webui_delete_profile(myWindow);
  ##  webui_clean();
  ##
  ##  @note This can break functionality of other windows if using the same
  ##  web-browser.
  ##
proc webui_get_parent_process_id*(window: csize_t): csize_t
  ##
  ##  @brief Get the parent process ID, which refers to the current backend application process.
  ##
  ##  @param window The window number
  ##
  ##  @return Returns the the parent process id as integer
  ##
  ##  @example size_t id = webui_get_parent_process_id(myWindow);
  ##
proc webui_get_child_process_id*(window: csize_t): csize_t
  ##
  ##  @brief Get the child process ID created by the parent, which refers to the web browser window.
  ##
  ##  Note: In WebView mode, this will return the parent process ID because the backend and the
  ##  WebView window run in the same process.
  ##
  ##  @param window The window number
  ##
  ##  @return Returns the the child process id as integer
  ##
  ##  @example size_t id = webui_get_child_process_id(myWindow);
  ##
proc webui_win32_get_hwnd*(window: csize_t): pointer
  ##
  ##  @brief Gets Win32 window `HWND`. More reliable with WebView
  ##  than web browser window, as browser PIDs may change on launch.
  ##
  ##  @param window The window number
  ##
  ##  @return Returns the window `hwnd` as `void*`
  ##
  ##  @example HWND hwnd = webui_win32_get_hwnd(myWindow);
  ##
proc webui_get_hwnd*(window: csize_t): pointer
  ##
  ##  @brief Get window `HWND`. More reliable with WebView
  ##  than web browser window, as browser PIDs may change on launch.
  ##
  ##  @param window The window number
  ##
  ##  @return Returns the window `hwnd` in Win32, `GtkWindow` in Linux.
  ##
  ##  @example
  ##  HWND hwnd = webui_get_hwnd(myWindow); // Win32 (Work with WebView and web browser)
  ##  GtkWindow* window = webui_get_hwnd(myWindow); // Linux (Work with WebView only)
  ##
proc webui_get_port*(window: csize_t): csize_t
  ##
  ##  @brief Get the network port of a running window.
  ##  This can be useful to determine the HTTP link of `webui.js`
  ##
  ##  @param window The window number
  ##
  ##  @return Returns the network port of the window
  ##
  ##  @example size_t port = webui_get_port(myWindow);
  ##
proc webui_set_port*(window: csize_t; port: csize_t): bool
  ##
  ##  @brief Set a custom web-server/websocket network port to be used by WebUI.
  ##  This can be useful to determine the HTTP link of `webui.js` in case
  ##  you are trying to use WebUI with an external web-server like NGNIX.
  ##
  ##  @param window The window number
  ##  @param port The web-server network port WebUI should use
  ##
  ##  @return Returns True if the port is free and usable by WebUI
  ##
  ##  @example bool ret = webui_set_port(myWindow, 8080);
  ##
proc webui_get_free_port*(): csize_t
  ##
  ##  @brief Get an available usable free network port.
  ##
  ##  @return Returns a free port
  ##
  ##  @example size_t port = webui_get_free_port();
  ##
proc webui_set_logger*(`func`: proc (level: csize_t; log: cstring; user_data: pointer);
                      user_data: pointer)
  ##
  ##  @brief Set a custom logger function.
  ##
  ##  @example
  ##  void myLogger(size_t level, const char* log, void* user_data) {
  ##    printf("myLogger (%d): %s", level, log);
  ##  }
  ##  webui_set_logger(myLogger, NULL);
  ##
proc webui_set_config*(option: webui_config; status: bool)
  ##
  ##  @brief Control the WebUI behaviour. It's recommended to be called at the beginning.
  ##
  ##  @param option The desired option from `webui_config` enum
  ##  @param status The status of the option, `true` or `false`
  ##
  ##  @example webui_set_config(show_wait_connection, false);
  ##
proc webui_set_event_blocking*(window: csize_t; status: bool)
  ##
  ##  @brief Control if UI events comming from this window should be processed
  ##  one a time in a single blocking thread `True`, or process every event in
  ##  a new non-blocking thread `False`. This update single window. You can use
  ##  `webui_set_config(ui_event_blocking, ...)` to update all windows.
  ##
  ##  @param window The window number
  ##  @param status The blocking status `true` or `false`
  ##
  ##  @example webui_set_event_blocking(myWindow, true);
  ##
proc webui_set_frameless*(window: csize_t; status: bool)
  ##
  ##  @brief Make a WebView window frameless.
  ##
  ##  @param window The window number
  ##  @param status The frameless status `true` or `false`
  ##
  ##  @example webui_set_frameless(myWindow, true);
  ##
proc webui_set_transparent*(window: csize_t; status: bool)
  ##
  ##  @brief Make a WebView window transparent.
  ##
  ##  @param window The window number
  ##  @param status The transparency status `true` or `false`
  ##
  ##  @example webui_set_transparent(myWindow, true);
  ##
proc webui_get_mime_type*(file: cstring): cstring
  ##
  ##  @brief Get the HTTP mime type of a file.
  ##
  ##  @return Returns the HTTP mime string
  ##
  ##  @example const char* mime = webui_get_mime_type("foo.png");
  ##
proc webui_set_tls_certificate*(certificate_pem: cstring; private_key_pem: cstring): bool
  ##  -- SSL/TLS -------------------------
  ##
  ##  @brief Set the SSL/TLS certificate and the private key content, both in PEM
  ##  format. This works only with `webui-2-secure` library. If set empty WebUI
  ##  will generate a self-signed certificate.
  ##
  ##  @param certificate_pem The SSL/TLS certificate content in PEM format
  ##  @param private_key_pem The private key content in PEM format
  ##
  ##  @return Returns True if the certificate and the key are valid.
  ##
  ##  @example bool ret = webui_set_tls_certificate("-----BEGIN
  ##  CERTIFICATE-----\n...", "-----BEGIN PRIVATE KEY-----\n...");
  ##
proc webui_run*(window: csize_t; script: cstring)
  ##  -- JavaScript ----------------------
  ##
  ##  @brief Run JavaScript without waiting for the response. All clients.
  ##
  ##  @param window The window number
  ##  @param script The JavaScript to be run
  ##
  ##  @example webui_run(myWindow, "alert('Hello');");
  ##
proc webui_run_client*(e: ptr webui_event_t; script: cstring)
  ##
  ##  @brief Run JavaScript without waiting for the response. Single client.
  ##
  ##  @param e The event struct
  ##  @param script The JavaScript to be run
  ##
  ##  @example webui_run_client(e, "alert('Hello');");
  ##
proc webui_script*(window: csize_t; script: cstring; timeout: csize_t; buffer: cstring;
                  buffer_length: csize_t): bool
  ##
  ##  @brief Run JavaScript and get the response back. Work only in single client mode.
  ##  Make sure your local buffer can hold the response.
  ##
  ##  @param window The window number
  ##  @param script The JavaScript to be run
  ##  @param timeout The execution timeout in seconds
  ##  @param buffer The local buffer to hold the response
  ##  @param buffer_length The local buffer size
  ##
  ##  @return Returns True if there is no execution error
  ##
  ##  @example bool err = webui_script(myWindow, "return 4 + 6;", 0, myBuffer, myBufferSize);
  ##
proc webui_script_client*(e: ptr webui_event_t; script: cstring; timeout: csize_t;
                         buffer: cstring; buffer_length: csize_t): bool
  ##
  ##  @brief Run JavaScript and get the response back. Single client.
  ##  Make sure your local buffer can hold the response.
  ##
  ##  @param e The event struct
  ##  @param script The JavaScript to be run
  ##  @param timeout The execution timeout in seconds
  ##  @param buffer The local buffer to hold the response
  ##  @param buffer_length The local buffer size
  ##
  ##  @return Returns True if there is no execution error
  ##
  ##  @example bool err = webui_script_client(e, "return 4 + 6;", 0, myBuffer, myBufferSize);
  ##
proc webui_set_runtime*(window: csize_t; runtime: csize_t)
  ##
  ##  @brief Chose between Deno and Nodejs as runtime for .js and .ts files.
  ##
  ##  @param window The window number
  ##  @param runtime Deno | Bun | Nodejs | None
  ##
  ##  @example webui_set_runtime(myWindow, Deno);
  ##
proc webui_get_count*(e: ptr webui_event_t): csize_t
  ##
  ##  @brief Get how many arguments there are in an event.
  ##
  ##  @param e The event struct
  ##
  ##  @return Returns the arguments count.
  ##
  ##  @example size_t count = webui_get_count(e);
  ##
proc webui_get_int_at*(e: ptr webui_event_t; index: csize_t): clonglong
  ##
  ##  @brief Get an argument as integer at a specific index.
  ##
  ##  @param e The event struct
  ##  @param index The argument position starting from 0
  ##
  ##  @return Returns argument as integer
  ##
  ##  @example long long int myNum = webui_get_int_at(e, 0);
  ##
proc webui_get_int*(e: ptr webui_event_t): clonglong
  ##
  ##  @brief Get the first argument as integer.
  ##
  ##  @param e The event struct
  ##
  ##  @return Returns argument as integer
  ##
  ##  @example long long int myNum = webui_get_int(e);
  ##
proc webui_get_float_at*(e: ptr webui_event_t; index: csize_t): cdouble
  ##
  ##  @brief Get an argument as float at a specific index.
  ##
  ##  @param e The event struct
  ##  @param index The argument position starting from 0
  ##
  ##  @return Returns argument as float
  ##
  ##  @example double myNum = webui_get_float_at(e, 0);
  ##
proc webui_get_float*(e: ptr webui_event_t): cdouble
  ##
  ##  @brief Get the first argument as float.
  ##
  ##  @param e The event struct
  ##
  ##  @return Returns argument as float
  ##
  ##  @example double myNum = webui_get_float(e);
  ##
proc webui_get_string_at*(e: ptr webui_event_t; index: csize_t): cstring
  ##
  ##  @brief Get an argument as string at a specific index.
  ##
  ##  @param e The event struct
  ##  @param index The argument position starting from 0
  ##
  ##  @return Returns argument as string
  ##
  ##  @example const char* myStr = webui_get_string_at(e, 0);
  ##
proc webui_get_string*(e: ptr webui_event_t): cstring
  ##
  ##  @brief Get the first argument as string.
  ##
  ##  @param e The event struct
  ##
  ##  @return Returns argument as string
  ##
  ##  @example const char* myStr = webui_get_string(e);
  ##
proc webui_get_bool_at*(e: ptr webui_event_t; index: csize_t): bool
  ##
  ##  @brief Get an argument as boolean at a specific index.
  ##
  ##  @param e The event struct
  ##  @param index The argument position starting from 0
  ##
  ##  @return Returns argument as boolean
  ##
  ##  @example bool myBool = webui_get_bool_at(e, 0);
  ##
proc webui_get_bool*(e: ptr webui_event_t): bool
  ##
  ##  @brief Get the first argument as boolean.
  ##
  ##  @param e The event struct
  ##
  ##  @return Returns argument as boolean
  ##
  ##  @example bool myBool = webui_get_bool(e);
  ##
proc webui_get_size_at*(e: ptr webui_event_t; index: csize_t): csize_t
  ##
  ##  @brief Get the size in bytes of an argument at a specific index.
  ##
  ##  @param e The event struct
  ##  @param index The argument position starting from 0
  ##
  ##  @return Returns size in bytes
  ##
  ##  @example size_t argLen = webui_get_size_at(e, 0);
  ##
proc webui_get_size*(e: ptr webui_event_t): csize_t
  ##
  ##  @brief Get size in bytes of the first argument.
  ##
  ##  @param e The event struct
  ##
  ##  @return Returns size in bytes
  ##
  ##  @example size_t argLen = webui_get_size(e);
  ##
proc webui_return_int*(e: ptr webui_event_t; n: clonglong)
  ##
  ##  @brief Return the response to JavaScript as integer.
  ##
  ##  @param e The event struct
  ##  @param n The integer to be send to JavaScript
  ##
  ##  @example webui_return_int(e, 123);
  ##
proc webui_return_float*(e: ptr webui_event_t; f: cdouble)
  ##
  ##  @brief Return the response to JavaScript as float.
  ##
  ##  @param e The event struct
  ##  @param f The float number to be send to JavaScript
  ##
  ##  @example webui_return_float(e, 123.456);
  ##
proc webui_return_string*(e: ptr webui_event_t; s: cstring)
  ##
  ##  @brief Return the response to JavaScript as string.
  ##
  ##  @param e The event struct
  ##  @param n The string to be send to JavaScript
  ##
  ##  @example webui_return_string(e, "Response...");
  ##
proc webui_return_bool*(e: ptr webui_event_t; b: bool)
  ##
  ##  @brief Return the response to JavaScript as boolean.
  ##
  ##  @param e The event struct
  ##  @param n The boolean to be send to JavaScript
  ##
  ##  @example webui_return_bool(e, true);
  ##
proc webui_get_last_error_number*(): csize_t
  ##
  ##  @brief Get the last WebUI error code.
  ##
  ##  @example int error_num = webui_get_last_error_number();
  ##
proc webui_get_last_error_message*(): cstring
  ##
  ##  @brief Get the last WebUI error message.
  ##
  ##  @example const char* error_msg = webui_get_last_error_message();
  ##
proc webui_interface_bind*(window: csize_t; element: cstring; `func`: proc (
    a1: csize_t; a2: csize_t; a3: cstring; a4: csize_t; a5: csize_t)): csize_t
  ##  -- Wrapper's Interface -------------
  ##
  ##  @brief Bind a specific HTML element click event with a function. Empty element means all events.
  ##
  ##  @param window The window number
  ##  @param element The element ID
  ##  @param func The callback as myFunc(Window, EventType, Element, EventNumber, BindID)
  ##
  ##  @return Returns unique bind ID
  ##
  ##  @example size_t id = webui_interface_bind(myWindow, "myID", myCallback);
  ##
proc webui_interface_set_response*(window: csize_t; event_number: csize_t;
                                  response: cstring)
  ##
  ##  @brief When using `webui_interface_bind()`, you may need this function to easily set a response.
  ##
  ##  @param window The window number
  ##  @param event_number The event number
  ##  @param response The response as string to be send to JavaScript
  ##
  ##  @example webui_interface_set_response(myWindow, e->event_number, "Response...");
  ##
proc webui_interface_is_app_running*(): bool
  ##
  ##  @brief Check if the app still running.
  ##
  ##  @return Returns True if app is running
  ##
  ##  @example bool status = webui_interface_is_app_running();
  ##
proc webui_interface_get_window_id*(window: csize_t): csize_t
  ##
  ##  @brief Get a unique window ID.
  ##
  ##  @param window The window number
  ##
  ##  @return Returns the unique window ID as integer
  ##
  ##  @example size_t id = webui_interface_get_window_id(myWindow);
  ##
proc webui_interface_get_string_at*(window: csize_t; event_number: csize_t;
                                   index: csize_t): cstring
  ##
  ##  @brief Get an argument as string at a specific index.
  ##
  ##  @param window The window number
  ##  @param event_number The event number
  ##  @param index The argument position
  ##
  ##  @return Returns argument as string
  ##
  ##  @example const char* myStr = webui_interface_get_string_at(myWindow, e->event_number, 0);
  ##
proc webui_interface_get_int_at*(window: csize_t; event_number: csize_t;
                                index: csize_t): clonglong
  ##
  ##  @brief Get an argument as integer at a specific index.
  ##
  ##  @param window The window number
  ##  @param event_number The event number
  ##  @param index The argument position
  ##
  ##  @return Returns argument as integer
  ##
  ##  @example long long int myNum = webui_interface_get_int_at(myWindow, e->event_number, 0);
  ##
proc webui_interface_get_float_at*(window: csize_t; event_number: csize_t;
                                  index: csize_t): cdouble
  ##
  ##  @brief Get an argument as float at a specific index.
  ##
  ##  @param window The window number
  ##  @param event_number The event number
  ##  @param index The argument position
  ##
  ##  @return Returns argument as float
  ##
  ##  @example double myFloat = webui_interface_get_int_at(myWindow, e->event_number, 0);
  ##
proc webui_interface_get_bool_at*(window: csize_t; event_number: csize_t;
                                 index: csize_t): bool
  ##
  ##  @brief Get an argument as boolean at a specific index.
  ##
  ##  @param window The window number
  ##  @param event_number The event number
  ##  @param index The argument position
  ##
  ##  @return Returns argument as boolean
  ##
  ##  @example bool myBool = webui_interface_get_bool_at(myWindow, e->event_number, 0);
  ##
proc webui_interface_get_size_at*(window: csize_t; event_number: csize_t;
                                 index: csize_t): csize_t
  ##
  ##  @brief Get the size in bytes of an argument at a specific index.
  ##
  ##  @param window The window number
  ##  @param event_number The event number
  ##  @param index The argument position
  ##
  ##  @return Returns size in bytes
  ##
  ##  @example size_t argLen = webui_interface_get_size_at(myWindow, e->event_number, 0);
  ##
proc webui_interface_show_client*(window: csize_t; event_number: csize_t;
                                 content: cstring): bool
  ##
  ##  @brief Show a window using embedded HTML, or a file. If the window is already
  ##  open, it will be refreshed. Single client.
  ##
  ##  @param window The window number
  ##  @param event_number The event number
  ##  @param content The HTML, URL, Or a local file
  ##
  ##  @return Returns True if showing the window is successed.
  ##
  ##  @example webui_show_client(e, "<html>...</html>"); |
  ##  webui_show_client(e, "index.html"); | webui_show_client(e, "http://...");
  ##
proc webui_interface_close_client*(window: csize_t; event_number: csize_t)
  ##
  ##  @brief Close a specific client.
  ##
  ##  @param window The window number
  ##  @param event_number The event number
  ##
  ##  @example webui_close_client(e);
  ##
proc webui_interface_send_raw_client*(window: csize_t; event_number: csize_t;
                                     function: cstring; raw: pointer; size: csize_t)
  ##
  ##  @brief Safely send raw data to the UI. Single client.
  ##
  ##  @param window The window number
  ##  @param event_number The event number
  ##  @param function The JavaScript function to receive raw data: `function
  ##  myFunc(myData){}`
  ##  @param raw The raw data buffer
  ##  @param size The raw data size in bytes
  ##
  ##  @example webui_send_raw_client(e, "myJavaScriptFunc", myBuffer, 64);
  ##
proc webui_interface_navigate_client*(window: csize_t; event_number: csize_t;
                                     url: cstring)
  ##
  ##  @brief Navigate to a specific URL. Single client.
  ##
  ##  @param window The window number
  ##  @param event_number The event number
  ##  @param url Full HTTP URL
  ##
  ##  @example webui_navigate_client(e, "http://domain.com");
  ##
proc webui_interface_run_client*(window: csize_t; event_number: csize_t;
                                script: cstring)
  ##
  ##  @brief Run JavaScript without waiting for the response. Single client.
  ##
  ##  @param window The window number
  ##  @param event_number The event number
  ##  @param script The JavaScript to be run
  ##
  ##  @example webui_run_client(e, "alert('Hello');");
  ##
proc webui_interface_script_client*(window: csize_t; event_number: csize_t;
                                   script: cstring; timeout: csize_t;
                                   buffer: cstring; buffer_length: csize_t): bool
  ##
  ##  @brief Run JavaScript and get the response back. Single client.
  ##  Make sure your local buffer can hold the response.
  ##
  ##  @param window The window number
  ##  @param event_number The event number
  ##  @param script The JavaScript to be run
  ##  @param timeout The execution timeout in seconds
  ##  @param buffer The local buffer to hold the response
  ##  @param buffer_length The local buffer size
  ##
  ##  @return Returns True if there is no execution error
  ##
  ##  @example bool err = webui_script_client(e, "return 4 + 6;", 0, myBuffer, myBufferSize);
  ## 