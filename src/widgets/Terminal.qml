import QtQuick
import QtQuick.Controls

import org.mauikit.controls as Maui
import org.mauikit.terminal as Term

import org.maui.station as Station

Maui.SplitViewItem
{
    id: control
    Maui.Controls.title: title
    Maui.Controls.badgeText: hasActiveProcess ? "!" : ""

    readonly property bool hasActiveProcess : session.hasActiveProcess

    property string path : "$HOME"

    function forceActiveFocus()
    {
        control.kterminal.forceActiveFocus()
    }

    enum TabTitle
    {
        ProcessName,
        WorkingDirectory,
        Auto
    }

    readonly property alias terminal : _terminal
    readonly property alias session : _terminal.session
    readonly property string title : switch(settings.tabTitleStyle)
                                     {
                                     case Terminal.TabTitle.ProcessName : return _terminal.session.foregroundProcessName
                                     case Terminal.TabTitle.WorkingDirectory : return _terminal.session.currentDir
                                     case Terminal.TabTitle.Auto : return terminal.title
                                     }
    readonly property alias kterminal : _terminal.kterminal

    property color tabColor : session.foregroundProcessName.startsWith("sudo") ? "red" : "transparent"

    property bool watchForSlience : false

    signal silenceWarning()

    background: null

    Term.Terminal
    {
        id: _terminal
        background: null

        anchors.fill: parent

        session.initialWorkingDirectory : control.path
        session.historySize: settings.historySize
        session.monitorSilence: control.watchForSlience

        onUrlsDropped: (urls) =>
                       {
                           for(var i in urls)
                           control.session.sendText((urls[i]).toString().replace("file://", "")+ " ")
                       }

        kterminal.font: settings.font
        kterminal.colorScheme: settings.adaptiveColorScheme ? "Adaptive" : settings.colorScheme
        kterminal.lineSpacing: settings.lineSpacing
        kterminal.backgroundOpacity: settings.windowTranslucency ? 0 : 1

        kterminal.enableBold : settings.enableBold
        kterminal.blinkingCursor : settings.blinkingCursor
        kterminal.fullCursorHeight : settings.fullCursorHeight
        kterminal.antialiasText : settings.antialiasText

        menu: [

            MenuSeparator{},

            MenuItem
            {
                text: i18n("Open Current Location")
                icon.name: "folder"
                onTriggered: Qt.openUrlExternally("file://"+session.currentDir)
            },

            MenuSeparator{},

            MenuItem
            {
                readonly property string url: kterminal.isTextSelected && visible ? parseUrl() : ""
                enabled: Station.Station.isValidUrl(url) && kterminal.isTextSelected
                // visible: enabled
                height: visible ? implicitHeight : -Maui.Style.defaultSpacing
                text: "Open Link"
                icon.name: "quickopen"

                function parseUrl() : string
                {
                    console.log("parsing url", Station.Station.resolveUrl(kterminal.selectedText(), session.currentDir))
                    return Station.Station.resolveUrl(kterminal.selectedText(), session.currentDir)
                }

                onTriggered:
                {
                    Qt.openUrlExternally(url)
                }
            },

            MenuItem
            {
                enabled: kterminal.isTextSelected && Maui.Handy.isEmail(kterminal.selectedText())
                visible: enabled
                height: visible ? implicitHeight : -Maui.Style.defaultSpacing
                text: i18n("Email")
                icon.name: "mail"
                onTriggered: Qt.openUrlExternally("mailto="+kterminal.selectedText())
            },

            MenuItem
            {
                enabled: kterminal.isTextSelected
                visible: enabled
                height: visible ? implicitHeight : -Maui.Style.defaultSpacing
                text: i18n("Search Web")
                icon.name: "webpage-symbolic"
                onTriggered: Qt.openUrlExternally("https://www.google.com/search?q="+kterminal.selectedText())
            },

            MenuSeparator{},

            MenuItem
            {
                enabled: !settings.watchForSilence
                text: i18n("Watch for Silence")
                checkable: true
                checked: control.watchForSlience
                icon.name: "notifications"
                onTriggered:
                {
                    control.watchForSlience = !control.watchForSlience
                }
            }
        ]

        onKeyPressed: (event) =>
                      {
                          if ((event.key == Qt.Key_Tab) && (event.modifiers & Qt.ControlModifier)  && (event.modifiers & Qt.ShiftModifier))
                          {
                              control.SplitView.view.incrementCurrentIndex();
                              currentTerminal.forceActiveFocus()
                              event.accepted = true
                              return
                          }

                          if ((event.key == Qt.Key_Right) && (event.modifiers & Qt.ControlModifier) && (event.modifiers & Qt.ShiftModifier))
                          {
                              split()
                              event.accepted = true
                              return
                          }

                          if ((event.key == Qt.Key_T) && (event.modifiers & Qt.ControlModifier) && (event.modifiers & Qt.ShiftModifier))
                          {
                              root.openTab("$PWD")
                              event.accepted = true
                              return
                          }
                      }

        Connections
        {
            target: _terminal.session

            function onBellRequest(message)
            {
                console.log("Bell REQUESTED!!!", message);
            }

            function onProcessHasSilent(value)
            {
                if(control.watchForSlience && value && control.session.hasActiveProcess )
                    control.silenceWarning()
            }

            function onForegroundProcessNameChanged()
            {
                var process = control.session.foregroundProcessName

                switch (process)
                {
                case "nano" : settings.keysModelCurrentIndex = 1; break;
                case "htop" : settings.keysModelCurrentIndex = 0; break;
                }
            }

            function onFinished()
            {
                console.log("ASKED TO CLOSE SESSION")
                if(currentTab.count === 1)
                {
                    closeTab(currentTabIndex)
                }else
                {
                    closeSplit()
                }
            }
        }
    }
}
