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
