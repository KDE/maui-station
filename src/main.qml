import QtQuick 2.10
import QtQuick.Controls 2.10
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import QtQuick.Layouts 1.3
import QtQml.Models 2.3

import org.maui.station 1.0 as Station

Maui.ApplicationWindow
{
    id: root
    title: currentTab && currentTab.terminal ? currentTab.terminal.session.title : ""
    property alias currentTab : _browserList.currentItem
    readonly property Maui.Terminal currentTerminal : currentTab.terminal

    Maui.App.handleAccounts: false
    Maui.App.description: qsTr("Station is a convergent terminal emulator")
    Maui.App.iconName: "qrc:/station.svg"
    Maui.App.enableCSD: true

    onClosing:
    {
        if(currentTab.terminal.session.hasActiveProcess)
        {
            root.notify("face-ninja", "Process is running", "Are you sure you want to quit?", root.close())
            close.accepted = false
        }
    }

    headBar.leftContent: Label
    {
        Layout.fillWidth: true
        Layout.fillHeight: true
        text : currentTab && currentTab.terminal ? currentTab.terminal.session.title : ""
    }

    headBar.rightContent: [
        ToolButton
        {
            autoExclusive: true
            icon.name: "view-split-left-right"
            onClicked: root.currentTab.split(Qt.Horizontal)
            checked: root.currentTab.orientation === Qt.Horizontal && root.currentTab.count > 1
        },

        ToolButton
        {
            autoExclusive: true
            icon.name: "view-split-top-bottom"
            onClicked: root.currentTab.split(Qt.Vertical)
            checked: root.currentTab.orientation === Qt.Vertical && root.currentTab.count > 1
        },

        ToolButton
        {
            icon.name: "tab-new"
            onClicked: root.openTab("~")
        }
    ]

    Maui.PieButton
    {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: height
        //        radius: Maui.Style.radiusV
        z: 999

        height: Maui.Style.toolBarHeight
        icon.name: "tools"
        icon.color: Kirigami.Theme.highlightedTextColor
        alignment: Qt.AlignLeft

        Action
        {
            icon.name: "edit-copy"
            onTriggered: currentTab.terminal.kterminal.copyClipboard()
        }

        Action
        {
            icon.name: "edit-paste"
            onTriggered: currentTab.terminal.kterminal.pasteClipboard()
        }

        Action
        {
            icon.name: "edit-find"
            onTriggered: currentTab.terminal.findBar.visible = !currentTab.terminal.findBar.visible
        }
    }

    footBar.visible: Maui.Handy.isTouch
    footBar.leftContent:  Repeater
    {
        model: Station.KeysModel
        {
            id: _keysModel
        }

        Button
        {
            text: model.label
            icon.name: model.iconName

            onClicked: _keysModel.sendKey(index, currentTerminal.kterminal)
        }
    }

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

            Repeater
            {
                id: _repeater
                model: tabsObjectModel.count

                Maui.TabButton
                {
                    id: _tabButton
                    implicitHeight: tabsBar.implicitHeight
                    implicitWidth: Math.max(root.width / _repeater.count, 120)
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


        //           Maui.PathBar
        //              {
        //                  //    Kirigami.Theme.backgroundColor:"transparent"
        //                  //    Kirigami.Theme.textColor:c"white"
        //                  Layout.fillWidth: true

        //                  border.color: "transparent"
        //                  radius: 0
        //                  Layout.alignment:Qt.AlignBottom

        //                  url:  currentTab && currentTab.terminal ? currentTab.terminal.title.slice(currentTab.terminal.title.indexOf(":")+1) : ""
        //              }
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

    }
}
