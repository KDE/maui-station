import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.mauikit.controls as Maui
import org.mauikit.terminal as Term

import org.maui.station as Station

Maui.SettingsDialog
{
    id: control

    Component
    {
        id:_fontPageComponent

        Maui.SettingsPage
        {
            title: i18n("Font")

            Maui.FontPicker
            {
                Layout.fillWidth: true

                mfont: settings.font
                model.onlyMonospaced: true

                onFontModified:
                {
                    settings.font = font
                }
            }
        }
    }

    Component
    {
        id:_csPageComponent
        
        Term.ColorSchemesPage
        {
            currentColorScheme: settings.colorScheme
            enabled: !settings.adaptiveColorScheme
            
            onCurrentColorSchemeChanged: settings.colorScheme = currentColorScheme
        }
    }

    Component
    {
        id: _alertsPageComponent

        Maui.SettingsPage
        {
            title: i18n("Alerts")

            Maui.FlexSectionItem
            {
                label1.text: i18n("Running Task")
                label2.text: i18n("Prevent from closing a running task.")

                Switch
                {
                    checked: settings.preventClosing
                    onToggled: settings.preventClosing = ! settings.preventClosing
                }
            }

            Maui.FlexSectionItem
            {
                label1.text: i18n("Finished Task")
                label2.text: i18n("Emit a notification when a pending process has finished.")

                Switch
                {
                    checked: settings.alertProcess
                    onToggled: settings.alertProcess = ! settings.alertProcess
                }
            }

            Maui.FlexSectionItem
            {
                label1.text: i18n("Silent")
                label2.text: i18n("Emit an alert when a running task has been silent for more than 30 seconds.")

                Switch
                {
                    checked: settings.watchForSilence
                    onToggled: settings.watchForSilence = ! settings.watchForSilence
                }
            }
        }
    }

    Maui.SectionGroup
    {
        title: i18n("Interface")
//        description: i18n("Configure the application components and behaviour.")

        Maui.FlexSectionItem
        {
            label1.text: i18n("Color")
            label2.text: i18n("Switch between light and dark colorscheme.")

            Maui.ToolActions
            {
                autoExclusive: true

                Action
                {
                    text: i18n("Light")
                    onTriggered: settings.colorStyle = Maui.Style.Light
                    checked: settings.colorStyle === Maui.Style.Light
                }

                Action
                {
                    text: i18n("Dark")
                    onTriggered: settings.colorStyle = Maui.Style.Dark
                    checked: settings.colorStyle === Maui.Style.Dark
                }


                Action
                {
                    text: i18n("Adaptive")
                    onTriggered:
                    {
                        settings.colorStyle = Maui.Style.Adaptive
                    }

                    checked: settings.colorStyle === Maui.Style.Adaptive
                }/*

                Action
                {
                    text: i18n("System")
                    onTriggered:
                    {
                        settings.colorStyle = undefined
                    }

                    checked: Maui.Style.styleType === 'undefined'
                }*/
            }
        }

        Maui.FlexSectionItem
        {
            label1.text: i18n("Shortcuts")
            label2.text: i18n("Enable the sidebar with commands and places shortcuts.")

            Switch
            {
                checked: settings.enableSideBar
                onToggled: settings.enableSideBar = !settings.enableSideBar
            }
        }

        Maui.FlexSectionItem
        {
            label1.text: i18n("Translucency")
            label2.text: i18n("Translucent background.")

            Switch
            {
                checked: settings.windowTranslucency
                onToggled: settings.windowTranslucency = !settings.windowTranslucency
            }
        }

        Maui.FlexSectionItem
        {
            label1.text: i18n("Tab Title")

            Maui.ToolActions
            {
                autoExclusive: true

                Action
                {
                    text: i18n("Auto")
                    onTriggered: settings.tabTitleStyle = Terminal.TabTitle.Auto
                    checked: settings.tabTitleStyle === Terminal.TabTitle.Auto
                }

                Action
                {
                    text: i18n("Process")
                    onTriggered: settings.tabTitleStyle = Terminal.TabTitle.ProcessName
                    checked: settings.tabTitleStyle === Terminal.TabTitle.ProcessName
                }

                Action
                {
                    text: i18n("Directory")
                    onTriggered: settings.tabTitleStyle = Terminal.TabTitle.WorkingDirectory
                    checked: settings.tabTitleStyle === Terminal.TabTitle.WorkingDirectory
                }
            }
        }
    }

    Maui.SectionGroup
    {
        title: i18n("Terminal")
//        description: i18n("Configure the app UI and plugins.")

        Maui.FlexSectionItem
        {
            label1.text: i18n("Save Session")
            label2.text: i18n("Restore previous session on startup.")

            Switch
            {
                checkable: true
                checked:  settings.restoreSession
                onToggled: settings.restoreSession = ! settings.restoreSession
            }

        }

        Maui.FlexSectionItem
        {
            label1.text: i18n("Adaptive Color Scheme")
            label2.text: i18n("Colors based on the current style.")

            Switch
            {
                checkable: true
                checked:  settings.adaptiveColorScheme
                onToggled: settings.adaptiveColorScheme = ! settings.adaptiveColorScheme
            }

        }

        Maui.FlexSectionItem
        {
            label1.text: i18n("Color Scheme")
            label2.text: i18n("Change the color scheme of the terminal.")
            enabled: !settings.adaptiveColorScheme

            ToolButton
            {
                checkable: true
                icon.name: "go-next"
                onToggled: control.addPage(_csPageComponent)
            }
        }

        Maui.FlexSectionItem
        {
            label1.text: i18n("Alerts")
            label2.text: i18n("Alert on processes and prevent closing them.")

            ToolButton
            {
                checkable: true
                icon.name: "go-next"
                onToggled: control.addPage(_alertsPageComponent)
            }
        }
    }

    Maui.SectionGroup
    {
        title: i18n("Display")
//        description: i18n("Configure the terminal font and display options.")

        Maui.FlexSectionItem
        {
            label1.text: i18n("Font")
            label2.text: i18n("Font family and size.")

            ToolButton
            {
                checkable: true
                icon.name: "go-next"
                onToggled: control.addPage(_fontPageComponent)
            }
        }

        Maui.FlexSectionItem
        {
            label1.text:  i18n("Line Spacing")

            SpinBox
            {
                from: 0; to : 500
                value: settings.lineSpacing
                onValueChanged: settings.lineSpacing = value
            }
        }

        Maui.FlexSectionItem
        {
            label1.text:  i18n("History Size")
            label2.text: i18n("Number of lines to keep in buffer. Less than zero means infinite lines.")

            SpinBox
            {
                from: -1; to : 9999
                value: settings.historySize
                onValueChanged: settings.historySize = value
            }
        }

        Maui.FlexSectionItem
        {
            label1.text:  i18n("Enable Bold")

            Switch
            {
               checked: settings.enableBold
               onToggled:  settings.enableBold = !settings.enableBold
            }
        }

        Maui.FlexSectionItem
        {
            label1.text:  i18n("Blinking Cursor")

            Switch
            {
               checked: settings.blinkingCursor
               onToggled:  settings.blinkingCursor = !settings.blinkingCursor
            }
        }

        Maui.FlexSectionItem
        {
            label1.text:  i18n("Full Cursor Height")

            Switch
            {
               checked: settings.fullCursorHeight
               onToggled:  settings.fullCursorHeight = !settings.fullCursorHeight
            }
        }

        Maui.FlexSectionItem
        {
            label1.text:  i18n("Antialias text")

            Switch
            {
               checked: settings.antialiasText
               onToggled:  settings.antialiasText = !settings.antialiasText
            }
        }
    }
}
