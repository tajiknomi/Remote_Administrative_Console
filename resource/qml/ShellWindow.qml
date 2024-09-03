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
    width: 800
    height: 450
    color: "white"
    title: username

    Connections {               // Signal handler to receive shell data from C++
        target: httpServer
        function onShellResponse(userID, response) {
            if(userID === id){
                const regex = /\| Child process exited with status:.*$/;
                response = response.replace(regex, '');
                responseData += "\n" + response;
            }
        }
    }
    property string id: ""
    property string username: ""
    property string responseData:""//"Output Window\n...\n...\n...\n...\n...\n...\n...\n...\n...\n...\n...\n...\n...\n...\n...\n...\n...\n...\n...\n...\n...\n...\n...\n...\n"

    function isChangeDir(input) {
      // Remove leading and trailing spaces from the input
      input = input.trim();

      // Modified regular expression to match various forms of "cd" commands
      if (/^cd\s+((?:"[^"]*"|'[^']*')|([A-Za-z]:?\\?.*|\.{2}[\/\\]+|[\/\\][^"'\s]+|~(?:[\/\\][^"'\s]+)*)+)$/.test(input)) {
        return true;
      }

      // If the input doesn't match the pattern, return false
      return false;
    }

    Rectangle {
        id: shell_rect
        width: parent.width * 0.8
        height: parent.height * 0.8
        color: "transparent"
      //  border.color: "black"
        clip: true
        anchors{
            top: parent.top
            left: parent.left
            topMargin: parent.height * 0.09//0.05
            leftMargin: parent.width * 0.09
        }
        Item {
            width: parent.width
            height: parent.height
            ScrollView {
                id: scrollView
                anchors.fill: parent
                Flickable {
                    id: flickableArea
                    anchors.fill: parent
                    contentWidth: outputTxt.width
                    contentHeight:outputTxt.height
                    TextArea {
                        id: outputTxt
                        color: "black"
                        readOnly: true
                        selectByMouse: true
                        text: responseData
                        background: Rectangle {
                            color: "transparent"
                        }
                        onTextChanged: {
                            flickableArea.contentY = outputTxt.height - flickableArea.height
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: command_input_rect
        width: shell_rect.width
        height: shell_rect.height/12
        color: "light grey"
        border.color: "transparent"
        clip: true
        anchors {
            top: shell_rect.bottom
            left: shell_rect.left
            leftMargin: 3
            topMargin: 3
        }

        TextInput {
            id: cmdInput
            text: "whoami"
            font.pixelSize: shell_rect.height/30
            selectByMouse: true
            anchors.fill: parent
            focus: true

            Keys.onReturnPressed: {
                let input = cmdInput.text;
                responseData += ">> " + input;
                let mode = "shell";
                let jsonObj;

                if(isChangeDir(input)){
                    input = input.replace(/^cd\s*/, '');
                    input = input.replace(/"/g, '');
                    jsonObj = {
                        id: id,
                        mode: mode,
                        cd: input
                    };
                }
                else {
                    jsonObj = {
                        id: id,
                        mode: mode,
                        command: input
                    };
                }
                let jsonString = JSON.stringify(jsonObj);
                httpServer.registerTaskForClient(jsonString);
                cmdInput.clear();
            }
        }
    }

    Rectangle {
        id: dollar_rect
        width: (parent.width - shell_rect.width)/8
        height: shell_rect.height/12
        color: "light grey"
        anchors {
            right: shell_rect.left
            top: shell_rect.bottom
            topMargin: 3
        }

        Text {
            id: dollar_txt
            text: "$"
            font.pixelSize: cmdInput.font.pixelSize
            anchors.right: parent.right
        }
    }
}
