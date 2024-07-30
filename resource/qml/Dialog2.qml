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

Item {
    id: root
    property alias upload_dialog: upload_dialog
    property alias txtField1: txtField1
    property alias txtField2: txtField2
    property alias title: upload_dialog.title
    property alias txt1: txt1_id.text
    property alias txt2: txt2_id.text

    Dialog {
        id: upload_dialog
        title: "Upload item"
        height: 200
        width: 300
//        standardButtons: Dialog.Ok | Dialog.Cancel
        focus: true    // Needed in 5.9+ or this code is NOT going to work!!

        Text {
            id: txt1_id
            text: ""
        }
        TextField {
            id: txtField1
            width: parent.width * 0.85
            height: parent.height * 0.2
            focus: true
            selectByMouse: true
            anchors{
                top: txt1_id.bottom
                margins: 5
            }
        }
        Text {
            id: txt2_id
            text: ""
            anchors{
                top: txtField1.bottom
            }
        }
        TextField {
            id: txtField2
            width: parent.width * 0.85
            height: parent.height * 0.2
            focus: true
            selectByMouse: true
            anchors{
                top: txt2_id.bottom
                margins: 5
            }
        }

        Row {
            //anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10 // Adjust the spacing as needed
            anchors{
                top: txtField2.bottom
                margins: 8
            }

            Button {
                text: "Ok"
                onClicked: {
                    upload_dialog.accept();
                }
            }
            Button {
                text: "Cancel"
                onClicked: {
                    upload_dialog.reject();
                }
            }
        }
    }

    function openUploadDialog() {
        upload_dialog.open()
        txtField1.focus = true
        txtField2.focus = true
    }
}
