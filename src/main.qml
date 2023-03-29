import QtQuick 2.15
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import Qt.labs.settings 1.0
import org.mauikit.controls 1.3 as Maui
import org.mauikit.terminal 1.0 as Term

import org.maui.station 1.0 as Station

import "widgets"

Maui.ApplicationWindow
{
    id: root
    title: currentTerminal? currentTerminal.session.title : ""

    property alias dialog : _dialogLoader.item
    Maui.Style.styleType: settings.colorStyle
    property alias currentTab : _layout.currentItem
    readonly property Term.Terminal currentTerminal : currentTab.currentItem.terminal
    readonly property font defaultFont : Qt.font({ family: "Monospace", pointSize: Maui.Style.defaultFontSize})

    Maui.WindowBlur
    {
        view: root
        geometry: Qt.rect(root.x, root.y, root.width, root.height)
        windowRadius: Maui.Style.radiusV
        enabled: !Maui.Handy.isMobile && settings.windowOpacity < 1
    }

    onClosing:
    {
        if(currentTerminal.session.hasActiveProcess)
        {
            root.notify("face-ninja", "Process is running", "Are you sure you want to quit?", root.close())
            close.accepted = false
        }
    }

    Settings
    {
        id: settings
        category: "General"
        property string colorScheme: "Maui-Dark"
        property bool pathBar : true
        property int lineSpacing : 0
        property font font : defaultFont
        property int keysModelCurrentIndex : 4
        property int colorStyle : Maui.Style.Dark
        property double windowOpacity: 1
        property int tabSpace: 4
        property bool adaptiveColorScheme : true
    }

    Loader
    {
        id: _dialogLoader
    }

    Component
    {
        id: _tutorialDialogComponent
        TutorialDialog {}
    }

    Component
    {
        id: _settingsDialogComponent
        SettingsDialog {}
    }

    Maui.Page
    {
        anchors.fill: parent
        headBar.visible: false

        background: null

        Maui.TabView
        {
            id: _layout
            background: null

            anchors.fill: parent

            onNewTabClicked: openTab("$PWD")
            onCloseTabClicked: closeTab(index)

            tabBar.showNewTabButton: false
            tabBar.visible: true
            tabBar.background: Rectangle
            {
                color: Maui.Theme.backgroundColor
                opacity: settings.windowOpacity
            }

            tabBar.content: [

                Maui.ToolButtonMenu
                {
                    icon.name: "list-add"

                    MenuItem
                    {
                        icon.name: "tab-new"
                        text: i18n("New Tab")
                        onTriggered: root.openTab("$PWD")
                    }

                    MenuItem
                    {
                        enabled: root.currentTab
                        checked: root.currentTab && root.currentTab.count === 2
                        text: i18n("Split")

                        icon.name: root.currentTab.orientation === Qt.Horizontal ? "view-split-left-right" : "view-split-top-bottom"
                        onTriggered: root.currentTab.split()
                    }

                    MenuSeparator {}

                    MenuItem
                    {
                        text: i18n("Tutorial")
                        onTriggered:
                        {
                            _dialogLoader.sourceComponent = _tutorialDialogComponent
                            dialog.open()
                        }
                        icon.name : "help-contents"
                    }

                    MenuItem
                    {
                        icon.name: "settings-configure"
                        text: i18n("Settings")
                        onTriggered:
                        {
                            _dialogLoader.sourceComponent = _settingsDialogComponent
                            dialog.open()
                        }
                    }

                    MenuItem
                    {
                        text: i18n("About")
                        icon.name: "documentinfo"
                        onTriggered: root.about()
                    }
                },

                Maui.WindowControls {}
            ]
        }

        Maui.Holder
        {
            anchors.fill: parent
            visible: _layout.count === 0
            title: i18n("Nothing here")
            body: i18n("To start hacking open a new tab or a split screen.")
            actions: Action
            {
                text: i18n("New Tab")
                onTriggered: root.openTab("$PWD")
            }
        }

        footBar.visible: Maui.Handy.isTouch

        footBar.farRightContent: Loader
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
            }
        }

        footBar.leftContent: [

            ToolButton
            {
                icon.name: "document-edit"
                onClicked: openCommandDialog()
            },

            Repeater
            {
                model: Station.KeysModel
                {
                    id: _keysModel
                    group: settings.keysModelCurrentIndex
                }

                Button
                {
                    font.bold: true
                    text: model.label
                    icon.name: model.iconName

                    onClicked: _keysModel.sendKey(index, currentTerminal.kterminal)

                    activeFocusOnTab: false
                    focusPolicy: Qt.NoFocus
                    autoRepeat: true
                }
            }
        ]
    }

    Component
    {
        id: _terminalComponent
        TerminalLayout {}
    }

    Component
    {
        id: _commandDialogComponent

        CommandShortcuts
        {
            onCommandTriggered:
            {
                root.currentTerminal.session.sendText(command)
                root.currentTerminal.forceActiveFocus()
            }
        }
    }

    function openTab(path : string)
    {
        _layout.addTab(_terminalComponent, {'path': path});
        _layout.currentIndex = _layout.count -1
    }

    function closeTab(index)
    {
        _layout.closeTab(index)
    }

    function openCommandDialog()
    {
        _dialogLoader.sourceComponent = _commandDialogComponent
        dialog.open()
    }
}
