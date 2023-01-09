import QtQuick 2.15
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import org.mauikit.controls 1.3 as Maui

import org.maui.station 1.0 as Station

Maui.Dialog
{
    id: control
    maxHeight: 600
    maxWidth: 400

    defaultButtons: false
    persistent: false

    headBar.visible: true
    signal commandTriggered(string command)

    headBar.middleContent: TextField
    {
        Layout.fillWidth: true
        Layout.maximumWidth: 500
        onAccepted: _commandsList.insert(text)
        placeholderText: i18n("New Command")

    }

        Maui.NewDialog
        {
            id: _editCommandDialog
            property int index : -1

            title: i18n("Edit Command")
            message: i18n("Edit a command shortcut")

            onFinished: _commandsList.edit(index, text)
        }


    stack: Maui.ListBrowser
    {
        id: _commandsShortcutList
        Layout.fillWidth: true
        Layout.fillHeight: true

        holder.visible: _commandsShortcutList.count === 0
        holder.emoji: "qrc:/station/edit-rename.svg"
        holder.title: i18n("No Commands")
        holder.body: i18n("Start adding new command shortcuts")

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
                control.close()
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
                _editCommandDialog.index= _commandsShortcutList.currentIndex
                _editCommandDialog.textEntry.text = _commandsShortcutList.model.get(_commandsShortcutList.currentIndex).value
                _editCommandDialog.open()
            }
        }
    }
}
