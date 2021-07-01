import QtQuick 2.15
import QtQml 2.15
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import QtQml.Models 2.3
import Qt.labs.settings 1.0

import QtGraphicalEffects 1.0

import org.kde.kirigami 2.14 as Kirigami
import org.mauikit.controls 1.3 as Maui

import org.maui.station 1.0 as Station

Maui.Page
{
    id: control

    implicitHeight: Math.min(Math.max(root.height* 0.3, _commandsShortcutList.contentHeight), 200)

    signal commandTriggered(string command)

    headBar.farRightContent: ToolButton
    {
        icon.name: "list-add"
        onClicked: control.newCommand()

    }

    headBar.farLeftContent: [
        ToolButton
        {
            id: _shortcutsButton
            checkable: true
            icon.name: "configure-shortcuts"
            focusPolicy: Qt.NoFocus

            onClicked: console.log(currentTerminal.session.history)
        },

        Maui.ToolActions
        {
            id: _groupsBox
            visible: _shortcutsButton.checked
            autoExclusive: true
            expanded: true
            currentIndex: 4

            function close()
            {
                _shortcutsButton.checked = false
            }

            Action
            {
                text: i18n("Fn")
                onTriggered: _groupsBox.close()
            }

            Action
            {
                text: i18n("Nano")
                onTriggered: _groupsBox.close()
            }

            Action
            {
                text: i18n("Ctrl")
                onTriggered: _groupsBox.close()
            }

            Action
            {
                text: i18n("Nav")
                onTriggered: _groupsBox.close()
            }

            Action
            {
                text: i18n("Fav")
                onTriggered: _groupsBox.close()
            }
        }
    ]

    headBar.leftContent: Repeater
    {
        model: Station.KeysModel
        {
            id: _keysModel
            group: _groupsBox.currentIndex
        }

        Maui.BasicToolButton
        {
            visible: !_shortcutsButton.checked

            Layout.minimumWidth: 54
            implicitHeight: Maui.Style.iconSizes.medium + Maui.Style.space.medium

            text: model.label
            icon.name: model.iconName

            onClicked: _keysModel.sendKey(index, currentTerminal.kterminal)

            activeFocusOnTab: false
            focusPolicy: Qt.NoFocus
            autoRepeat: true

            background: Kirigami.ShadowedRectangle
            {
                color: pressed || down || checked || hovered ? Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.15) : Qt.lighter(Kirigami.Theme.backgroundColor)

                radius: Kirigami.Units.smallSpacing

                shadow.size: Kirigami.Units.largeSpacing
                shadow.color: Qt.rgba(0.0, 0.0, 0.0, 0.15)
                shadow.yOffset: Kirigami.Units.devicePixelRatio * 2
            }
        }
    }

    footBar.middleContent: Maui.TextField
    {
        id: _commandField
        Layout.fillWidth: true
        placeholderText: i18n("Filter or add a new command")

        onTextChanged:
        {
            _commandsShortcutList.model.filter = text
        }

        onCleared: _commandsShortcutList.model.filter = ""

        onAccepted:
        {
            _commandsShortcutList.model.filter = text

            if(_commandsList.insert(text))
            {
                commandTriggered(text)
                clear()
            }
        }
    }

    Maui.NewDialog
    {
        id: _newCommandDialog
        title: i18n("New Command")
        message: i18n("Add a new command shortcut")
        textEntry.text: _commandField.text
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
                _editCommandDialog.index= index
                _editCommandDialog.textEntry.text = model.value
                _editCommandDialog.open()
            }
        }
    }

    function newCommand()
    {
        _newCommandDialog.textEntry.text = _commandField.text
        _newCommandDialog.open()
    }
}
