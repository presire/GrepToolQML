import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.15
import Qt.labs.settings 1.1
import QtQuick.Controls.Material 2.15
import QtQuick.Controls.Universal 2.15
import MainWindow 1.0


ApplicationWindow {
    id: mainWindow
    x: mainWindowModel.getMainWindowX()
    y: mainWindowModel.getMainWindowY()
    width: mainWindowModel.getMainWindowWidth()
    height: mainWindowModel.getMainWindowHeight()
    visible: true
    visibility: mainWindowModel.getMainWindowMaximized() ?  Window.Maximized : Window.Windowed
    title: qsTr("GrepToolQML for PinePhone")

    CMainWindow {
        id: mainWindowModel;
    }

    // Color Mode
    Settings {
        id: settings
        property string style: mainWindowModel.getColorMode() ? "Material" : "Universal"
    }

    function saveApplicationState() {
        // Save window state
        let bMaximized = false
        if(mainWindow.visibility === Window.Maximized)
        {
            bMaximized = true;
        }

        mainWindowModel.setMainWindowState(x, y, width, height, bMaximized)

        // Save color mode
        if (settings.style == "Material")
        {
            mainWindowModel.setColorMode(true);
        }
        else
        {
            mainWindowModel.setColorMode(false);
        }
    }

    // Show Grep form
    Shortcut {
        sequence: "Esc"
        onActivated: {
            if(stackView.depth > 1)
            {
                for(let i = stackView.depth; i > 1; i--)
                {
                    stackView.pop()
                }

                actionGrep.enabled = false
                actionSettings.enabled = true
                actionAboutGrepToolQML.enabled = true
                actionAboutQt.enabled = true
            }
        }
    }

    Shortcut {
        sequence: "Ctrl+Q"
        onActivated: {
            quitDialog.open()
        }
    }

    onClosing: {
        //quitDialog.open()
        //close.accepted = false

        saveApplicationState();
    }

    onOpenglContextCreated: {
        actionGrep.enabled = false
    }

    property int currentMainWindowWidth:  0
    property int currentMainWindowHeight: 0

    header: MenuBar {
        id: mainMenu
        x: 0
        y: 0
        width: mainWindow.width

        // [File] Menu
        Menu {
            title: qsTr("&File(&F)")

            // [Save Password] SubMenu
//            Action {
//                text: "Save Password(&P)"
//                onTriggered: {
//                    passwordDialog.open();
//                }
//            }

            // [Quit] SubMenu
            Action {
                text: "Quit(&O)"
                onTriggered: {
                    quitDialog.open();
                }
            }
        }

        // [Feature] Menu
        Menu {
            title: qsTr("&Feature(&C)")

            // [Grep] SubMenu
            Action {
                id: actionGrep
                text: "Grep(&G)"
                onTriggered: {
                    stackView.pop()
                    stackView.push("GrepPinePhone.qml")

                    actionGrep.enabled = false
                    actionSettings.enabled = true
                    actionAboutGrepToolQML.enabled = true
                    actionAboutQt.enabled = true
                }
            }

            //
            Action {
                id: actionSettings
                text: "Settings(&A)"
                onTriggered: {
                    stackView.pop()
                    stackView.push("SettingsPinePhone.qml")

                    actionGrep.enabled = true
                    actionSettings.enabled = false
                    actionAboutGrepToolQML.enabled = true
                    actionAboutQt.enabled = true
                }
            }
        }

        // [Mode] Menu
        Menu {
            title: qsTr("&Mode(&M)")

            // [Save Password] SubMenu
            Action {
                id: darkMode
                text: "Dark Mode(&D)"

                onTriggered: {
                    darkModeDialog.open();
                }
            }
        }

        // [Help] Menu
        Menu {
            title: qsTr("&Help(&H)")

            // [about GrepToolQML] SubMenu
            Action {
                id: actionAboutGrepToolQML
                text: "about GrepToolQML(&A)"
                onTriggered: {
                    stackView.pop()
                    stackView.push("aboutGrepToolQML.qml")

                    actionGrep.enabled = true
                    actionSettings.enabled = true
                    actionAboutGrepToolQML.enabled = false
                    actionAboutQt.enabled = true
                }
            }

            // [about Qt] SubMenu
            Action {
                id: actionAboutQt
                text: "about Qt(&t)"
                onTriggered: {
                    stackView.pop()
                    stackView.push("aboutQt.qml")

                    actionGrep.enabled = true
                    actionSettings.enabled = true
                    actionAboutGrepToolQML.enabled = true
                    actionAboutQt.enabled = false
                }
            }
        }
    }

    StackView {
        id: stackView
        x: 0
        y: mainMenu.height
        width: mainWindow.width
        height: mainWindow.height - mainMenu.height
        initialItem: "GrepPinePhone.qml"
        anchors.fill: parent
    }

    Dialog {
        id: passwordDialog
        title: "Save Linux System Password"
        x: Math.round((mainWindow.width - width) / 2)
        y: Math.round(mainWindow.height / 6)
        width: Math.round(Math.min(mainWindow.width, mainWindow.height) / 10 * 9)
        contentHeight: passwordColumn.height

        modal: true
        focus: true
        closePolicy: Dialog.CloseOnEscape

        ColumnLayout {
            id: passwordColumn
            width: parent.width
            spacing: 20

            TextField {
                id: passwordInput
                text: mainWindowModel.getPassword()
                width: parent.width
                implicitWidth: parent.width
                Layout.alignment: Qt.AlignHCenter

                font.bold: true
                focus: true
                cursorVisible: true
                selectedTextColor: "#393939"
                horizontalAlignment: TextField.AlignRight
                placeholderText: qsTr("Please Input PinePhone PIN.")

                echoMode: TextField.Password
                passwordMaskDelay: 2000
            }

            RowLayout {
                x: 0
                width: passwordColumn.width
                Layout.alignment: Qt.AlignHCenter
                spacing: 20

                Button {
                    id: savePasswordBtn
                    text: "Save"

                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 10

                    Connections {
                        target: savePasswordBtn
                        function onClicked() {
                            let iError = mainWindowModel.savePassword(passwordInput.text);
                            if(iError === -1)
                            {
                                errorDialog.title = qsTr("File Error");
                                errorDialogMessage.text = qsTr("error occurred while saving the PIN.\n");
                                errorDialog.open();
                            }

                            passwordDialog.close();
                        }
                    }
                }

                Button {
                    id: closePasswordDialogBtn
                    text: "Cancel"

                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 10

                    Connections {
                        target: closePasswordDialogBtn
                        function onClicked() {
                            passwordDialog.close();
                        }
                    }
                }
            }
        }
    }


    Dialog {
        id: darkModeDialog
        title: "Dark Mode"
        x: Math.round((mainWindow.width - width) / 2)
        y: Math.round(mainWindow.height / 6)
        width: Math.round(Math.min(mainWindow.width, mainWindow.height) / 10 * 9)
        contentHeight: darkModeColumn.height

        modal: true
        focus: true
        closePolicy: Dialog.CloseOnEscape

        property bool bRestart: false

        onClosed: {
            if (!darkModeDialog.bRestart)
            {
                themeSwitch.checked = mainWindowModel.getColorMode();
            }
        }

        ColumnLayout {
            id: darkModeColumn
            width: parent.width
            spacing: 20

            Label {
                text: "When you restart this software, the color will change."
                wrapMode: Label.WordWrap
                horizontalAlignment: Label.AlignHCenter
                verticalAlignment: Label.AlignVCenter
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.bottomMargin: 20
            }

            Switch {
                id: themeSwitch
                text: "Dark"
                checked: mainWindowModel.getColorMode() ? true : false
                Layout.alignment: Qt.AlignHCenter

                onCheckedChanged: {
                    let bDarkMode = mainWindowModel.getColorMode();
                    if (bDarkMode !== themeSwitch.checked)
                    {
                        darkModeRestartBtn.enabled = true;
                    }
                    else
                    {
                        darkModeRestartBtn.enabled = false;
                    }
                }
            }

            RowLayout {
                width: parent.width
                Layout.alignment: Qt.AlignHCenter
                spacing: 20

                Button {
                    id: darkModeRestartBtn
                    text: "Application Quit"
                    enabled: false

                    Connections {
                        target: darkModeRestartBtn
                        function onClicked() {
                            darkModeDialog.bRestart = true;

                            if (themeSwitch.checked)
                            {
                                settings.style = "Material";
                                mainWindowModel.setColorMode(true);
                            }
                            else
                            {
                                settings.style = "Universal";
                                mainWindowModel.setColorMode(false);
                            }

                            mainWindowModel.restartSoftware();

                            Qt.quit();
                        }
                    }
                }

                Button {
                    id: darkModeCancelBtn
                    text: "Cancel"

                    Connections {
                        target: darkModeCancelBtn
                        function onClicked() {
                            darkModeDialog.close();
                        }
                    }
                }
            }
        }
    }

    Dialog {
        id: quitDialog
        title: "Quit GrepToolQML"
        x: Math.round((mainWindow.width - width) / 2)
        y: Math.round(mainWindow.height / 6)
        width: Math.round(Math.min(mainWindow.width, mainWindow.height) / 10 * 9)
        contentHeight: quitColumn.height

        modal: true
        focus: true
        closePolicy: Dialog.CloseOnEscape

        onOpened: {
            quitDialogBtnOK.focus = true;
        }

        ColumnLayout {
            id: quitColumn
            x: parent.x
            width: parent.width
            spacing: 20

            Label {
                text: "Do you want to quit GrepToolQML?"
                horizontalAlignment: Label.AlignHCenter
                verticalAlignment: Label.AlignVCenter
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.bottomMargin: 20
            }

            RowLayout {
                x: quitDialog.x
                width: quitDialog.width
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: 20
                spacing: 20

                Button {
                    id: quitDialogBtnOK
                    text: "OK"
                    focus: true
                    Layout.alignment: Qt.AlignHCenter

                    Connections {
                        target: quitDialogBtnOK
                        function onClicked() {
                            // Save Window State
                            saveApplicationState()

                            // Close QuitDialog
                            quitDialog.close()

                            // Exit GrepToolQML
                            Qt.quit()
                        }
                    }

                    Keys.onPressed: {
                        if (event.key === Qt.Key_Return)
                        {   // If pressed [Return] key
                            if(quitDialogBtnOK.focus)
                            {   // If focused [OK] button
                                // Save Window State
                                saveApplicationState()

                                // Close QuitDialog
                                quitDialog.close()

                                // Exit GrepToolQML
                                Qt.quit()
                            }
                            else if(quitDialogBtnCancel.focus)
                            {   // If focused [Cancel] button
                                // Close QuitDialog
                                quitDialog.close();
                            }
                        }
                    }
                }

                Button {
                    id: quitDialogBtnCancel
                    text: "Cancel"
                    Layout.alignment: Qt.AlignHCenter

                    Connections {
                        target: quitDialogBtnCancel
                        function onClicked() {
                            quitDialog.close();
                        }
                    }
                }
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
