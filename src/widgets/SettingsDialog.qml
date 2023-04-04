import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.3 as Maui
import org.mauikit.terminal 1.0 as Term

import org.maui.station 1.0 as Station

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

        Maui.SettingsPage
        {
            title: i18n("Color Scheme")
            Maui.SectionItem
            {
                label1.text: i18n("Color Scheme")
                label2.text: i18n("Change the color scheme of the terminal.")
                enabled: !settings.adaptiveColorScheme
                columns: 1

                GridLayout
                {
                    columns: 3
                    Layout.fillWidth: true
                    opacity: enabled ? 1 : 0.5
                    Repeater
                    {
                        model: Term.ColorSchemesModel
                        {
                        }

                        delegate: Maui.GridBrowserDelegate
                        {
                            Layout.fillWidth: true
                            checked: model.name === settings.colorScheme
                            onClicked: settings.colorScheme = model.name

                            template.iconComponent: Control
                            {
                                implicitHeight: Math.max(_layout.implicitHeight + topPadding + bottomPadding, 64)
                                padding: Maui.Style.space.small

                                background: Rectangle
                                {
                                    color: model.background
                                    radius: Maui.Style.radiusV
                                }

                                contentItem: Column
                                {
                                    id:_layout
                                    spacing: 2

                                    Text
                                    {
                                        wrapMode: Text.NoWrap
                                        elide: Text.ElideLeft
                                        width: parent.width
                                        //                                    font.pointSize: Maui.Style.fontSizes.small
                                        text: "Hello world!"
                                        color: model.foreground
                                        font.family: settings.font.family
                                    }

                                    Rectangle
                                    {
                                        radius: 2
                                        height: 8
                                        width: parent.width
                                        color: model.highlight
                                    }

                                    Rectangle
                                    {
                                        radius: 2
                                        height: 8
                                        width: parent.width
                                        color: model.color3
                                    }

                                    Rectangle
                                    {
                                        radius: 2
                                        height: 8
                                        width: parent.width
                                        color: model.color4
                                    }
                                }
                            }

                            label1.text: model.name
                        }
                    }
                }
            }
        }
    }

    Component
    {
        id: _alertsPageComponent

        Maui.SettingsPage
        {
            title: i18n("Alerts")
            Maui.SectionItem
            {
                label1.text: i18n("Running Task")
                label2.text: i18n("Prevent from closing a running task.")

                Switch
                {
                    checked: settings.preventClosing
                    onToggled: settings.preventClosing = ! settings.preventClosing
                }
            }

            Maui.SectionItem
            {
                label1.text: i18n("Finished Task")
                label2.text: i18n("Emit a notificacion when a pending process has finished.")

                Switch
                {
                    checked: settings.alertProcess
                    onToggled: settings.alertProcess = ! settings.alertProcess
                }
            }
        }
    }

    Maui.SectionGroup
    {
        title: i18n("Interface")
        description: i18n("Configure the application components and behaviour.")


        Maui.SectionItem
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

        Maui.SectionItem
        {
            label1.text: i18n("Translucency")
            label2.text: i18n("Level of translucency. Works better if there is blurred background support.")

            columns: 1

            RowLayout
            {
                Layout.fillWidth: true

                Slider
                {
                    id: _opacitySlider
                    Layout.fillWidth: true

                    from: 0
                    to: 100
                    value: (1 - settings.windowOpacity) * 100
                    stepSize: 5
                    snapMode: Slider.SnapAlways

                    onMoved:
                    {
                        settings.windowOpacity = 1 - (value / 100);
                    }
                }

                Label
                {
                    text: i18n("%1\%", _opacitySlider.value)

                }
            }
        }
    }

    Maui.SectionGroup
    {
        title: i18n("Terminal")
        description: i18n("Configure the app UI and plugins.")


        Maui.SectionItem
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

        Maui.SectionItem
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

        Maui.SectionItem
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
        description: i18n("Configure the terminal font and display options.")

        Maui.SectionItem
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

        Maui.SectionItem
        {
            label1.text:  i18n("Line Spacing")

            SpinBox
            {
                from: 0; to : 500
                value: settings.lineSpacing
                onValueChanged: settings.lineSpacing = value
            }
        }

        Maui.SectionItem
        {
            label1.text:  i18n("Enable Bold")

            Switch
            {
               checked: settings.enableBold
               onToggled:  settings.enableBold = !settings.enableBold
            }
        }

        Maui.SectionItem
        {
            label1.text:  i18n("Blinking Cursor")

            Switch
            {
               checked: settings.blinkingCursor
               onToggled:  settings.blinkingCursor = !settings.blinkingCursor
            }
        }

        Maui.SectionItem
        {
            label1.text:  i18n("Full Cursor Height")

            Switch
            {
               checked: settings.fullCursorHeight
               onToggled:  settings.fullCursorHeight = !settings.fullCursorHeight
            }
        }

        Maui.SectionItem
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
