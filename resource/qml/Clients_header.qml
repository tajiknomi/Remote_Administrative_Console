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


Rectangle {
    id: clients_rect
    height: 25
    width: parent.width-27
    color: "transparent"
    border.color: "black"
    property string elem_border_color: "black"
    property int elem_txt_size: 14
    property int elem_width: parent.width/5
    readonly property alias username_rect: username_rect
    readonly property alias sys_rect: sys_rect
    readonly property alias ip_rect: ip_rect
    readonly property alias location_rect:  location_rect
    readonly property alias os_rect: os_rect
//    readonly property alias status_rect: status_rect

    Rectangle {
        id: username_rect
        width: elem_width
        height: parent.height
        color: "transparent"
        border.color: elem_border_color
        clip: true
        Text {
            id: username_txt
            text: "USER"
            font.pixelSize: elem_txt_size
            anchors {
                centerIn: parent
            }
        }
    }

    Rectangle {
        id: sys_rect
        width: elem_width
        height: parent.height
        color: "transparent"
        border.color: elem_border_color
        clip: true
        Text {
            id: sys_txt
            text: "SYSTEM"
            font.pixelSize: elem_txt_size
            anchors.centerIn: parent
        }
        anchors.left: username_rect.right
    }

    Rectangle {
        id: ip_rect
        width: elem_width
        height: parent.height
        color: "transparent"
        border.color: elem_border_color
        clip: true
        Text {
            id: ip_txt
            text: "IP"
            font.pixelSize: elem_txt_size
            anchors.centerIn: parent
        }
        anchors.left: sys_rect.right
    }

    Rectangle {
        id: os_rect
        width: elem_width
        height: parent.height
        color: "transparent"
        border.color: elem_border_color
        clip: true
        Text {
            id: os_txt
            text: "OS"
            font.pixelSize: elem_txt_size
            anchors.centerIn: parent
        }
        anchors.left: ip_rect.right
    }

    Rectangle {
        id: location_rect
        width: elem_width
        height: parent.height
        color: "transparent"
        border.color: elem_border_color
        clip: true
        Text {
            id: location_txt
            text: "LOCATION"
            font.pixelSize: elem_txt_size
            anchors.centerIn: parent
        }
        anchors.left: os_rect.right
    }

//    Rectangle {
//        id: status_rect
//        width: elem_width
//        height: parent.height
//        color: "transparent"
//        border.color: elem_border_color
//        clip: true
//        Text {
//            id: status_txt
//            text: "STATUS"
//            font.pixelSize: elem_txt_size
//            anchors.centerIn: parent
//        }
//        anchors.left: os_rect.right
//    }

}
