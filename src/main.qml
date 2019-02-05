import QtQuick 2.9
import QtQuick.Controls 2.2
import org.kde.kirigami 2.4 as Kirigami
import org.kde.mauikit 1.0 as Maui

Maui.ApplicationWindow
{
    id: root
    title: qsTr("Station")
    property alias kterminal : terminal.kterminal
    viewBackgroundColor: backgroundColor
    backgroundColor: "#242222"
    textColor: "#fafafa"
    headBarBGColor: "#2c2c2c"
    headBarFGColor: "#fff"
//    headBar.visible: false
    floatingBar: true
    footBarOverlap: true
    footBarMargins: space.huge
    footBarAligment: Qt.AlignRight

    footBar.middleContent:[

        Maui.PieButton
        {
            iconName: "list-add"
            barHeight: footBar.height
            content: [
                Maui.ToolButton
                {
                    iconName: "edit-copy"
                    onClicked: kterminal.copyClipboard()
                },

                Maui.ToolButton
                {
                    iconName: "edit-paste"
                    onClicked: kterminal.pasteClipboard()
                },

                Maui.ToolButton
                {
                    iconName: "edit-find"
                    onClicked: terminal.findBar.visible = !terminal.findBar.visible
                }
            ]
        },

        Maui.ToolButton
        {
            iconName: "tab-new"
        }
    ]

    Maui.Terminal
    {
        id: terminal
        anchors.fill: parent
        kterminal.colorScheme: "DarkPastels"
    }
}
