### Intro

C2 Framework for administration of clients via [REST API](https://www.redhat.com/en/topics/api/what-is-a-rest-api). The objective of this project is to give user a guideline and a ready-to-use server component that can be integrated with various client app(s) or service(s).


![Alt text](/screenshots/2.JPG?raw=true "Optional Title")

### Features
**1: System Information:** Gain insights into the system by viewing details like operating system, hardware specifications, and software versions.

**2: Client Country Information:** Identify the client's country of origin (if applicable).

**3: File Management:** Effortlessly manage your files and directories. Upload, download, copy, paste, and delete with ease.

**4: Shell Handling:** Take control by executing commands directly on the client through a shell interface.

**5: Upload/Download File or Directory:** Seamlessly transfer files and directories between the client and server.

**6: Execute:** Run program or scripts on the client to automate tasks.

**7: Persist (Optional):** modify the OS configuration to automatically start the client on startup or specific time.

**8: Popups:** Stay informed with clear and concise messages or notifications from client about an operation or task.

**9: Logging:** Track client/server activity and events for troubleshooting.


### Usage
Download the [latest release](https://github.com/tajiknomi/Remote_Administrative_Console/releases) and run the application. This app acts like a webserver API, so you need client app/service to interact with it. You have three options available:-

1: You can use my client app/service like C++ based [windows client](https://github.com/tajiknomi/ClientHTTP_windows/releases) / [Linux client](https://github.com/tajiknomi/ClientHTTP_linux/releases).

2: For testing API, you can use any tool which can interact with web-api like [POSTMAN](https://www.postman.com/downloads/), [HTTPie](https://httpie.io/), [CURL](https://curl.se/).

3: Create your own app/service to interact with the servcer (by following the [protocol](https://github.com/tajiknomi/Remote_Administrative_Console/edit/main/README.md#rest-requests-for-advance-users) ) 


For simplicity i have created test-cases for [POSTMAN](https://www.postman.com/downloads/) i.e. "postman\TestCases.json". To use the compiled testcases, you can:-
1) Import the **postman\\TestCases.json** in your postman app or its web-interface.
2) edit --> Variables --> baseUrl. Set the value of baseUrl to your own ip address.
3) Open the server application and click on the "LISTEN" button.
4) Now you can send request(s) from postman to the server.

To receive files from clients, set up a web server using [XAMPP](https://www.apachefriends.org/), EasyPHP or WAMPP. Place the [php_script\index.php](https://github.com/tajiknomi/Remote_Administrative_Console/blob/main/php_script/index.php) script in the 'htdocs' folder of your XAMPP directory and run apache server. Set the data port in GUI to the port you choose for apacher server. Now the clients can send files to the server which will be available in "*path\to\XAMPP\htdocs\ClientData*" directory

### How to build
Its upto you to use cmake or qmake. I have provided both files (i.e CMakeLists.txt, server.qrc) which you can use in your Qt-Creator IDE or directly build the project using command line.
To use Qt Creator, you must open the project using either CMakeLists.txt or server.qrc.

command-line option is given below:-

#### 1) qmake
```
qmake -makeFile
make
```
#### 2) cmake
```
mkdir build && cd build;
cmake ../
cmake --build .
```

**Technology Stack:**
* Qt
* C++
* QML


#### REST requests (for advance users)
If you want to create a client application for this server you can use 
[REST/json](https://www.codecademy.com/article/what-is-rest) protocol to interact with the server.
[REST/json](https://www.codecademy.com/article/what-is-rest) is choose for its simplicity, scalability & statelessness.

 
#### Client --> Server

1: Alive signal (*signal serves as a heartbeat, indicating the client's active status*)
```
{
  "id": "{{id}}",
  "username": "Ghani",
  "computerName": "postman-1",
  "OSname": "windows"
}
```
2: GetResource (*for example, the client "Ghani" is requesting the server to give him a resource i.e. "test.txt"*)
```
{
  "id": "{{id_1}}",
  "username": "postman-1",
  "computerName": "Ghani",
  "OSname": "windows",
  "resourceRequired": "test.txt"
}
```
3: Shell (*display the message on the servers shell window e.g. "Hello Ghani!" message will be shown on the shell window opened for the user "Ghani"*)
```
{
  "id": "{{id_1}}",
  "username": "postman-1",
  "computerName": "Ghani",
  "OSname": "windows",
  "shellResponse": "[Hello Ghani!]"
}
```
4: Filemanager (*for example, here the client "Ghani" is sending the filesystem content of "C:/users/Ghani/Desktop/DllLoader/" which will be shown graphically on the opened filemanager for user "Ghani"*)
```
{
  "id": "{{id_1}}",
  "username": "Ghani",
  "computerName": "postman-1",
  "OSname": "windows",
  "dirList": {
    "files": [
      {
        "name": "libcurl.dll",
        "size": "2135728"
      },
      {
        "name": "UnknownFile.sln",
        "size": "1441"
      }
    ],
    "dirToList": [
      "C:/users/Ghani/Desktop/DllLoader/"
    ],
    "drive": [
      ""
    ]
  }
}
```

#### Server --> Client
1: Shell (*server is sending "whoami" command to the client*)
```
{
  "mode": "shell",
  "command": "whoami"
}
```
2: Filemanager (*show the filesystem content of "C:\users"*)
```
{
  "mode": "listDir",
  "dirToList": "C:\\users"
}
```
3: Download file (*ask client to upload a file to http server 192.168.0.50:8081. here the server can send its own ip:port or any other data server which can receive file using http service*) 
```
{
  "mode": "uploadFile",
  "filePath": "path/to/file",
  "port": "8081",
  "url": "192.168.0.50"
}
```
4: Download Directory (*request client to upload the content of a directory and filter the results based on file extensions. For example, the following request instructs the client to upload only .doc, .pdf, and .txt files to a specific directory. fileExtensions is optional, if not present, client should assume all files*)
```
{
  "mode": "UploadDir",
  "dirPath": "path/to/directory",
  "fileExtensions": ".doc,.pdf,.txt",
  "port": "8081",
  "url": "192.168.0.50"
}
```
5: Upload (*instruct the client to download a file from http://192.168.0.50:8081/path/to/file*)
```
{
  "mode": "downloadFile",
  "destPath": "path/to/destination",
  "filePath": "path/to/file",
  "port": "8081",
  "url": "192.168.0.50"
}
```
6: Execute (*instruct client to run executableFile.exe, arguments are optional*)
```
{
  "mode": "execute",
  "exePath": "path/to/executableFile.exe",
  "arguments": ""
}
```
7: Delete (*instruct client to delete a file*)
```
{
  "mode": "deleteFile",
  "filePath": "path/to/file"
}
```
8: compressAndDownload (*instruct client to compress the file/folder before uploading to server*)
```
{
  "mode": "compressAndDownload",
  "path": "path/to/file",
  "port": "8081",
  "url": "192.168.0.50"
}
```
9: Copy instruction doesn't send instruction to the client, its state is save on server side, it wait for the paste option

10: Paste
```
{
  "mode": "copy",
  "destPath": "path/to/destination/directory",
  "sourcePath": "path/to/source"
}
```

### Disclaimer
This application is designed for personal and administrative use. It is not intended for unauthorized access, data manipulation, or any other malicious activity. Any use of this software for illegal purposes is strictly prohibited. You can use this service in offensive security scenarios on you own machine/network ONLY.
The author disclaims all liability for any misuse or damage caused by the application. Users are solely responsible for their actions and the consequences thereof.


### Contributing

Pull requests are welcome. For major changes, please open an issue first
to discuss what you would like to change.
