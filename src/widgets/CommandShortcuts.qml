import QtQuick 2.15
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import org.mauikit.controls 1.3 as Maui

import org.maui.station 1.0 as Station

Maui.Page
{
    id: control

    implicitHeight: Math.min(Math.max(root.height* 0.3, _commandsShortcutList.contentHeight), 200)

    signal commandTriggered(string command)

//    background: Rectangle
//    {
//        opacity: 0.5
//        color: Maui.Theme.backgroundColor
//    }

//    footBar.background: null





    Component
    {
        id: _newCommandDialogComponent
        Maui.NewDialog
        {
            title: i18n("New Command")
            message: i18n("Add a new command shortcut")
            textEntry.text: _commandField.text
            onFinished: _commandsList.insert(text)
        }

    }


    Component
    {
        id: _editCommandDialogComponent

        Maui.NewDialog
        {
            property int index : -1

            title: i18n("Edit Command")
            message: i18n("Edit a command shortcut")

            onFinished: _commandsList.edit(index, text)
        }
    }

    Maui.Holder
    {
        anchors.fill: parent
        visible: _commandsShortcutList.count === 0
        emoji: "qrc:/station/edit-rename.svg"
        title: i18n("No Commands")
        body: i18n("Start adding new command shortcuts")
    }

    Maui.ListBrowser
    {
        id: _commandsShortcutList
        anchors.fill: parent

        model: Maui.BaseModel
        {
            list: Station.CommandsModel
            {
                id: _commandsList
            }
        }

        delegate: Maui.ListBrowserDelegate
        {
            width: ListView.view.width
            label1.text: model.value

            onClicked:
            {
                _commandsShortcutList.currentIndex = index
                commandTriggered(model.value)
            }

            onRightClicked:
            {
                _commandsShortcutList.currentIndex = index
                _menu.popup()
            }

            onPressAndHold:
            {
                _commandsShortcutList.currentIndex = index
                _menu.popup()
            }
        }
    }

    Menu
    {
        id: _menu

        MenuItem
        {
            text: i18n("Remove")
            icon.name: "edit-clear"
            onTriggered:
            {
                _commandsList.remove(index)
            }
        }

        MenuItem
        {
            text: i18n("Edit")
            icon.name: "edit-rename"
            onTriggered:
            {
                _dialogLoader.sourceComponent = _editCommandDialogComponent
                dialog.index= index
                dialog.textEntry.text = model.value
                dialog.open()
            }
        }
    }

    function newCommand()
    {
        _dialogLoader.sourceComponent = _newCommandDialogComponent
        dialog.textEntry.text = _commandField.text
        dialog.open()
    }
}
