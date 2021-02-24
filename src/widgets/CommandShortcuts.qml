import QtQuick 2.15
import QtQml 2.15
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import QtQml.Models 2.3
import Qt.labs.settings 1.0

import QtGraphicalEffects 1.0

import org.kde.kirigami 2.14 as Kirigami
import org.kde.mauikit 1.3 as Maui

import org.maui.station 1.0 as Station

Maui.Page
{
    id: control
    implicitHeight: Math.min(Math.max(root.height* 0.3, _commandsShortcutList.contentHeight), 200)

    signal commandTriggered(string command)

    property alias pinned : _pinButton.checked

    headBar.rightContent: ToolButton
    {
        icon.name: "list-add"
        onClicked: _newCommandDialog.open()
    }

    headBar.leftContent: ToolButton
    {
        id: _pinButton
        icon.name: "edit-pin"
        checkable: true
    }

    headBar.middleContent: Maui.TextField
    {
        Layout.fillWidth: true
        placeholderText: i18n("Filter command")
    }

    Maui.NewDialog
    {
        id: _newCommandDialog
        title: i18n("New Command")
        message: i18n("Add a new command shortcut")

        onFinished: _commandsList.insert(text)
    }


    Maui.NewDialog
    {
        id: _editCommandDialog
        property int index : -1

        title: i18n("Edit Command")
        message: i18n("Edit a command shortcut")

        onFinished: _commandsList.edit(index, text)
    }

    Maui.Holder
    {
        visible: _commandsShortcutList.count === 0
        emoji: "qrc:/edit-rename.svg"
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

            onClicked: commandTriggered(model.value)

            template.content: [

                ToolButton
                {
                    icon.name: "edit-clear"
                    onClicked:
                    {
                         _commandsList.remove(index)
                    }
                },

                ToolButton
                {
                    icon.name: "edit-rename"
                    onClicked:
                    {
                        _editCommandDialog.index= index
                        _editCommandDialog.textEntry.text = model.value
                         _editCommandDialog.open()
                    }
                }

            ]
        }
    }
}
