import webui
import std/cpuinfo
import std/os
import std/json
import std/random
import std/math


type
  SystemInfo = object
    cpuPercent: float
    cpuCores: int
    ramPercent: float
    ramUsed: float  # in GB
    ramTotal: float # in GB
    diskPercent: float
    diskUsed: float # in GB
    diskTotal: float # in GB
    netDownloadSpeed: float # in bytes/sec
    netUploadSpeed: float   # in bytes/sec
    netBytesRecv: float     # total bytes received
    netBytesSent: float     # total bytes sent
    processes: seq[ProcessInfo]

  ProcessInfo = object
    name: string
    cpu: float
    memory: float

randomize()

## webuiCb is a proc pragma to automatically create a WebUI callback wrapper function : getSystemInfoWebuiCbWrapper
## 
## Supported argument types: primitives + Event:
## ```
##    int : int, int8, int16, int32, int64,
## 
##          uint, uint, uint8, uint16, uint32, uint64,
## 
##          cint8, cint16, cint32, cint64,
## 
##          cshort, cushort, cint, cuint, clong, culong
## 
##          csize_t, byte
## 
##    float : float, float32, float64, cfloat, cdouble
## 
##    string : string, cstring, JsonNode
## 
##    bool : bool
## 
##    Event
## ```
## Supported return types: primitives + void
## 
proc getSystemInfo(some_argument : JsonNode): string {.webuiCb.} =
  echo "Received argument: ", some_argument.pretty

  # This is a placeholder that generates random data for demonstration
  # A real implementation would use system APIs to get actual values
  var sys_info : SystemInfo

  sys_info.cpuCores = countProcessors()
  sys_info.cpuPercent = 25.0 + (rand(5000).float / 100.0)  # Random value between 25-75%
  
  sys_info.ramTotal = 16.0
  sys_info.ramUsed = 8.0 + (rand(800).float / 100.0)  # Random value between 8-16 GB
  sys_info.ramPercent = (sys_info.ramUsed / sys_info.ramTotal) * 100.0
  
  sys_info.diskTotal = 512.0
  sys_info.diskUsed = 200.0 + (rand(30000).float / 100.0)  # Random value between 200-500 GB
  sys_info.diskPercent = (sys_info.diskUsed / sys_info.diskTotal) * 100.0
  
  sys_info.netDownloadSpeed = rand(10000000).float  # Random download speed
  sys_info.netUploadSpeed = rand(5000000).float     # Random upload speed
  sys_info.netBytesRecv = 1000000000.0 + rand(10000000000).float  # Random total received
  sys_info.netBytesSent = 500000000.0 + rand(5000000000).float    # Random total sent
  
  # Generate some fake processes
  sys_info.processes = @[
    ProcessInfo(name: "system_monitor.exe", cpu: 5.2, memory: 2.1),
    ProcessInfo(name: "chrome.exe", cpu: 12.5, memory: 8.3),
    ProcessInfo(name: "vscode.exe", cpu: 8.1, memory: 5.7),
    ProcessInfo(name: "explorer.exe", cpu: 1.2, memory: 3.2),
    ProcessInfo(name: "spotify.exe", cpu: 3.7, memory: 1.8),
    ProcessInfo(name: "docker.exe", cpu: 6.4, memory: 4.2),
    ProcessInfo(name: "slack.exe", cpu: 4.3, memory: 2.9),
    ProcessInfo(name: "firefox.exe", cpu: 9.8, memory: 6.1),
    ProcessInfo(name: "steam.exe", cpu: 2.6, memory: 3.5),
    ProcessInfo(name: "discord.exe", cpu: 3.1, memory: 2.4)
  ]

  return (%*{
      "cpu": {
        "percent": sys_info.cpuPercent.round(2),
        "cores": sys_info.cpuCores
      },
      "ram": {
        "percent": sys_info.ramPercent.round(2),
        "used": sys_info.ramUsed,
        "total": sys_info.ramTotal
      },
      "disk": {
        "percent": sys_info.diskPercent.round(2),
        "used": sys_info.diskUsed,
        "total": sys_info.diskTotal
      },
      "network": {
        "downloadSpeed": sys_info.netDownloadSpeed,
        "uploadSpeed": sys_info.netUploadSpeed,
        "bytesRecv": sys_info.netBytesRecv,
        "bytesSent": sys_info.netBytesSent
      },
      "processes": %*sys_info.processes
    }).pretty

proc functionWithoutArgsOrOutput(e1 : Event, e2 : Event) {.webuiCb.} =
  echo "functionWithoutArgsOrOutput called"

proc main() =
  try:
    let window = newWindow()
    window.bindCb("GetSystemInfo", getSystemInfo)
    window.bindCb("FunctionWithoutArgsOrOutput", functionWithoutArgsOrOutput)
    window.show(readFile(currentSourcePath().parentDir() / "index.html"))
  finally:
    wait()
    clean()

main()