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

    background: Rectangle
    {
        opacity: 0.5
        color: Maui.Theme.backgroundColor
    }

    footBar.background: null

    headBar.farRightContent: Loader
    {
        asynchronous: true
        sourceComponent: Maui.ToolButtonMenu
        {
            icon.name: "overflow-menu"
            MenuItem
            {
                text: i18n("Function Keys")
                autoExclusive: true
                checked: settings.keysModelCurrentIndex === 0
                checkable: true
                onTriggered: settings.keysModelCurrentIndex = 0
            }

            MenuItem
            {
                text: i18n("Nano")
                autoExclusive: true
                checked: settings.keysModelCurrentIndex === 1
                checkable: true
                onTriggered: settings.keysModelCurrentIndex = 1
            }

            MenuItem
            {
                text: i18n("Ctrl Modifiers")
                autoExclusive: true
                checked: settings.keysModelCurrentIndex === 2
                checkable: true
                onTriggered:settings.keysModelCurrentIndex = 2
            }

            MenuItem
            {
                text: i18n("Navigation")
                autoExclusive: true
                checked: settings.keysModelCurrentIndex === 3
                checkable: true
                onTriggered: settings.keysModelCurrentIndex = 3
            }

            MenuItem
            {
                text: i18n("Favorite")
                autoExclusive: true
                checked: settings.keysModelCurrentIndex === 4
                checkable: true
                onTriggered: settings.keysModelCurrentIndex = 4
            }

            MenuSeparator {}

            MenuItem
            {
                text: i18n("Add shortcut")
                icon.name: "list-add"
                onTriggered: control.newCommand()
            }
        }
    }

    headBar.leftContent: Repeater
    {
        model: Station.KeysModel
        {
            id: _keysModel
            group: settings.keysModelCurrentIndex
        }

        Maui.BasicToolButton
        {
            visible: !_shortcutsButton.checked

            Layout.minimumWidth: 54
            implicitHeight: Maui.Style.iconSizes.medium + Maui.Style.space.medium
            font.bold: true
            text: model.label
            icon.name: model.iconName

            onClicked: _keysModel.sendKey(index, currentTerminal.kterminal)

            activeFocusOnTab: false
            focusPolicy: Qt.NoFocus
            autoRepeat: true

            background: Maui.ShadowedRectangle
            {
                color: pressed || down || checked || hovered ? Qt.rgba(Maui.Theme.highlightColor.r, Maui.Theme.highlightColor.g, Maui.Theme.highlightColor.b, 0.15) : Qt.lighter(Maui.Theme.backgroundColor)

                radius: Maui.Style.radiusV
                shadow.size: Maui.Style.space.medium
                shadow.color: Qt.rgba(0.0, 0.0, 0.0, 0.15)
                shadow.yOffset: 2
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
