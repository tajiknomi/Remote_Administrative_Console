## Intro

C2 Framework for administration of clients via REST API. The basic set of functionality is given and user can add/remove/modify the feature(s) according to his/her need. The communication is purely HTTP base to avoid security end-points alarm(s) by masquerading the traffic to be legitimate web traffic.


## Features
**1: System Information:** Gain insights into the system by viewing details like operating system, hardware specifications, and software versions.

**2: Client Country Information:** Identify the client's country of origin (if applicable).

**3: File Management:** Effortlessly manage your files and directories. Upload, download, copy, paste, and delete with ease.

**4: Shell Handling:** Take control by executing commands directly on the client through a shell interface.

**5: Upload/Download File or Directory:** Seamlessly transfer files and directories between the client and server.

**6: Execute:** Run program or scripts on the client to automate tasks.

**7: Persist (Optional):** modify the OS configuration to automatically start the client on startup or specific time.

**8: Popups:** Stay informed with clear and concise messages or notifications from client about an operation or task.

**9: Logging:** Track client/server activity and events for troubleshooting.


## How to build
Its upto you to use cmake or qmake. I have provided both files (i.e CMakeLists.txt, server.qrc) which you can use in your Qt-Creator IDE or directly build the project using command line.

if you want to use Qt-Creator, you just have to either open the project using CMakeLists.txt or server.qrc.

command-line option is given below

### 1) qmake
```
qmake -makeFile
make
```
### 2) cmake
```
mkdir build && cd build;
cmake ../
cmake --build .
```
## Usage

This is a server application that requires a client to interact with it. To evaluate the server's behavior, I've used POSTMAN to send/recieve request/response. { Import the **postman\\TestCases.json** file in your postman application or web interface }

Detail usage will be shown via video [to be uploaded soon].

**Technology Stack:**
* Qt
* C++
* QML

## Contributing

Pull requests are welcome. For major changes, please open an issue first
to discuss what you would like to change.