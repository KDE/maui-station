import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.mauikit.controls as Maui

import org.maui.station as Station

Maui.Page
{
    id: control

    signal commandTriggered(string command, bool autorun)

    headBar.visible: false
    footerMargins: Maui.Style.defaultPadding
    footBar.forceCenterMiddleContent: false
    footBar.middleContent: Maui.SearchField
    {
        placeholderText: i18n("Filter/Add")
        onAccepted:
        {
            _commandsList.insert(text)
            clear()
        }

        Layout.fillWidth: true
        Layout.maximumWidth: 500
        implicitWidth: 80
    }

    Maui.InputDialog
    {
        id: _editCommandDialog
        property int index : -1

        title: i18n("Edit Command")
        message: i18n("Edit a command shortcut")

        onFinished: _commandsList.edit(index, text)
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

    Maui.ListBrowser
    {
        id: _commandsShortcutList
        anchors.fill: parent
        currentIndex: -1
        holder.visible: _commandsShortcutList.count === 0
        holder.emoji: "qrc:/station/edit-rename.svg"
        holder.title: i18n("No Commands")
        holder.body: i18n("Start adding new command shortcuts")

        // footer: Maui.ListBrowserDelegate
        // {
        //     width: ListView.view.width
        //     label1.text: "> " + currentTerminal.session.foregroundProcessName
        //     label1.font
        //     {
        //         pointSize: Maui.Style.fontSizes.medium
        //         family:  currentTerminal.kterminal.font.family
        //     }

        //     label1.color: currentTerminal.kterminal.foregroundColor

        //     background: Rectangle
        //     {
        //         color: currentTerminal.kterminal.backgroundColor
        //         radius: Maui.Style.radiusV
        //     }
        // }

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
            label1.text: "> " + model.value
            label1.font
            {
                pointSize: Maui.Style.fontSizes.medium
                family:  currentTerminal.kterminal.font.family
            }

            label1.color: currentTerminal.kterminal.foregroundColor

            background: Rectangle
            {
                color: currentTerminal.kterminal.backgroundColor
                radius: Maui.Style.radiusV
            }

            onClicked:
            {
                commandTriggered(model.value, false)
            }

            onDoubleClicked:
            {
                commandTriggered(model.value, true)
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

            ToolButton
            {
                flat: true
                icon.name: "media-playback-start"
                icon.width: Maui.Style.iconSizes.small
                padding: 0
                background: null
                icon.color: currentTerminal.kterminal.foregroundColor
                onClicked:
                {
                    _commandsShortcutList.currentIndex = index
                    commandTriggered(model.value, true)
                }
            }
        }
    }
}
