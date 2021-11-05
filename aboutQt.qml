import QtQuick 2.15
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Controls.Universal 2.15


Page {
    id: pageAboutQt
    title: qsTr("about Qt")

    focus: true

    ScrollView {
        id: scrollAboutQt
        width: parent.width
        height : parent.height
        contentWidth: aboutQtRow.width    // The important part
        contentHeight: aboutQtRow.height  // Same
        anchors.fill: parent
        clip : true                       // Prevent drawing column outside the scrollview borders

        RowLayout {
            id: aboutQtRow
            x: parent.x
            width: parent.width
            Layout.fillWidth: true
            spacing: 20

            Image {
                id: imgQt
                source: "Image/Qt.svg"
                Layout.alignment: Qt.AlignTop
                fillMode: Image.PreserveAspectFit

                Layout.margins: 20
            }

            Label {
                id: aboutQtLabel
                text: "<html><head/><body><p><h2>About Qt</h2><br> \
<br> \
This program uses Qt version 5.15.2.<br>
Qt is a C++ toolkit for cross-platform application development.<br>
Qt provides single-source portability across all major desktop operating systems.<br>
It is also available for embedded Linux and other embedded and mobile operating systems.<br>
<br>
Qt is available under multiple licensing options designed to accommodate the needs of our various users.<br>
<br>
Qt licensed under our commercial license agreement is appropriate for development of proprietary/commercial<br> \
software where you do not want to share any source code with third parties or otherwise cannot comply<br> \
with the terms of GNU (L)GPL.<br>
<br>
Qt licensed under GNU (L)GPL is appropriate for the development of Qt applications <br>
provided you can comply with the terms and conditions of the respective licenses.<br>
<br>
Please see <a href=\"http://qt.io/licensing/\">qt.io/licensing</a> for an overview of Qt licensing.<br>
<br>
Copyright (C) 2021 The Qt Company Ltd and other contributors.<br>
Qt and the Qt logo are trademarks of The Qt Company Ltd.<br>
<br>
Qt is The Qt Company Ltd product developed as an open source project.<br>
See <a href=\"http://qt.io/\">qt.io</a> for more information.</p></body></html>"
                width: aboutQtRow.width - imgQt.width - aboutQtRow.spacing * 2

                textFormat: Label.RichText
                wrapMode: Label.WordWrap
                background: null

                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignTop | Qt.AlignVCenter
                Layout.margins: 20

                Connections {
                    target: aboutQtLabel
                    function onLinkActivated() {
                        Qt.openUrlExternally(link)
                    }
                }
            }
        }
    }
}
