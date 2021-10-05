import QtQuick 2.15
import QtQuick.Controls 2.14

import Qt.labs.settings 1.0

import org.kde.kirigami 2.14 as Kirigami
import org.mauikit.controls 1.3 as Maui

import org.maui.station 1.0 as Station

import "widgets"

Maui.ApplicationWindow
{
    id: root
    title: currentTerminal? currentTerminal.session.title : ""
    altHeader: Kirigami.Settings.isMobile

    page.title: root.title
    page.showTitle: true

    autoHideHeader: settings.focusMode

    property alias dialog : _dialogLoader.item

    property alias currentTab : _layout.currentItem
    readonly property Maui.Terminal currentTerminal : currentTab.currentItem.terminal
    readonly property font defaultFont : Qt.font({ family: "Monospace", pointSize: Maui.Style.defaultFontSize})

    Maui.WindowBlur
    {
        view: root
        geometry: Qt.rect(root.x, root.y, root.width, root.height)
        windowRadius: root.background.radius
        enabled: !Kirigami.Settings.isMobile
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
        property bool focusMode : false
        property bool pathBar : true
        property int lineSpacing : 0
        property font font : defaultFont
        property int keysModelCurrentIndex : 4
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

    headBar.forceCenterMiddleContent: root.isWide
    headBar.leftContent: Loader
    {
        asynchronous: true
        sourceComponent: Maui.ToolButtonMenu
        {
            icon.name: "application-menu"

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
        }
    }

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
            visible: _layout.mobile && _layout.count > 1
            text: _layout.count
            checked: _layout.overviewMode
            checkable: true
            icon.name: "tab-new"
            onClicked: _layout.openOverview()
        },

        ToolButton
        {
            icon.name: "list-add"
            onClicked: root.openTab("$HOME")
        }
    ]

    Maui.SplitView
    {
        anchors.fill: parent
        spacing: 0
        orientation: Qt.Vertical

        Maui.TabView
        {
            id: _layout
            //mobile: true
            SplitView.fillWidth: true
            SplitView.fillHeight: true
            tabBarVisible: !mobile
            spacing: 0
            mobile: !root.isWide
            onNewTabClicked: openTab("$HOME")
            onCloseTabClicked: closeTab(index)
        }

        Loader
        {
            id: _shortcutsLoader

            SplitView.fillWidth: true
            SplitView.preferredHeight: Maui.Style.toolBarHeight -1
            SplitView.maximumHeight: parent.height * 0.5
            SplitView.minimumHeight : Maui.Style.toolBarHeight -1
            active: Maui.Handy.isTouch
            visible: active
            asynchronous: true
            sourceComponent: CommandShortcuts
            {
                onCommandTriggered:
                {
                    root.currentTerminal.session.sendText(command)
                    root.currentTerminal.forceActiveFocus()
                }
            }
        }
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

    Connections
    {
        target: Station.Station
        function onOpenPaths(urls)
        {
            for(var url of urls)
            {
                console.log("Open tabs:", url)
                openTab(url)
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
}
