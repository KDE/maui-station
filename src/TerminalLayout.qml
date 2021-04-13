import QtQuick 2.14
import QtQml 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.14 as Kirigami
import org.mauikit.controls 1.3 as Maui

import QtQml.Models 2.3

ColumnLayout
{
    id: control
    spacing: 0
    height: ListView.view.height
    width:  ListView.view.width
    focus: true

    property string title: terminal.title
    property alias terminal : _splitView.currentItem
    property alias orientation : _splitView.orientation
    property alias count : _splitView.count

    function forceActiveFocus()
    {
        control.terminal.forceActiveFocus()
    }

    ObjectModel { id: splitObjectModel }

    Maui.Dialog
    {
        id: _confirmCloseDialog
        title: i18n("Close")
        message: i18n("A process is currently still running. Are oyu sure you want to close it?")

        onAccepted: pop()
    }

    SplitView
    {
        id: _splitView
        focus: true

        Binding on orientation
        {
            value: width >= 600 ? Qt.Horizontal : Qt.Vertical
            restoreMode: Binding.RestoreValue
        }

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

    Component.onCompleted: split()

    function split()
    {
        if(_splitView.count === 2)
        {
            if(control.terminal.session.hasActiveProcess)
            {
                _confirmCloseDialog.open()
            }else
            {
                pop()
            }

            return
        }//close the innactive split

        const component = Qt.createComponent("Terminal.qml");
        if (component.status === Component.Ready)
        {
            const object = component.createObject(splitObjectModel, {'path': control.path, 'index': _splitView.count});
            splitObjectModel.append(object)
        }
    }

    function pop()
    {
        if(_splitView.count === 1)
        {
            return //can not pop all the browsers, leave at leats 1
        }

        console.log("Current splitview index", _splitView.currentIndex)
        closeSplit(_splitView.currentIndex === 1 ? 0 : 1)
    }

    function closeSplit(index) //closes a split but triggering a warning before
    {
        if(index >= _splitView.count)
        {
            return
        }

        const item = _splitView.itemAt(index)
        destroyItem(index)
    }

    function destroyItem(index) //deestroys a split view withouth warning
    {
        var item = _splitView.itemAt(index)
        item.destroy()
        splitObjectModel.remove(index)
        _splitView.currentIndex = 0
    }
}
