import QtQuick 2.15
import QtQml 2.15
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

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

    property alias currentTab : _layout.currentItem
    readonly property Maui.Terminal currentTerminal : currentTab.currentItem.terminal

    Text
    {
        visible: false
        id: _defaultFont
        font.family: "Monospace"
        font.pointSize: Maui.Style.defaultFontSize
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
        property font font : _defaultFont.font
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
            onClicked: root.openTab("$HOME")
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
            checked: currentTerminal.findBar.visible
            onClicked:
            {
                currentTerminal.footBar.visible = !currentTerminal.footBar.visible
            }
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

            SplitView.fillWidth: true
            SplitView.fillHeight: true

            spacing: 0
            mobile: !root.isWide
            onNewTabClicked: openTab("$HOME")
            onCloseTabClicked: closeTab(index)
        }

        CommandShortcuts
        {
            id: _shortcuts

//            visible: Maui.Handy.isTouch

            SplitView.fillWidth: true
            SplitView.preferredHeight: Maui.Style.toolBarHeight -1
            SplitView.maximumHeight: parent.height * 0.5
            SplitView.minimumHeight : Maui.Style.toolBarHeight -1

            onCommandTriggered:
            {
                root.currentTerminal.session.sendText(command)
                root.currentTerminal.forceActiveFocus()
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
