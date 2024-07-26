import QtQuick.Controls.Basic
import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: window
    width: 500
    height: 30
    visible: true
    title: promptTitle
    property string message: ""
    property string promptTitle: ""

    Component.onCompleted: {
        // Open the Popup when the window is loaded
        popup.open()
    }

    Popup {
        id: popup
        width: parent.width
        height: parent.height
        modal: true
        focus: true
        closePolicy: Popup.NoAutoClose //Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
        Text {
            text: message
            anchors.fill: parent
        }
    }
}





