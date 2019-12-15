import QtQuick 2.9
import QtQuick.Controls 2.2
import org.kde.kirigami 2.4 as Kirigami
import org.kde.mauikit 1.0 as Maui
import QtQuick.Layouts 1.3

import org.maui.station 1.0 as Station

Maui.ApplicationWindow
{
    id: root
    title: qsTr("Station | ") +  terminal.session.title
    property alias kterminal : terminal.kterminal
    //    viewBackgroundColor: backgroundColor
    //    backgroundColor: "#242222"
    //    textColor: "#fafafa"
    //    headBarBGColor: "#2c2c2c"
    //    headBarFGColor: "#fff"
    //    floatingBar: true
    //    footBarOverlap: true
    //    footBarMargins: space.huge
    //    footBarAligment: Qt.AlignRight
    //    headBar.drawBorder: false

    rightIcon.visible: false

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

//        Rectangle
//        {
//            color: terminal.session.hasActiveProcess ? Kirigami.Theme.neutralTextColor : Kirigami.Theme.positiveTextColor
//            Layout.preferredHeight: Maui.Style.iconSizes.tiny
//            Layout.preferredWidth: height
//            radius: height
//        }

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


    Maui.FloatingButton
    {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Maui.Style.space.big
//        radius: Maui.Style.radiusV

        height: Maui.Style.toolBarHeight
        width: height
        z: 999
//        color: Kirigami.Theme.highlightColor

        Maui.PieButton
        {
            anchors.fill : parent
            icon.name: "tools"
            icon.color: Kirigami.Theme.highlightedTextColor
            barHeight: parent.height
            alignment: Qt.AlignLeft
            content: [
                ToolButton
                {
                    icon.name: "edit-copy"
                    onClicked: kterminal.copyClipboard()
                },

                ToolButton
                {
                    icon.name: "edit-paste"
                    onClicked: kterminal.pasteClipboard()
                },

                ToolButton
                {
                    icon.name: "edit-find"
                    onClicked: terminal.findBar.visible = !terminal.findBar.visible
                }
            ]
        }
    }

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
