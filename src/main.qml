import QtQuick 2.15
import QtQml 2.15
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import Qt.labs.settings 1.0

import QtGraphicalEffects 1.0

import org.kde.kirigami 2.14 as Kirigami
import org.mauikit.controls 1.3 as Maui

import org.maui.station 1.0 as Station

import "widgets"

Maui.ApplicationWindow
{
    id: root
    title: currentTab && currentTab.terminal ? currentTab.terminal.session.title : ""
    altHeader: Kirigami.Settings.isMobile

    page.title: root.title
    page.showTitle: true

    autoHideHeader: settings.focusMode

    property alias currentTab : _layout.currentItem
    readonly property Maui.Terminal currentTerminal : currentTab.terminal

    onClosing:
    {
        if(currentTab.terminal.session.hasActiveProcess)
        {
            root.notify("face-ninja", "Process is running", "Are you sure you want to quit?", root.close())
            close.accepted = false
        }
    }

    Settings
    {
        id: settings
        category: "General"
        property string colorScheme: "DarkPastels"
        property bool focusMode : false
        property bool pathBar : true
        property int lineSpacing : 0
        property font font
    }


    TutorialDialog
    {
        id: _tutorialDialog
    }

    mainMenu: [
        Action
        {
            text: i18n("Tutorial")
            onTriggered: _tutorialDialog.open()
            icon.name : "help-contents"
        },

        Action
        {
            icon.name: "settings-configure"
            text: i18n("Settings")
            onTriggered: _settingsDialog.open()
        }
    ]

    SettingsDialog
    {
        id: _settingsDialog
    }

    headBar.leftContent: [
        ToolButton
        {
            icon.name: "tab-new"
            onClicked: root.openTab("~")
        }]

    headBar.rightContent: [
        ToolButton
        {
            id: _splitButton
            checked: root.currentTab && root.currentTab.count === 2

icon.name: root.currentTab.orientation === Qt.Horizontal ? "view-split-left-right" : "view-split-top-bottom"
           onClicked: root.currentTab.split()
        },


        ToolButton
        {
            icon.name: "edit-find"
            checked: currentTab.terminal.findBar.visible
            onClicked:
            {
                currentTab.terminal.footBar.visible = !currentTab.terminal.footBar.visible
            }
        }
    ]

    footBar.visible: Maui.Handy.isTouch
    page.footerBackground.color: "transparent"

    page.footerColumn: CommandShortcuts
    {
        id: _shortcuts
        visible: false
        width: parent.width

        onCommandTriggered:
        {
            root.currentTerminal.session.sendText(command)
            root.currentTerminal.forceActiveFocus()

            if(!pinned)
            {
                _shortcuts.visible = false
            }
        }
    }

    footBar.farRightContent: ToolButton
    {
        icon.name: "edit-rename"
        checked: _shortcuts.visible
        checkable: true
        onClicked: _shortcuts.visible = !_shortcuts.visible
    }

    footBar.farLeftContent: [
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

    footBar.leftContent: Repeater
    {
        model: Station.KeysModel
        {
            id: _keysModel
            group: _groupsBox.currentIndex
        }

        Maui.BasicToolButton
        {
            visible: !_shortcutsButton.checked

            implicitHeight: Maui.Style.iconSizes.medium + Maui.Style.space.medium

            id: button
            text: model.label
            icon.name: model.iconName

            onClicked: _keysModel.sendKey(index, currentTerminal.kterminal)

            activeFocusOnTab: false
            focusPolicy: Qt.NoFocus

            background: Kirigami.ShadowedRectangle
            {
                color: Kirigami.Theme.backgroundColor

                radius: Kirigami.Units.smallSpacing

                shadow.size: Kirigami.Units.largeSpacing
                shadow.color: Qt.rgba(0.0, 0.0, 0.0, 0.15)
                shadow.yOffset: Kirigami.Units.devicePixelRatio * 2

                border.width: Kirigami.Units.devicePixelRatio
                border.color: Qt.tint(Kirigami.Theme.textColor,
                                      Qt.rgba(color.r, color.g, color.b, 0.6))
            }
        }
    }

    Maui.TabView
    {
        id: _layout
        anchors.fill: parent
        spacing: 0
        mobile: !root.isWide
        onNewTabClicked: openTab("$HOME")
    }

    Component.onCompleted:
    {
        openTab("$HOME")
    }

    Component
    {
        id: _terminalComponent
        TerminalLayout {}
    }

    function openTab(path)
    {
        _layout.addTab(_terminalComponent, {'path': path});
        _layout.currentIndex = _layout.count -1
    }

    function closeTab(index)
    {
        _layout.closeTab(index)
    }
}
