import webui

const html = """
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <script src="/webui.js"></script>
    <title>Call C from JavaScript Example</title>
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
    <h1>WebUI - Call C from JavaScript</h1>
    <p>Call C functions with arguments (<em>See the logs in your terminal</em>)</p>
    <button onclick="webui.call('One', 'Hello', 'World');">Call my_function_string()</button>
    <br>
    <button onclick="webui.call('Two', 123, 456, 789);">Call my_function_integer()</button>
    <br>
    <button onclick="webui.call('Three', true, false);">Call my_function_boolean()</button>
    <br>
    <button onclick="webui.call('RawBinary', new Uint8Array([0x41,0x42,0x43]), big_arr);"> 
     Call my_function_raw_binary()</button>
    <br>
    <p>Call a C function that returns a response</p>
    <button onclick="MyJS();">Call my_function_with_response()</button>
    <div>Double: <input type="text" id="MyInputID" value="2"></div>
    <script>
      const arr_size = 512 * 1000;
      const big_arr = new Uint8Array(arr_size);
      big_arr[0] = 0xA1;
      big_arr[arr_size - 1] = 0xA2;
      function MyJS() {
        const MyInput = document.getElementById('MyInputID');
        const number = MyInput.value;
        webui.call('Four', number, 2).then((response) => {
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
    # JavaScript:
    # webui.call('One', 'Hello', 'World`);

    let 
      str1 = e.getString()
      str2 = e.getString(1)
    
    echo "function_one: ", str1 # Hello
    echo "function_one: ", str2 # World

  window.bind("Two") do (e: Event):
    # JavaScript: 
    # webui.call('Two', 123, 456, 789);

    let 
      number1 = e.getInt()
      number2 = e.getInt(1)
      number3 = e.getInt(2)

    echo "function_two: ", number1 # 123
    echo "function_two: ", number2 # 456
    echo "function_two: ", number3 # 789

  window.bind("Three") do (e: Event):
    # JavaScript:
    # webui.call('MyID_Three', true, false);

    let 
      status1 = e.getBool()
      status2 = e.getBool(1)

    echo "function_three: ", status1 # true
    echo "function_three: ", status2 # false

  window.bind("Four") do (e: Event) -> int:
    # JavaScript: 
    # webui.call('Four', number, 2).then(...)

    let
      number = e.getInt()
      times = e.getInt(1)

    result = number * times

    echo "function_four: ", number, " * ", times, " = ", result

    # result is sent back to Javascript for you

  window.bind("RawBinary") do (e: Event):
    # JavaScript:
    # webui.call('RawBinary', new Uint8Array([0x41]), new Uint8Array([0x42, 0x43]));

    let 
      raw1 = e.getString()
      raw2 = e.getString(1)

      len1 = e.getSize()
      len2 = e.getSize(1)

    # print raw1
    echo "function_raw_binary 1 (", len1, " bytes): ", raw1

    # check raw2 (Big)
    if raw2[0] == chr(0xa1) and raw2[^1] == chr(0xa2):
      echo "function_raw_binary 2 (", len2, " bytes): valid data? ", "Yes"
    else:
      echo "function_raw_binary 2 (", len2, " bytes): valid data? ", "No"

  # Show the window
  window.show(html)

  # Wait until all windows get closed
  wait()

  # Free all memory resources (Optional)
  clean()

main()
