import QtQuick 2.15
//import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import Qt.labs.platform 1.1
import QtQuick.Dialogs 1.3
import QtQuick.Controls 2.15
//import QtQml.Models 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Controls.Universal 2.15
import MainWindow 1.0


Page {
    id: pageSettings
    title: qsTr("Settings")

    CMainWindow {
        id: mainWindowModel;
    }

    // Setting UI Control
    // Display vertical scroll bar to ListView
    ScrollView {
        id: sViewSettings
        width: parent.width
        height : parent.height
        contentWidth: settingsItem.width    // The important part
        contentHeight: settingsItem.height  // Same
        anchors.fill: parent
        clip : true                       // Prevent drawing column outside the scrollview borders

        ColumnLayout {
            id: settingsItem
            x: parent.x
            width: parent.width
            spacing: 0

            Label {
                id: labelEditor
                width: parent.width
                text: qsTr("Please Input Editor Path.") + qsTr("\n") + qsTr("(Ex. /usr/bin/kate)")

                Layout.topMargin: 20
                Layout.margins: 20

                wrapMode: Label.WordWrap
            }

            RowLayout {
                id: editEditorLayout
                width: parent.width
                spacing: 20

                Layout.topMargin: 5
                Layout.margins: 20

                TextField {
                    id: editEditor
                    text: mainWindowModel.getEditor()
                    width: pageSettings.width - btnEditorSelect.width - parent.spacing * 2 - Layout.margins * 2
                    implicitWidth: pageSettings.width - btnEditorSelect.width - parent.spacing * 2 - Layout.margins * 2

                    placeholderText: qsTr("/usr/bin/kate")
                    selectedTextColor: mainWindowModel.getColorMode() ? "white" : "black"

                    cursorVisible: true
                    horizontalAlignment: TextField.AlignLeft

                    onTextChanged: {
                        let iRet = mainWindowModel.saveEditor(editEditor.text);
                        if(iRet === -1)
                        {
                            errorDialog.messageTitle = qsTr("Error : Don't save editor path");
                            errorDialog.messageText  = qsTr("Error : The editor path you inputed could not be saved.") + qsTr("\n") + qsTr("For details, please contact the developer.");
                            errorDialog.open();
                            return;
                        }
                    }
                }

                RoundButton {
                    id: btnEditorSelect
                    text: "..."

                    Layout.rightMargin: 20

                    focus: true

                    onClicked: {
                        fileSelectDialog.title = qsTr("Please input a Editor.");
                        fileSelectDialog.strEditType = qsTr("editor");
                        fileSelectDialog.open();
                    }
                }
            }

            Label {
                id: labelEditorOption
                text: qsTr("Editor Option:")
                width: parent.width

                Layout.topMargin: 20
                Layout.margins: 20

                wrapMode: Label.WordWrap
            }

            TextField {
                id: editEditorOption
                text: mainWindowModel.getEditorOption()
                width: pageSettings.width - parent.spacing * 2 - Layout.margins * 2
                implicitWidth: pageSettings.width - parent.spacing * 2 - Layout.margins * 2

                Layout.topMargin: 5
                Layout.margins: 20

                placeholderText: qsTr("Ex. Kate : -b option ")
                selectedTextColor: mainWindowModel.getColorMode() ? "white" : "black"

                cursorVisible: true
                horizontalAlignment: TextField.AlignLeft
            }

            Label {
                id: labelDiff
                text: qsTr("Please Input Diff Tool Path.") + qsTr("\n") + qsTr("(Ex. /usr/bin/meld)")
                width: parent.width

                Layout.topMargin: 20
                Layout.margins: 20

                wrapMode: Label.WordWrap
            }

            RowLayout {
                id: editDiffLayout
                width: parent.width
                spacing: 20

                Layout.topMargin: 5
                Layout.margins: 20

                TextField {
                    id: editDiff
                    text: mainWindowModel.getDiffTool()
                    width: pageSettings.width - btnDiffSelect.width - parent.spacing * 2 - Layout.margins * 2
                    implicitWidth: pageSettings.width - btnDiffSelect.width - parent.spacing * 2 - Layout.margins * 2

                    placeholderText: qsTr("/usr/bin/meld")
                    selectedTextColor: mainWindowModel.getColorMode() ? "white" : "black"

                    cursorVisible: true
                    horizontalAlignment: TextField.AlignLeft
                }

                RoundButton {
                    id: btnDiffSelect
                    text: "..."

                    Layout.rightMargin: 20

                    onClicked: {
                        fileSelectDialog.title = qsTr("Please input a Diff Tool.");
                        fileSelectDialog.strEditType = qsTr("diff");
                        fileSelectDialog.open();
                    }
                }
            }

            Button {
                id: saveBtn
                text: qsTr("Save")

                Layout.topMargin: 50
                Layout.alignment: Qt.AlignHCenter

                onPressed: {
                    // Save editor path
                    var iRet = mainWindowModel.saveEditorOption(editEditorOption.text);
                    if(iRet === -1)
                    {
                        errorDialog.messageTitle = qsTr("Error : Don't save editor option");
                        errorDialog.messageText  = qsTr("Error : The editor option you inputed could not be saved.") + qsTr("\n") + qsTr("For details, please contact the developer.");
                        errorDialog.open();
                        return;
                    }

                    // Save diff tool path
                    iRet = mainWindowModel.saveDiffTool(editDiff.text);
                    if(iRet === -1)
                    {
                        errorDialog.messageTitle = qsTr("Error : Don't save diff tool path");
                        errorDialog.messageText  = qsTr("Error : The diff tool path you inputed could not be saved.") + qsTr("\n") + qsTr("For details, please contact the developer.");
                        errorDialog.open();
                        return;
                    }

                    // Display a popup when saving is complete
                    completePopup.messageText = qsTr("\n") + qsTr("The settings have been saved.") + qsTr("\n");
                    completePopup.open();
                }
            }
        }
    }


    FileDialog {
        id: fileSelectDialog
        title: "Please select a File"

        visible: false
        folder: StandardPaths.standardLocations(StandardPaths.HomeLocation)[0]
        modality: Qt.WindowModal

        property string strEditType: ""

        onAccepted: {
            var strDirPath = fileSelectDialog.fileUrl.toString().replace("file://", "");
            if (strEditType === qsTr("editor"))
            {
                editEditor.text = strDirPath;
            }
            else if (strEditType === qsTr("diff"))
            {
                editDiff.text = strDirPath;
            }

            fileSelectDialog.close();
        }
        onRejected: {
            fileSelectDialog.close();
        }
    }


    Popup {
        id: completePopup
        x: Math.round((pageSettings.width - width) / 2)
        y: Math.round(pageSettings.height / 6)
        width: Math.round(Math.min(pageSettings.width, pageSettings.height) / 10 * 9)

        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        property string messageText: ""

        ColumnLayout {
            id: completeColumn
            x: parent.x
            width: parent.width
            spacing: 20

            Layout.margins: 50

            Label {
                text: completePopup.messageText
                horizontalAlignment: Label.AlignHCenter
                verticalAlignment: Label.AlignVCenter
                Layout.fillWidth: true
                Layout.fillHeight: true

                wrapMode: Label.WordWrap
            }
        }

        onOpened: {
            completeTimer.start();
        }

        Timer {
            id: completeTimer

            interval: 2000
            repeat: false
            running: false

            onTriggered: {
                completeTimer.stop();
                completePopup.close();
            }
        }
    }


    Dialog {
        id: errorDialog
        title: errorDialog.messageTitle
        x: Math.round((mainWindow.width - width) / 2)
        y: Math.round(mainWindow.height / 6)
        width: Math.round(Math.min(mainWindow.width, mainWindow.height) / 10 * 9)

        modal: true
        focus: true
        closePolicy: Dialog.CloseOnEscape

        property string messageTitle: ""
        property string messageText: ""

        ColumnLayout {
            id: errorColumn
            x: parent.x
            width: parent.width
            spacing: 20

            RowLayout {
                id: errorRow
                x: errorDialog.x
                width: errorDialog.width
                spacing: 20

                Layout.alignment: Qt.AlignVCenter
                Layout.bottomMargin: 20

                Image {
                    id: errorIcon
                    source: "Image/Critical.png"
                    fillMode: Image.Stretch
                    Layout.alignment: Qt.AlignVCenter
                }

                Label {
                    text: errorDialog.messageText
                    verticalAlignment: Label.AlignVCenter
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    wrapMode: Label.WordWrap
                }
            }

            Button {
                id: errorBtnOK
                text: "OK"

                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: 20

                Connections {
                    target: errorBtnOK
                    function onClicked() {
                        errorDialog.close();
                    }
                }
            }
        }
    }
}
