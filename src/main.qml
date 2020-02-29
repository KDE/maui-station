import QtQuick 2.10
import QtQuick.Controls 2.10
import org.kde.kirigami 2.4 as Kirigami
import org.kde.mauikit 1.0 as Maui
import QtQuick.Layouts 1.3

import org.maui.station 1.0 as Station

Maui.ApplicationWindow
{
    id: root
    title: qsTr("Station | ") +  terminal.session.title
    property alias kterminal : terminal.kterminal

    Maui.App.handleAccounts: false
    Maui.App.description: qsTr("Station is a convergent terminal emulator")
    Maui.App.iconName: "qrc:/station.svg"

    onClosing:
    {
        if(terminal.session.hasActiveProcess)
        {
            root.notify("face-ninja", "Process is running", "Are you sure you want to quit?", root.close())
            close.accepted = false
        }
    }

    headBar.leftContent: RowLayout
    {
        Label
        {
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: terminal.session.title
        }
    }

    headBar.rightContent: [
        ToolButton
        {
            icon.name: "view-split-left-right"
        },

        ToolButton
        {
            icon.name: "view-split-top-bottom"
        },

        ToolButton
        {
            icon.name: "tab-new"
        }
    ]

    Maui.PieButton
    {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: height
        //        radius: Maui.Style.radiusV
        z: 999

        height: Maui.Style.toolBarHeight
        icon.name: "tools"
        icon.color: Kirigami.Theme.highlightedTextColor
        alignment: Qt.AlignLeft

        Action
        {
            icon.name: "edit-copy"
            onTriggered: kterminal.copyClipboard()
        }

        Action
        {
            icon.name: "edit-paste"
            onTriggered: kterminal.pasteClipboard()
        }

        Action
        {
            icon.name: "edit-find"
            onTriggered: terminal.findBar.visible = !terminal.findBar.visible
        }
    }

    footBar.visible: Maui.Handy.isTouch
    footBar.leftContent:  Repeater
    {
        model: Station.KeysModel
        {
            id: _keysModel
        }

        Button
        {
            text: model.label
            icon.name: model.iconName

            onClicked: _keysModel.sendKey(index, terminal.kterminal)
        }
    }

    Maui.Terminal
    {
        id: terminal
        //     anchors.fill: parent
        anchors.fill : parent
        session.shellProgram: "/bin/zsh"
        kterminal.colorScheme: "DarkPastels"
    }
}
