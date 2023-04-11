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
    readonly property font defaultFont : Maui.Style.monospacedFont

    Maui.WindowBlur
    {
        view: root
        geometry: Qt.rect(root.x, root.y, root.width, root.height)
        windowRadius: Maui.Style.radiusV
        enabled: !Maui.Handy.isMobile && settings.windowTranslucency
    }

    onClosing:
    {
        _dialogLoader.sourceComponent = null
        _dialogLoader.sourceComponent = _confirmCloseDialogComponent

        if(anyTabHasActiveProcess() && !dialog.discard && settings.preventClosing)
        {
            close.accepted = false

            dialog.index = -1
            dialog.cb =  ()=> {root.close()}
            close.accepted = false
            dialog.open()
            return
        }

        close.accepted = true
    }

    Settings
    {
        id: settings
        property string colorScheme: "Maui-Dark"

        property int lineSpacing : 0
        property font font : defaultFont
        property int keysModelCurrentIndex : 4
        property int colorStyle : Maui.Style.Dark

        property double windowOpacity: 0.6
        property bool windowTranslucency: false

        property bool adaptiveColorScheme : true
        property bool preventClosing: true
        property bool alertProcess: true

        property bool enableBold: true
        property bool blinkingCursor: true
        property bool fullCursorHeight: true
        property bool antialiasText: true
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

        background: Rectangle
        {
            color: Maui.Theme.backgroundColor
            opacity: _layout.count === 0 ? 1 : 0
        }

        Maui.TabView
        {
            id: _layout
            background: null

            anchors.fill: parent

            onNewTabClicked: root.openTab("$PWD")
            onCloseTabClicked: root.closeTab(index)

            tabBar.showNewTabButton: false
            tabBar.visible: true
            tabBar.background: Rectangle
            {
                color: Maui.Theme.backgroundColor
                opacity: settings.windowTranslucency ? settings.windowOpacity : 1
            }

            tabBar.content: [

                ToolButton
                {
                  icon.name: "edit-find"
                  checked: root.currentTerminal.footBar.visible
                  onClicked: root.currentTerminal.toggleSearchBar()
                },

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

        footBar.visible: true

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

        footBar.farLeftContent:  ToolButton
        {
            icon.name: "input-keyboard-virtual"
            text: i18n("Toggle Virtual Keyboard")
            display: AbstractButton.IconOnly
            onClicked:
            {
                if (Qt.inputMethod.visible)
                {
                    Qt.inputMethod.hide();
                } else
                {
                    root.currentTerminal.forceActiveFocus();
                    Qt.inputMethod.show();
                }
            }
        }

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

    Component
    {
        id: _confirmCloseDialogComponent

        Maui.Dialog
        {
            id : _dialog
            property var cb : ({})
            property int index: -1
            property bool discard : false

            headBar.visible: false
            title: i18n("Close")
            message: i18n("A process is still running. Are you sure you want to interrupt it and close it?")
            template.iconSource: "dialog-warning"
            template.iconVisible: true
            template.iconSizeHint: Maui.Style.iconSizes.huge

            acceptButton.text: i18n("Close")
            rejectButton.text: i18n("Cancel")
            scrollView.padding: Maui.Style.space.big

            onAccepted:
            {
                discard = true
                _dialog.close()

                if(cb instanceof Function)
                {
                    cb(index)
                }

            }

            onRejected:
            {
                discard = false
                 close()
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
        var tab = _layout.tabAt(index)

        if(tab && tab.hasActiveProcess && settings.preventClosing)
        {
            _dialogLoader.sourceComponent = _confirmCloseDialogComponent
            dialog.index = index
            dialog.cb = _layout.closeTab
            dialog.open()
            return;
        }

        _layout.closeTab(index)
    }

    function openCommandDialog()
    {
        _dialogLoader.sourceComponent = _commandDialogComponent
        dialog.open()
    }

    function anyTabHasActiveProcess()
    {
        for(var i = 0; i < _layout.count; i ++)

        {
            let tab = _layout.tabAt(i)
            if(tab && tab.hasActiveProcess)
            {
                return true;
            }
        }

        return false;
    }
}
