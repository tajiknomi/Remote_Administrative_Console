import QtQuick.Controls.Basic
import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    property alias upload_dialog: upload_dialog
    property alias txtField: txtField
    property alias title: upload_dialog.title
    property alias txt: name_id.text

    Dialog {
        id: upload_dialog
        title: "Upload item"
        height: 180
        width: 315
//        standardButtons: Dialog.Ok | Dialog.Cancel
        focus: true    // Needed in 5.9+ or this code is NOT going to work!!

       Text {
            id: name_id
            text: ""            
        }
        TextField {
            id: txtField            
            width: parent.width * 0.85
            height: parent.height * 0.3
            focus: true
            anchors{
                top: name_id.bottom
                margins: 5
            }
            selectByMouse: true
        }

        Row {
            //anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10 // Adjust the spacing as needed
            anchors{
                top: txtField.bottom
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
        txtField.focus = true
    }
}
