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

    background: Rectangle
    {
        opacity: 0.5
        color: Kirigami.Theme.backgroundColor
    }
    footBar.background: null

    headBar.farRightContent: Maui.ToolButtonMenu
    {
        id: _groupsBox
        property int currentIndex : 4
        icon.name: "overflow-menu"
        MenuItem
        {
            text: i18n("Function Keys")
            autoExclusive: true
            checked: currentIndex = 0
            checkable: true
            onTriggered: _groupsBox.currentIndex = 0
        }

        MenuItem
        {
            text: i18n("Nano")
            autoExclusive: true
            checked: currentIndex = 1
            checkable: true
            onTriggered: _groupsBox.currentIndex = 1
        }

        MenuItem
        {
            text: i18n("Ctrl Modifiers")
            autoExclusive: true
            checked: currentIndex = 2
            checkable: true
            onTriggered: _groupsBox.currentIndex = 2
        }

        MenuItem
        {
            text: i18n("Navigation")
            autoExclusive: true
            checked: currentIndex = 3
            checkable: true
            onTriggered: _groupsBox.currentIndex = 3
        }

        MenuItem
        {
            text: i18n("Favorite")
            autoExclusive: true
            checked: currentIndex = 4
            checkable: true
            onTriggered: _groupsBox.currentIndex = 4
        }

        MenuSeparator {}

        MenuItem
        {
            text: i18n("Add shortcut")
            icon.name: "list-add"
            onTriggered: control.newCommand()
        }

    }

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
