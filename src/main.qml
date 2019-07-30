import QtQuick 2.9
import QtQuick.Controls 2.2
import org.kde.kirigami 2.4 as Kirigami
import org.kde.mauikit 1.0 as Maui
import QtQuick.Layouts 1.3


Maui.ApplicationWindow
{
    id: root
    title: qsTr("Station")
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

    onSearchButtonClicked: terminal.findBar.visible = !terminal.findBar.visible


    Rectangle
    {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: space.big
        radius: radiusV

        height: toolBarHeight
        width: height
z: 999
        color: Kirigami.Theme.highlightColor

        Maui.PieButton
        {
            anchors.fill : parent
            icon.name: "list-add"
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

    footBar.middleContent: ToolButton
        {
            icon.name: "tab-new"
        }


Maui.Terminal
{
    id: terminal
//     anchors.fill: parent
    anchors.fill : parent

    kterminal.colorScheme: "DarkPastels"

//        menu:[
//            Maui.MenuItem
//            {
//                Row
//                {
//                    anchors.fill: parent

//                    Rectangle
//                    {
//                        height: iconSizes.medium
//                        width: height
//                        radius: radiusV
//                        color: "#2c2c2c"
//                    }

//                    Rectangle
//                    {
//                        height: iconSizes.medium
//                        width: height
//                        radius: radiusV
//                        color: "#2c2c2c"
//                    }
//                }
//            }
//        ]
}


}
