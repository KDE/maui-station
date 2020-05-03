import QtQuick 2.9
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import QtQml.Models 2.3

ColumnLayout
{
    id: control
    spacing: 0
    height: _browserList.height
    width: _browserList.width
    focus: true

    property alias terminal : _splitView.currentItem
    property alias orientation : _splitView.orientation
    property alias count : _splitView.count

    function forceActiveFocus()
    {
        control.terminal.forceActiveFocus()
    }

    ObjectModel { id: splitObjectModel }

    SplitView
    {
        id: _splitView
        focus: true
        Layout.fillWidth: true
        Layout.fillHeight: true

        Repeater
        {
            model: splitObjectModel
        }



        onCurrentItemChanged: currentItem.forceActiveFocus()

        handle: Rectangle
        {
            implicitWidth: 6
            implicitHeight: 6
            color: SplitHandle.pressed ? Kirigami.Theme.highlightColor
                                       : (SplitHandle.hovered ? Qt.lighter(Kirigami.Theme.backgroundColor, 1.1) : Kirigami.Theme.backgroundColor)

            Rectangle
            {
                anchors.centerIn: parent
                height: _splitView.orientation == Qt.Horizontal ? 48 : parent.height
                width:  _splitView.orientation == Qt.Horizontal ? parent.width : 48
                color: _splitSeparator1.color
            }


            states: [  State
            {
                when: _splitView.orientation === Qt.Horizontal

                AnchorChanges
                {
                    target: _splitSeparator1
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: undefined
                }

                AnchorChanges
                {
                    target: _splitSeparator2
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    anchors.left: undefined
                }
            },

            State
            {
                when: _splitView.orientation === Qt.Vertical

                AnchorChanges
                {
                    target: _splitSeparator1
                    anchors.top: parent.top
                    anchors.bottom: undefined
                    anchors.left: parent.left
                    anchors.right: parent.right
                }

                AnchorChanges
                {
                    target: _splitSeparator2
                    anchors.top: undefined
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    anchors.left: parent.left
                }
            }

            ]


            Kirigami.Separator
            {
                id: _splitSeparator1
            }

            Kirigami.Separator
            {
                id: _splitSeparator2
            }
        }

    }

    Kirigami.Separator
    {
        Layout.fillWidth: true
    }

    Maui.PathBar
    {
        //    Kirigami.Theme.backgroundColor:"transparent"
        //    Kirigami.Theme.textColor:c"white"
        border.color: "transparent"
        radius: 0
        Layout.fillWidth: true
        Layout.alignment:Qt.AlignBottom
        onPlaceClicked:
        {
            terminal.session.sendText("cd " + path.trim() + "\n")
        }
        url: control.terminal.title.slice(control.terminal.title.indexOf(":")+1)
    }

    Component.onCompleted: split(Qt.Vertical)

    function split(orientation)
    {
        _splitView.orientation = orientation

        if(_splitView.count === 2)
            return;

        const component = Qt.createComponent("Terminal.qml");
        if (component.status === Component.Ready)
        {
            const object = component.createObject(splitObjectModel, {'path': control.path, 'index': _splitView.count});
            splitObjectModel.append(object)
        }
    }

}
