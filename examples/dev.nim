import ../webui

const html = """
<!DOCTYPE html>
<html>
	<head>
		<title>WebUI 2 - Nim Debug & Development</title>
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
		<h2>Python Debug & Development</h2>
		<br>
		<input type="text" id="MyInput" OnKeyUp="document.getElementById('err').innerHTML='&nbsp;';" autocomplete="off" value=\"2\">
		<br>
		<h3 id="err" style="color: #dbdd52">&nbsp;</h3>
		<br>
		<button id="TestID">Test Nim-To-JS</button>
		<button OnClick="MyJS();">Test JS-To-Nim</button>
		<button id="ExitID">Exit</button>
		<script>
			function MyJS() {
				const number = document.getElementById('MyInput').value;
				var result = webui_fn('Test2', number);
				document.getElementById('MyInput').value = result;
			}
		</script>
    </body></html>
"""