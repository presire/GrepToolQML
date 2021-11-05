import QtQuick 2.15
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Controls.Universal 2.15


Page {
    id: pageAboutQt
    title: qsTr("about GrepToolQML")

    focus: true

    ColumnLayout {
        id: aboutColumn
        x: parent.x
        width: parent.width
        spacing: 50

        anchors.topMargin: 50

        Image {
            source: "Image/GrepToolQML.png"
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            fillMode: Image.PreserveAspectFit
        }

        Label {
            text: "GrepToolQML" + qsTr("\t") + mainWindowModel.getVersion()
            width: parent.availableWidth

            textFormat: Label.RichText
            wrapMode: Label.WordWrap

            horizontalAlignment: Label.AlignHCenter
            verticalAlignment: Label.AlignVCenter
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        Label {
            text: "<html><head/><body><p>GrepToolQML developed by Presire<br><br> \
                   <a href=\"https://github.com/presire\">Visit Prersire Github</a></p></body></html>"
            width: parent.availableWidth

            textFormat: Label.RichText
            wrapMode: Label.WordWrap

            horizontalAlignment: Label.AlignHCenter
            verticalAlignment: Label.AlignVCenter
            Layout.fillWidth: true
            Layout.fillHeight: true

            Connections {
                function onLinkActivated() {
                    Qt.openUrlExternally(link)
                }
            }
        }

//        Button {
//            id: aboutDialogButton
//            text: "Close"
//            focus: true

//            Layout.alignment: Qt.AlignHCenter
//            Layout.margins: 20

//            Connections {
//                target: aboutDialogButton
//                function onClicked() {
//                    aboutDialog.close()
//                }
//            }
//        }
    }
}
