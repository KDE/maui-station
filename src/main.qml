import QtQuick 2.15
import QtQml 2.15
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import QtQml.Models 2.3
import Qt.labs.settings 1.0

import QtGraphicalEffects 1.0

import org.kde.kirigami 2.14 as Kirigami
import org.kde.mauikit 1.3 as Maui

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
    
    property alias currentTab : _browserList.currentItem
    readonly property Maui.Terminal currentTerminal : currentTab.terminal

    onCurrentTabChanged:
    {
        _splitButton.currentIndex = currentTab && currentTab.count > 1 ? currentTab.orientation === Qt.Vertical ? 1 : (currentTab.orientation === Qt.Horizontal ? 0 : -1) : -1
    }

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
            text: i18n("Commands")
//            onTriggered: _tutorialDialog.open()
            icon.name: "edit-pin"
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

    footBar.rightContent: ToolButton
    {
        icon.name: "edit-rename"
        checked: _shortcuts.visible
        checkable: true
        onClicked: _shortcuts.visible = !_shortcuts.visible
    }

    footBar.leftContent: [
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
        },

        ToolSeparator{},

        Repeater
        {
            model: Station.KeysModel
            {
                id: _keysModel
                group: _groupsBox.currentIndex
            }

            Maui.BasicToolButton
            {
                visible: !_shortcutsButton.checked

                height: Maui.Style.iconSizes.medium + Maui.Style.space.medium

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
    ]

    ObjectModel { id: tabsObjectModel }

    ColumnLayout
    {
        id: _layout
        anchors.fill: parent
        spacing: 0

        Maui.TabBar
        {
            id: tabsBar
            visible: _browserList.count > 1
            Layout.fillWidth: true
            Layout.preferredHeight: tabsBar.implicitHeight
            position: TabBar.Header
            currentIndex : _browserList.currentIndex
            onNewTabClicked: openTab("$HOME")
            Repeater
            {
                id: _repeater
                model: tabsObjectModel.count

                Maui.TabButton
                {
                    id: _tabButton
                    implicitHeight: tabsBar.implicitHeight
                    implicitWidth: Math.max(parent.width / _repeater.count, 120)
                    checked: index === _browserList.currentIndex

                    text: tabsObjectModel.get(index).terminal.title

                    onClicked:
                    {
                        _browserList.currentIndex = index
                    }

                    onCloseClicked: root.closeTab(index)
                }
            }
        }

        Flickable
        {
            Layout.margins: 0
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView
            {
                id: _browserList
                anchors.fill: parent
                clip: true
                focus: true
                orientation: ListView.Horizontal
                model: tabsObjectModel
                snapMode: ListView.SnapOneItem
                spacing: 0
                interactive: Kirigami.Settings.hasTransientTouchInput && tabsObjectModel.count > 1
                highlightFollowsCurrentItem: true
                highlightMoveDuration: 0
                highlightResizeDuration: 0
                highlightRangeMode: ListView.StrictlyEnforceRange
                preferredHighlightBegin: 0
                preferredHighlightEnd: width
                highlight: Item {}
                highlightMoveVelocity: -1
                highlightResizeVelocity: -1

                onMovementEnded: _browserList.currentIndex = indexAt(contentX, contentY)
                boundsBehavior: Flickable.StopAtBounds

                onCurrentItemChanged:
                {
                    //                       control.currentPath =  tabsObjectModel.get(currentIndex).path
                    //                       _viewTypeGroup.currentIndex = browserView.viewType
                    currentItem.forceActiveFocus()
                }
            }
        }
    }

    Component.onCompleted:
    {
        openTab("$HOME")
    }

    function openTab(path)
    {
        const component = Qt.createComponent("TerminalLayout.qml");
        if (component.status === Component.Ready)
        {
            const object = component.createObject(tabsObjectModel, {'path': path});
            tabsObjectModel.append(object)
            _browserList.currentIndex = tabsObjectModel.count - 1
        }
    }

    function closeTab(index)
    {
        tabsObjectModel.remove(index)
    }
}
