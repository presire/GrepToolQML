import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import Qt.labs.platform 1.1
import QtQuick.Dialogs 1.3
import QtQuick.Controls 2.15
import QtQml.Models 2.15
import QtMultimedia 5.15
import QtQuick.Controls.Material 2.15
import QtQuick.Controls.Universal 2.15
import MainWindow 1.0
import "WindowState.js" as WindowState


Page {
    id: pageGrep
    title: qsTr("Grep")

    CMainWindow {
        id: mainWindowModel;
    }

    Keys.onPressed: {
        if (event.key === Qt.Key_Control)
        {
            ctrlPressed = true;
        }
    }

    Keys.onReleased: {
        if (event.key === Qt.Key_Control)
        {
            ctrlPressed = false
        }
    }

    // Result of Slot
    Connections {
        target: mainWindowModel
        function onResult(isFile, DirName, FileName) {
            listModel.append({"file" : isFile, "fileName": FileName, "filePath" : DirName});
            listViewSearch.forceLayout();
        }
    }

    Connections {
        target: mainWindowModel
        function onResultCancel() {
            enableUI();

            errorDialog.messageTitle = qsTr("Cancel Searching Files and Directories");
            errorDialog.messageText  = qsTr("The search for files and directories has been canceled.");
            errorDialog.open();
        }
    }

    Connections {
        target: mainWindowModel
        function onResultDone(strItemCount) {
            enableUI();

            completeDialog.title = qsTr("Complete search");
            completeDialog.messageText = qsTr("The search for the item is complete.") + qsTr("\n\n") + qsTr("Total of items searched : ") + qsTr(strItemCount);
            completeDialog.open();
        }
    }

    WorkerScript {
        id: wsClearListModel
        source: "ClearListModel.js"  // Specify WorkerScript file

        onMessage: {  // Communication event from WorkerScript
            // Start searching items
            cancelbtn.enabled = true;

            mainWindowModel.startSignal(editDirectoryPath.text, editExtension.text, option);

            bSelect = false;
        }
    }

    function enableUI() {
        btnDirectorySelect.enabled  = true;
        selectBtn.enabled = true;
        cancelbtn.enabled = false;
    }

    function disableUI() {
        btnDirectorySelect.enabled  = false;
        selectBtn.enabled = false;
        cancelbtn.enabled = false;
    }

    property bool ctrlPressed: false
    property var arrayFocusPos: []
    property bool bSelect: false
    property int option: 0

    // Grep UI Control
    ScrollView {
        id: scrollGrep
        width: parent.width
        height : parent.height
        contentWidth: grepColLayout.width    // The important part
        contentHeight: grepColLayout.height  // Same
        anchors.fill: parent
        clip : true                       // Prevent drawing column outside the scrollview borders

        ColumnLayout {
            id: grepColLayout
            x: parent.x + 5
            y: parent.y
            width: parent.width
            Layout.fillWidth: true
            spacing: 0

            Frame {
                id: frameList
                x: pageGrep.x + 5
                width: pageGrep.width - 10
                height: parent.height * 0.6

                Layout.topMargin: 5

                ListView {
                    id: listViewSearch
                    anchors.fill: parent
                    implicitWidth: parent.width
                    implicitHeight: parent.height

                    focus: true
                    clip: true

                    highlightMoveDuration: 10
                    highlightMoveVelocity: 10
                    highlightResizeDuration : 10
                    highlightResizeVelocity : 10
                    snapMode: ListView.SnapToItem

                    model: ListModel {
                        id: listModel
                    }

                    onCurrentItemChanged: {
                        var bFocus = false;

                        if (!bSelect)
                        {
                            if (pageGrep.ctrlPressed)
                            {   // If press [Ctrl] Key, multiple items can be selected
                                for(let i = 0; i < pageGrep.arrayFocusPos.length; i++)
                                {
                                    let indexa = pageGrep.arrayFocusPos.shift();
                                    if(indexa === listViewSearch.currentIndex)
                                    {
                                        bFocus = true;
                                        break;
                                    }

                                    pageGrep.arrayFocusPos.push(indexa);
                                }

                                if (bFocus)
                                {
                                    listViewSearch.itemAtIndex(listViewSearch.currentIndex).color = "transparent";
                                }
                                else
                                {
                                    listViewSearch.itemAtIndex(listViewSearch.currentIndex).color = "#0080f0";
                                    pageGrep.arrayFocusPos.push(listViewSearch.currentIndex);
                                }
                            }
                            else
                            {   // If don't press [Ctrl] Key, one item can be selected
                                // Set the selected all items to unfocused
                                while (pageGrep.arrayFocusPos.length > 0)
                                {
                                    let indexa = pageGrep.arrayFocusPos.pop();
                                    listViewSearch.itemAtIndex(indexa).color = "transparent";
                                }

                                // Focus on the selected item
                                listViewSearch.itemAtIndex(listViewSearch.currentIndex).color = "#0080f0";
                                pageGrep.arrayFocusPos.push(listViewSearch.currentIndex);
                            }
                        }
                    }

                    Keys.onPressed: {
                        if (event.key === Qt.Key_Up)
                        {   // Focus on previous ListItem
                            if(pageGrep.arrayFocusPos.length < 1)
                            {
                                return;
                            }

                            // Disable [Ctrl]Key Flag
                            pageGrep.ctrlPressed = false;

                            // Set the selected all items to unfocused
                            var currentPos = pageGrep.arrayFocusPos.shift();
                            listViewSearch.itemAtIndex(currentPos).color = "transparent";

                            while (pageGrep.arrayFocusPos.length > 0)
                            {
                                let index = pageGrep.arrayFocusPos.pop();
                                listViewSearch.itemAtIndex(index).color = "transparent";
                            }

                            // Focus on the selected item
                            if((currentPos - 1) >= 0)
                            {
                                listViewSearch.itemAtIndex(currentPos - 1).color = "#0080f0";
                                pageGrep.arrayFocusPos.push(currentPos - 1);
                            }
                            else
                            {
                                listViewSearch.itemAtIndex(currentPos).color = "#0080f0";
                                pageGrep.arrayFocusPos.push(currentPos);
                            }
                        }
                        else if (event.key === Qt.Key_Down)
                        {   // Focus on next ListItem
                            if(pageGrep.arrayFocusPos.length < 1)
                            {
                                return;
                            }

                            // Disable [Ctrl]Key Flag
                            pageGrep.ctrlPressed = false;

                            // Set the selected all items to unfocused
                            currentPos = pageGrep.arrayFocusPos.shift();
                            listViewSearch.itemAtIndex(currentPos).color = "transparent";

                            while (pageGrep.arrayFocusPos.length > 0)
                            {
                                let index = pageGrep.arrayFocusPos.pop();
                                listViewSearch.itemAtIndex(index).color = "transparent";
                            }

                            // Focus on the selected item
                            if(listModel.count > currentPos + 1)
                            {
                                listViewSearch.itemAtIndex(currentPos + 1).color = "#0080f0";
                                pageGrep.arrayFocusPos.push(currentPos + 1);
                            }
                            else
                            {
                                listViewSearch.itemAtIndex(currentPos).color = "#0080f0";
                                pageGrep.arrayFocusPos.push(currentPos);
                            }
                        }
                    }

                    // Layout for each record in the List
                    delegate: Rectangle {
                        id: listItem
                        width: frameList.width
                        height: itemLayout.height
                        color: "transparent"

                        property int indexOfThisDelegate: index

                        RowLayout {
                            id: itemLayout
                            width: parent.width
                            spacing: 0
                            Layout.fillWidth: true

                            Image {
                                id: iconType
                                source: model.file === 0 ? "Image/File.png" : "Image/Directory.png"
                                width: 24
                                height: 24
                                fillMode: Image.Stretch
                                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                Layout.leftMargin: 5
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0

                                TextArea {
                                    id: textFileName
                                    width: parent.width
                                    text: model.fileName
                                    color: mainWindowModel.getColorMode() ? "white" : "black"

                                    wrapMode: TextArea.WordWrap
                                    readOnly: true
                                    textMargin: 0.0
                                    background: null
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignTop | Qt.AlignVCenter
                                }

                                Label {
                                    id: labelFilePath
                                    text: model.filePath
                                    width: parent.width

                                    font.italic: true
                                    font.pointSize: 8
                                    color: mainWindowModel.getColorMode() ? "white" : "black"

                                    wrapMode: Label.WordWrap
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignTop | Qt.AlignVCenter
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton | Qt.RightButton  // Enable "LeftButton" and "RightButton" on mouse

                            onClicked: {
                                if (mouse.button === Qt.LeftButton)
                                {   // Left Clicked
                                    listViewSearch.forceActiveFocus();

                                    if (Number(indexOfThisDelegate) == Number(listViewSearch.currentIndex))
                                    {   // if you select the same item last time (Then, Don't work onCurrentItemChanged handler)
                                        var bFocus = false;
                                        if (ctrlPressed)
                                        {
                                            for (var i = 0; i < pageGrep.arrayFocusPos.length; i++)
                                            {
                                                let indexa = pageGrep.arrayFocusPos[i];
                                                if (indexa === indexOfThisDelegate)
                                                {
                                                    bFocus = true;
                                                    break;
                                                }
                                            }

                                            if (bFocus)
                                            {
                                                let indexa = pageGrep.arrayFocusPos.pop();
                                                listViewSearch.itemAtIndex(indexa).color = "transparent";
                                            }
                                            else
                                            {
                                                listViewSearch.itemAtIndex(indexOfThisDelegate).color = "#0080f0";
                                                pageGrep.arrayFocusPos.push(indexOfThisDelegate);
                                            }
                                        }
                                        else
                                        {
                                            while (pageGrep.arrayFocusPos.length > 0)
                                            {
                                                let indexa = pageGrep.arrayFocusPos.pop();
                                                listViewSearch.itemAtIndex(indexa).color = "transparent";
                                            }

                                            listViewSearch.itemAtIndex(indexOfThisDelegate).color = "#0080f0";
                                            pageGrep.arrayFocusPos.push(indexOfThisDelegate);
                                        }
                                    }

                                    listViewSearch.currentIndex = index;
                                }
                                else if (mouse.button == Qt.RightButton)
                                {   // Right Clicked
                                    listViewSearch.forceActiveFocus();

                                    if (pageGrep.arrayFocusPos.length < 2)
                                    {
                                        listViewSearch.currentIndex = index;
                                    }

                                    contextMenu.popup();
                                }

                                mouse.accepted = true;
                            }

                            onPressAndHold: {
                                if (pageGrep.ctrlPressed)
                                {   // If press [Ctrl] Key, multiple items can be selected
                                    // Make sure it is already in focus
                                    let bFocus = false;
                                    for(let i = 0; i < pageGrep.arrayFocusPos.length; i++)
                                    {
                                        let indexa = pageGrep.arrayFocusPos[i];
                                        if(indexa === indexOfThisDelegate)
                                        {
                                            bFocus = true;
                                            break;
                                        }
                                    }

                                    if (!bFocus)
                                    {   // If the item is not in focus
                                        listViewSearch.itemAtIndex(indexOfThisDelegate).color = "#0080f0";
                                        pageGrep.arrayFocusPos.push(indexOfThisDelegate);
                                    }
                                }
                                else
                                {   // If don't press [Ctrl] Key, one item can be selected
                                    // Set the selected all items to unfocused
                                    while (pageGrep.arrayFocusPos.length > 0)
                                    {
                                        let indexa = pageGrep.arrayFocusPos.pop();
                                        listViewSearch.itemAtIndex(indexa).color = "transparent";
                                    }

                                    // Focus on the selected item
                                    listViewSearch.itemAtIndex(indexOfThisDelegate).color = "#0080f0";
                                    pageGrep.arrayFocusPos.push(indexOfThisDelegate);
                                }

                                contextMenu.topMargin = WindowState.menuHeight + listViewSearch.mapToItem(pageGrep, 0, 0).y + parent.mapToItem(listViewSearch, 0, 0).y;
                                if (listViewSearch.mapToItem(pageGrep, 0, 0).x + mouse.x + contextMenu.width > pageGrep.width)
                                {
                                    contextMenu.leftMargin = mouse.x - contextMenu.width - 50;
                                }
                                else
                                {
                                    contextMenu.leftMargin = mouse.x + listViewSearch.x + 50;
                                }

                                contextMenu.popup();
                            }

                            onDoubleClicked: {
                                pageGrep.ctrlPressed ? pageGrep.ctrlPressed = false : pageGrep.ctrlPressed = true
                            }
                        }

                        Menu {
                            id: contextMenu

                            // Open the selected ListItem(s) in text editor
                            Action {
                                text: "Open in text editor"
                                onTriggered: {
                                    if (pageGrep.arrayFocusPos.length <= 1)
                                    {
                                        let isFile = listModel.get(indexOfThisDelegate).file;
                                        if(isFile === 0)
                                        {
                                            let editor = mainWindowModel.getEditor();
                                            if(editor === qsTr(""))
                                            {
                                                errorDialog.messageTitle = qsTr("Error : Don't open file");
                                                errorDialog.messageText  = qsTr("No editor is selected.\n") + qsTr("Please select the editor you want to use\n") + qsTr("[Feature] -> [Settings].");
                                                errorDialog.open();
                                                return;
                                            }

                                            let file = listModel.get(indexOfThisDelegate).filePath + listModel.get(indexOfThisDelegate).fileName;
                                            let iRet = mainWindowModel.openFile(editor, listModel.get(indexOfThisDelegate).fileName, listModel.get(indexOfThisDelegate).filePath);
                                            if(iRet === -1)
                                            {
                                                errorDialog.messageTitle = qsTr("Error : Don't open file");
                                                errorDialog.messageText  = qsTr("The selected file does not exist.") + qsTr("\n") + qsTr("Please check again.");
                                                errorDialog.open();
                                                return;
                                            }
                                            else if(iRet === -2)
                                            {
                                                errorDialog.messageTitle = qsTr("Error : Don't open file");
                                                errorDialog.messageText  = qsTr("You do not have permission to read the selected file.") + qsTr("\n") + qsTr("Please check again.");
                                                errorDialog.open();
                                                return;
                                            }
                                        }
                                        else
                                        {
                                            errorDialog.messageTitle = qsTr("Error : Don't open directory");
                                            errorDialog.messageText  = qsTr("This is a directory, it cannot be opened with text editor.") + qsTr("\n") + qsTr("Please select file.");
                                            errorDialog.open();
                                            return;
                                        }
                                    }
                                    else
                                    {
                                        errorDialog.messageTitle = qsTr("Error : Don't open multiple files");
                                        errorDialog.messageText  = qsTr("<html><head/><body><p>
                                                                 <u>You have selected " + pageGrep.arrayFocusPos.length + " items.</u><br><br>
                                                                 You can open 1 file, select a single file.</p></body></html>");
                                        errorDialog.open();
                                        return;
                                    }
                                }
                            }

                            // Open the selected 2 ListItems in diff tool
                            Action {
                                text: "Diff Files"
                                onTriggered: {
                                    // Diff two files
                                    if(pageGrep.arrayFocusPos.length === 2)
                                    {
                                        // Check Files or Directories
                                        let index_left = pageGrep.arrayFocusPos.shift();
                                        if(listModel.get(index_left).file === 0)
                                        {
                                            var file_left = listModel.get(index_left).filePath + qsTr("/") + listModel.get(index_left).fileName;
                                        }
                                        else
                                        {
                                            pageGrep.arrayFocusPos.unshift(index_left);

                                            errorDialog.messageTitle = qsTr("Error : Don't open diff tool");
                                            errorDialog.messageText  = qsTr("The directory has been selected.") + qsTr("\n") + qsTr("Please select 2 files.");
                                            errorDialog.open();
                                            return;
                                        }

                                        let index_right = pageGrep.arrayFocusPos.shift();
                                        if(listModel.get(index_right).file === 0)
                                        {
                                            var file_right = listModel.get(index_right).filePath + qsTr("/") + listModel.get(index_right).fileName;
                                        }
                                        else
                                        {
                                            pageGrep.arrayFocusPos.unshift(index_right);

                                            errorDialog.messageTitle = qsTr("Error : Don't open diff tool");
                                            errorDialog.messageText  = qsTr("The directory has been selected.") + qsTr("\n") + qsTr("Please select 2 files.");
                                            errorDialog.open();
                                            return;
                                        }

                                        let diff = mainWindowModel.getDiffTool();
                                        if(diff === qsTr(""))
                                        {
                                            errorDialog.messageTitle = qsTr("Error : Don't open file");
                                            errorDialog.messageText  = qsTr("No diff tool is selected.\n") + qsTr("Please select the editor you want to use\n") + qsTr("[Feature] -> [Settings].");
                                            errorDialog.open();
                                            return;
                                        }

                                        let iRet = mainWindowModel.diffFiles(diff, file_left, file_right);
                                        if(iRet === -1)
                                        {
                                            errorDialog.messageTitle = qsTr("Error : Don't open diff tool");
                                            errorDialog.messageText  = qsTr("The selected file does not exist.") + qsTr("\n") + qsTr("Please check again.");
                                            errorDialog.open();
                                        }
                                        else if(iRet === -2)
                                        {
                                            errorDialog.messageTitle = qsTr("Error : Don't open diff tool");
                                            errorDialog.messageText  = qsTr("You do not have permission to read the selected file.") + qsTr("\n") + qsTr("Please check again.");
                                            errorDialog.open();
                                        }

                                        pageGrep.arrayFocusPos.push(index_left);
                                        pageGrep.arrayFocusPos.push(index_right);

                                        return;
                                    }
                                    else
                                    {
                                        errorDialog.messageTitle = qsTr("Error : Don't open diff tool");
                                        errorDialog.messageText  = qsTr("<html><head/><body><p>
                                                                 <u>You have selected " + pageGrep.arrayFocusPos.length + " items.</u><br><br>
                                                                 You can compare the 2 files, select 2 files.</p></body></html>");
                                        errorDialog.open();
                                        return;
                                    }
                                }
                            }

                            // Remove the selected 1 ListItem
                            Action {
                                text: "Remove"
                                onTriggered: {
                                    // Play sound effect "Warning.mp3"
                                    soundWarning.play();

                                    // Display a confirmation dialog for deletion
                                    removeDialog.bAllRemove = false;
                                    removeDialog.open();
                                }
                            }

                            // Remove the All ListItems
                            Action {
                                text: "All Remove"
                                onTriggered: {
                                    // Play sound effect "Warning.mp3"
                                    soundWarning.play();

                                    // Display a confirmation dialog for deletion
                                    removeDialog.bAllRemove = true;
                                    removeDialog.title = qsTr("Delete All Items")
                                    removeDialog.text = qsTr("Do you want to delete all files / directories?");
                                    removeDialog.open();
                                }
                            }
                        }

                        Keys.onPressed: {
                            if (event.key === Qt.Key_Menu)
                            {
                                contextMenu.popup();
                            }
                            else if (event.key === Qt.Key_Delete)
                            {
                                // Play sound effect "Warning.wav"
                                soundWarning.play();

                                // Display a confirmation dialog for deletion
                                removeDialog.bAllRemove = false;
                                removeDialog.open();
                            }
                        }

                        // Item remove sound
                        SoundEffect {
                            id: soundWarning
                            source: "Sound/Warning.wav"
                            volume: 0.2
                        }
                    }

                    // Display vertical scroll bar to ListView
                    ScrollBar.vertical: ScrollBar {
                        active: true
                    }
                }
            }

            Label {
                id: labelCtrl
                text: pageGrep.ctrlPressed ? qsTr("Multi Select: ON") : qsTr("Multi Select: OFF")
                font.pointSize: 9
                color: pageGrep.ctrlPressed ? "#ff5555" : mainWindowModel.getColorMode() ? "white" : "black"

                horizontalAlignment: Label.AlignRight
                verticalAlignment: Label.AlignVCenter
                Layout.topMargin: 5
                Layout.rightMargin: 20
                Layout.fillWidth: true
                Layout.fillHeight: true

                wrapMode: Label.WordWrap
            }

            Label {
                id: labelDirectory
                x: pageGrep.x + 10
                width: parent.width - 20
                text: qsTr("Please Input Searched Directory Path.")

                Layout.topMargin: 5

                wrapMode: Label.WordWrap
            }

            RowLayout {
                id: editDirectoryLayout
                x: pageGrep.x + 10
                width: parent.width - 20
                spacing: 20

                Layout.topMargin: 5

                TextField {
                    id: editDirectoryPath
                    //x: pageGrep.x + 10
                    text: mainWindowModel.getDirectory()
                    width: pageGrep.width - btnDirectorySelect.width - parent.spacing * 2 - Layout.leftMargin
                    implicitWidth: pageGrep.width - btnDirectorySelect.width - parent.spacing * 2 - Layout.leftMargin

                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                    placeholderText: qsTr("/home/foo")
                    selectedTextColor: mainWindowModel.getColorMode() ? "white" : "black"

                    cursorVisible: true
                    horizontalAlignment: TextField.AlignLeft

                    onTextChanged: {
                        let iRet = mainWindowModel.saveDirectory(editDirectoryPath.text);
                        if(iRet === -1)
                        {
                            errorDialog.messageTitle = qsTr("Error : Don't save directory path");
                            errorDialog.messageText  = qsTr("Error : The directory path inputed could not be saved.") + qsTr("\n") + qsTr("For details, please contact the developer.");
                            errorDialog.open();
                            return;
                        }
                    }
                }

                RoundButton {
                    id: btnDirectorySelect
                    text: "..."

                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Layout.rightMargin: 20

                    focus: true

                    onClicked: {
                        directorySelectDialog.open();
                    }
                }
            }

            Label {
                 id: labelExtension
                 x: pageGrep.x + 10
                 text: qsTr("Please Input extension(WildCard) to search.")

                 Layout.topMargin: 10

                 wrapMode: Label.WordWrap
             }

             TextField {
                 id: editExtension
                 x: pageGrep.x + 10
                 width: pageGrep.width - parent.spacing * 2 - Layout.rightMargin
                 implicitWidth: pageGrep.width - parent.spacing * 2 - Layout.rightMargin
                 text: mainWindowModel.getExtension()
                 placeholderText: qsTr("*.jpg;*.png")
                 selectedTextColor: mainWindowModel.getColorMode() ? "white" : "black"

                 Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                 Layout.topMargin: 5
                 Layout.rightMargin: 20

                 cursorVisible: true
                 horizontalAlignment: TextField.AlignLeft

                 onTextChanged: {
                     let iRet = mainWindowModel.saveExtension(editExtension.text);
                     if(iRet === -1)
                     {
                         errorDialog.messageTitle = qsTr("Error : Don't save extension");
                         errorDialog.messageText  = qsTr("Error : The extension inputed could not be saved.") + qsTr("\n") + qsTr("For details, please contact the developer.");
                         errorDialog.open();
                         return;
                     }
                 }
             }

             Label {
                 id: labelOption
                 x: pageGrep.x + 10
                 text: qsTr("Search options:")

                 Layout.topMargin: 10

                 wrapMode: Label.WordWrap
             }

             ButtonGroup {
                 id: optionRadioGGroup
                 buttons: optionColumn.children
             }

             Column {
                 id: optionColumn

                 Layout.topMargin: 5

                 RadioButton {
                     checked: true
                     text: qsTr("Search only files.")
                     ButtonGroup.group: optionRadioGGroup

                     onClicked: {
                         option = 0;
                     }
                 }

                 RadioButton {
                     text: qsTr("Search for files and directories.")
                     ButtonGroup.group: optionRadioGGroup

                     onClicked: {
                         option = 1;
                     }
                 }

                 RadioButton {
                     text: qsTr("Search only directories.")
                     ButtonGroup.group: optionRadioGGroup

                     onClicked: {
                         option = 2;
                     }
                 }
             }

             RowLayout {
                 id: btnLayout
                 x: pageGrep.x + 10
                 width: pageGrep.width - 20
                 spacing: 50

                 Layout.topMargin: 10
                 Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                 Button {
                     id: selectBtn
                     text: qsTr("Select (&S)")
                     enabled: true

                     Connections {
                         target: selectBtn
                         function onClicked() {
                             if(editDirectoryPath.text === qsTr(""))
                             {
                                 errorDialog.messageTitle = qsTr("Error : Don't search files / directories");
                                 errorDialog.messageText  = qsTr("Error : The directory to be searched is empty") + qsTr("\n") + qsTr("Please input the directory to be searched.");
                                 errorDialog.open();

                                 editDirectoryPath.focus = true;

                                 return;
                             }

                             bSelect = true;

                             // Clear ListModel and focus information
                             wsClearListModel.sendMessage({"model" : listModel, "count" : listModel.count});

                             arrayFocusPos = [];

                             // Disable User Interface
                             disableUI();
                         }
                     }
                 }

                 Button {
                     id: cancelbtn
                     text: qsTr("Cancel (&C)")
                     enabled: false

                     Connections {
                         target: cancelbtn
                         function onClicked() {
                             mainWindowModel.cancelSignal();
                         }
                     }
                 }
             }
        }
    }


    FolderDialog {
        id: directorySelectDialog
        title: "Please select a Directory"

        visible: false
        currentFolder: ""
        folder: StandardPaths.standardLocations(StandardPaths.HomeLocation)[0]
        options: FolderDialog.ShowDirsOnly
        modality: Qt.WindowModal

        acceptLabel: qsTr("Select")
        rejectLabel: qsTr("Cancel")

        onAccepted: {
            var strDirPath = directorySelectDialog.folder.toString().replace("file://", "");
            editDirectoryPath.text = strDirPath;
            directorySelectDialog.close();
        }
        onRejected: {
            directorySelectDialog.close();
        }
    }


    MessageDialog {
        id: removeDialog
        title: "Delete Items"
        text: "Do you want to delete files / directories?"
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        visible: false
        modality: Qt.WindowModal
        icon: StandardIcon.Information

        property bool bAllRemove: false

        onAccepted: {
            var bError = false;

            if(bAllRemove)
            {
                // Disable [Ctrl]Key Flag
                pageGrep.ctrlPressed = false;

                // Remove the index of ListItem(s) in focus
                pageGrep.arrayFocusPos = [];

                while(listModel.count > 0)
                {
                    let file = listModel.get(0).filePath + qsTr("/") + listModel.get(0).fileName;
                    let iRet = mainWindowModel.removeFile(file);
                    if(iRet === 0)
                    {   // If successed removing files / directories
                        listModel.remove(0);
                    }
                    else
                    {   // If failed removing files / directories
                        bError = true;
                        break;
                    }
                }
            }
            else
            {
                while (pageGrep.arrayFocusPos.length > 0)
                {
                    let index = pageGrep.arrayFocusPos.shift();

                    let file = listModel.get(index).filePath + qsTr("/") + listModel.get(index).fileName;
                    let iRet = mainWindowModel.removeFile(file);
                    if(iRet === 0)
                    {   // If successed removing files / directories
                        listModel.remove(index);
                    }
                    else
                    {   // If failed removing files / directories
                        bError = true;

                        pageGrep.arrayFocusPos.push(index);

                        break;
                    }
                }
            }

            if (bError)
            {
                errorDialog.messageTitle = qsTr("Error : files / directories");
                errorDialog.messageText  = qsTr("Cannot remove files / directories, Due to some kind of error.") + qsTr("\n") +
                                           qsTr("Make sure that the files / directories exists.");
                errorDialog.open();
            }

            removeDialog.close();
        }

        onRejected: {
            removeDialog.close();
        }
    }


    Dialog {
        id: completeDialog
        title: completeDialog.messageTitle
        x: Math.round((mainWindow.width - width) / 2)
        y: Math.round(mainWindow.height / 6)
        width: Math.round(Math.min(mainWindow.width, mainWindow.height) / 10 * 9)

        modal: true
        focus: true
        closePolicy: Dialog.CloseOnEscape

        property string messageTitle: ""
        property string messageText: ""

        ColumnLayout {
            id: completeColumn
            x: parent.x
            width: parent.width
            spacing: 20

            Label {
                text: completeDialog.messageText
                horizontalAlignment: Label.AlignHCenter
                verticalAlignment: Label.AlignVCenter
                Layout.fillWidth: true
                Layout.fillHeight: true

                wrapMode: Label.WordWrap
            }

            Button {
                id: completeOK
                text: "OK"
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: 20

                Connections {
                    target: completeOK
                    function onClicked() {
                        completeDialog.close();
                    }
                }
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
        closePolicy: Dialog.NoAutoClose

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

                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                Layout.margins: 20

                Image {
                    id: errorIcon
                    source: "Image/Critical.png"
                    fillMode: Image.Stretch
                    scale: 0.8
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
                id: errorOKBtn
                text: "OK"
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: 20

                Connections {
                    target: errorOKBtn
                    function onClicked() {
                        errorDialog.close();
                    }
                }
            }
        }
    }
}
