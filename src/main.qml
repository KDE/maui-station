import QtQuick
import QtCore

import QtQuick.Controls
import QtQuick.Layouts

import org.mauikit.controls as Maui
import org.mauikit.terminal as Term
import org.mauikit.filebrowsing as FB

import org.maui.station as Station

import "widgets"

Maui.ApplicationWindow
{
    id: root

    Maui.Style.styleType: settings.colorStyle

    title: currentTerminal? currentTerminal.session.title : ""

    readonly property alias currentTab : _layout.currentItem

    readonly property Term.Terminal currentTerminal : currentTab.currentItem.terminal
    readonly property font defaultFont : Maui.Style.monospacedFont
    readonly property alias currentTabIndex : _layout.currentIndex

    Maui.WindowBlur
    {
        view: root
        geometry: Qt.rect(root.x, root.y, root.width, root.height)
        windowRadius: Maui.Style.radiusV
        enabled: !Maui.Handy.isMobile && settings.windowTranslucency
    }

    property bool discard : !settings.preventClosing
    onClosing: (close) =>
               {
                   close.accepted = !settings.restoreSession
                   root.saveSession()

                   if(anyTabHasActiveProcess() && !root.discard)
                   {
                       openCloseDialog(-1, ()=> {root.discard = true; root.close();})
                       close.accepted = false
                       return
                   }

                   close.accepted = true
               }


    Settings
    {
        id: settings
        property string colorScheme: "Maui-Dark"

        property int lineSpacing : 0
        property int historySize : -1

        property font font : defaultFont
        property int keysModelCurrentIndex : 4
        property int colorStyle : Maui.Style.Dark

        property double windowOpacity: 0.8
        property bool windowTranslucency: false

        property bool adaptiveColorScheme : true
        property bool preventClosing: true
        property bool alertProcess: true

        property bool enableBold: true
        property bool blinkingCursor: true
        property bool fullCursorHeight: true
        property bool antialiasText: true

        property bool showSignalBar: false
        property bool watchForSilence: false

        property bool restoreSession : false
        property var lastSession: []
        property int lastTabIndex : 0
        property int tabTitleStyle: Terminal.TabTitle.Auto

        property bool enableSideBar : true
    }

    Component
    {
        id: _tutorialDialogComponent
        TutorialDialog
        {
            onClosed: destroy()
        }
    }

    Component
    {
        id: _settingsDialogComponent
        SettingsDialog
        {
            onClosed: destroy()
        }
    }

    Maui.SideBarView
    {
        id: _sideBarView
        anchors.fill: parent

        sideBar.autoShow: false
        sideBar.autoHide: true
        sideBar.collapsed: !root.isWide

        background: Rectangle
        {
            color: currentTerminal.kterminal.backgroundColor
            opacity: _layout.count === 0 ? 1 : (settings.windowTranslucency ? settings.windowOpacity : 1)
        }

        sideBarContent: Loader
        {
            anchors.fill: parent
            anchors.margins: Maui.Style.defaultPadding

            active: settings.enableSideBar || item
            asynchronous: true
            sourceComponent: Maui.Page
            {
                background: Rectangle
                {
                    color: Maui.Theme.backgroundColor
                    radius: Maui.Style.radiusV
                    opacity: _layout.count === 0 ? 1 : (settings.windowTranslucency ? settings.windowOpacity : 1)
                }

                headerMargins: Maui.Style.defaultPadding
                headBar.middleContent: Maui.ToolActions
                {
                    autoExclusive: true
                    Layout.alignment: Qt.AlignHCenter
                    display: ToolButton.IconOnly

                    Action
                    {
                        text: i18n("Commands")
                        icon.name: "terminal-symbolic"
                        checked: _swipeView.currentIndex === 0
                        onTriggered: _swipeView.setCurrentIndex(0)
                    }

                    Action
                    {
                        text: i18n("Bookmarks")
                        icon.name:"folder"
                        checked: _swipeView.currentIndex === 1
                        onTriggered: _swipeView.setCurrentIndex(1)

                    }
                }

                SwipeView
                {
                    id: _swipeView
                    anchors.fill: parent
                    background: null

                    Maui.SwipeViewLoader
                    {
                        CommandShortcuts
                        {
                            background: null
                            onCommandTriggered: (command, autorun) =>
                                                {
                                                    root.currentTerminal.session.sendText("\x05\x15")

                                                    root.currentTerminal.session.sendText(command)

                                                    if(autorun)
                                                    {
                                                        root.currentTerminal.session.sendText("\r")
                                                    }

                                                    if(_sideBarView.sideBar.peeking)
                                                    {
                                                        _sideBarView.sideBar.close()
                                                    }

                                                    root.currentTerminal.forceActiveFocus()
                                                }
                        }
                    }

                    Maui.Page
                    {
                        id: _bookmarksPage
                        headBar.visible: false
                        background: null

                        FB.PlacesListBrowser
                        {
                            currentPath:  "file://"+root.currentTerminal.session.currentDir

                            anchors.fill: parent
                            onPlaceClicked:  (path) =>
                                             {
                                                 root.currentTerminal.session.changeDir(path.replace("file://", ""))

                                                 // root.currentTerminal.forceActiveFocus()
                                             }
                        }
                    }
                }
            }
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
                clip: true
                background: null
                altTabBar: Maui.Handy.isMobile
                Maui.Controls.showCSD: true

                anchors.fill: parent

                onNewTabClicked: root.openTab("$PWD")
                onCloseTabClicked:(index) => root.closeTab(index)

                tabBarMargins: Maui.Style.defaultPadding
                tabBar.showNewTabButton: false
                tabBar.visible: true
                tabBar.background: Rectangle
                {
                    color: Maui.Theme.backgroundColor
                    opacity: settings.windowTranslucency ? settings.windowOpacity : 1
                    radius: Maui.Style.radiusV
                }

                tabBar.leftContent: Loader
                {
                    active: settings.enableSideBar
                    asynchronous: true
                    sourceComponent: ToolButton
                    {
                        icon.name: "document-edit"
                        checked: _sideBarView.sideBar.visible
                        onClicked: _sideBarView.sideBar.toggle()
                    }
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
                            action: Action
                            {
                                shortcut: "Ctrl+Shift+T"
                            }
                        }

                        MenuItem
                        {
                            enabled: root.currentTab
                            checked: root.currentTab && root.currentTab.count === 2
                            checkable: true
                            text: i18n("Split")

                            icon.name: root.currentTab.orientation === Qt.Horizontal ? "view-split-left-right" : "view-split-top-bottom"
                            onTriggered: root.currentTab.split()
                            action: Action
                            {
                                shortcut: "Ctrl+Shift+→"
                            }
                        }

                        MenuSeparator {}

                        MenuItem
                        {
                            text: i18n("Tutorial")
                            onTriggered:
                            {
                                var dialog = _tutorialDialogComponent.createObject(root)
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
                                var dialog = _settingsDialogComponent.createObject(root)
                                dialog.open()
                            }
                        }

                        MenuItem
                        {
                            text: i18n("About")
                            icon.name: "documentinfo"
                            onTriggered: Maui.App.aboutDialog()
                        }
                    }
                ]

                holder.visible: _layout.count === 0
                holder.emoji: "terminal-symbolic"
                holder.title: i18n("Nothing here")
                holder.body: i18n("To start hacking open a new tab or a split screen.")
                holder.actions: Action
                {
                    text: i18n("New Tab")
                    onTriggered: root.openTab("$PWD")
                }
            }

            footBar.visible: Maui.Handy.isMobile || Maui.Handy.isTouch

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
                        onTriggered: settings.keysModelCurrentIndex = 2
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

                    MenuItem
                    {
                        text: i18n("Signals")
                        autoExclusive: true
                        checked: settings.keysModelCurrentIndex === 5
                        checkable: true
                        onTriggered: settings.keysModelCurrentIndex = 5
                    }

                    MenuSeparator {}

                    MenuItem
                    {
                        text: i18n("More Signals")
                        checked: settings.showSignalBar
                        checkable: true
                        onTriggered: settings.showSignalBar = !settings.showSignalBar
                    }
                }
            }

            footerColumn: Maui.ToolBar
            {
                visible: settings.showSignalBar
                width: parent.width
                position: ToolBar.Footer

                Repeater
                {
                    model: _keysModel.signalsGroup

                    delegate:  Button
                    {
                        font.bold: true
                        text: modelData.label + "/ " + modelData.signal

                        onClicked: currentTerminal.session.sendSignal(9)

                        activeFocusOnTab: false
                        focusPolicy: Qt.NoFocus
                        autoRepeat: true
                    }
                }
            }

            footBar.leftContent: [
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
    }

    Component
    {
        id: _terminalComponent
        TerminalLayout {}
    }

    Component
    {
        id:  _confirmCloseDialogComponent
        Maui.InfoDialog
        {
            id : _confirmCloseDialog

            property var cb : ({})
            property int index: -1

            // title: i18n("Close")
            message: i18n("A process is still running. Are you sure you want to interrupt it and close it?")

            template.iconSource: "dialog-warning"
            template.iconVisible: true
            template.iconSizeHint: Maui.Style.iconSizes.huge

            standardButtons: Dialog.Ok | Dialog.Cancel

            onAccepted:
            {
                _confirmCloseDialog.close()

                if(cb instanceof Function)
                {
                    cb(index)
                }

            }

            onRejected:
            {
                close()
            }
        }
    }

    Component
    {
        id: _restoreDialogComponent
        Maui.InfoDialog
        {
            message: i18n("Do you want to restore the previous session?")
            standardButtons: Dialog.Ok | Dialog.Cancel
            template.iconSource: "dialog-question"
            onClosed: destroy()
            onAccepted:
            {
                const tabs = settings.lastSession
                if(tabs.length)
                {
                    console.log("restore", tabs.length)
                    // root.closeTab(0)
                    restoreSession(tabs)
                    return
                }
            }
        }
    }

    Component.onCompleted:
    {
        if(settings.restoreSession)
        {
            var dialog = _restoreDialogComponent.createObject(root)
            dialog.open()
            return
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
            openCloseDialog(index, _layout.closeTab)
            return
        }

        _layout.closeTab(index)
    }

    function anyTabHasActiveProcess()
    {
        for(var i = 0; i < _layout.count; i++)
        {
            let tab = _layout.tabAt(i)
            if(tab && tab.hasActiveProcess)
            {
                return true
            }
        }

        return false
    }

    function saveSession()
    {
        var tabs = [];

        for(var i = 0; i < _layout.count; i ++)
        {
            var tab = _layout.contentModel.get(i)
            var tabPaths = []

            for(var j = 0; j < tab.count; j ++)
            {
                const term = tab.contentModel.get(j)
                var path = String(term.session.currentDir)
                const tabMap = {'path': path}

                tabPaths.push(tabMap)
            }

            tabs.push(tabPaths)
        }

        settings.lastSession = tabs
        console.log("Saving Session", settings.lastSession.length)

        // settings.lastTabIndex = currentTabIndex
    }

    function restoreSession(tabs)
    {
        console.log("TRYING TO RESTORE SESSION",tabs )


        for(var i = 0; i < tabs.length; i++ )
        {
            const tab = tabs[i]

            if(tab.length === 2)
            {
                root.openTab(tab[0].path, tab[1].path)
            }else
            {
                console.log("TRYING TO RESTORE SESSION", tab[0].path)
                root.openTab(tab[0].path)
            }
        }

        // currentTabIndex = settings.lastTabIndex
    }

    function openCloseDialog(index, cb)
    {
        var props = ({
                         'index' : index,
                         'cb' : cb
                     })
        var dialog = _confirmCloseDialogComponent.createObject(root, props)
        dialog.open()
    }
}
