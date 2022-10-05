import QtQuick 2.15
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import Qt.labs.settings 1.0
import org.mauikit.controls 1.3 as Maui

import org.maui.station 1.0 as Station

import "widgets"

Maui.ApplicationWindow
{
    id: root
    title: currentTerminal? currentTerminal.session.title : ""

    property alias dialog : _dialogLoader.item
    Maui.Style.styleType: settings.colorStyle
    property alias currentTab : _layout.currentItem
    readonly property Maui.Terminal currentTerminal : currentTab.currentItem.terminal
    readonly property font defaultFont : Qt.font({ family: "Monospace", pointSize: Maui.Style.defaultFontSize})

    Maui.WindowBlur
    {
        view: root
        geometry: Qt.rect(root.x, root.y, root.width, root.height)
        windowRadius: Maui.Style.radiusV
        enabled: !Maui.Handy.isMobile
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
        property string colorScheme: "DarkPastels"
        property bool pathBar : true
        property int lineSpacing : 0
        property font font : defaultFont
        property int keysModelCurrentIndex : 4
        property int colorStyle : Maui.Style.Dark
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

        Maui.TabView
        {
            id: _layout

            anchors.fill: parent

            onNewTabClicked: openTab("$HOME")
            onCloseTabClicked: closeTab(index)

            tabBar.showNewTabButton: false
            tabBar.visible: true

            tabBar.content: [



                Maui.ToolButtonMenu
                {
                    icon.name: "list-add"

                    MenuItem
                    {
                        icon.name: "tab-new"
                        text: i18n("New tab")
                        onTriggered: root.openTab("$HOME")
                    }

                    MenuItem
                    {
                        //                        enabled: root.currentTab && root.currentTab.count === 1
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

                Maui.WindowControls
                {

                }
            ]
        }


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
                    visible: !_shortcutsButton.checked

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


    Component.onCompleted:
    {
        openTab("$HOME")
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

    function openTab(path)
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
