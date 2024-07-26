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
