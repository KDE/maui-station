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
        id:_csPageComponent

        Maui.SettingsPage
        {
             title: i18n("Color Scheme")
            Maui.SectionItem
            {
                label1.text: i18n("Color Scheme")
                label2.text: i18n("Change the color scheme of the terminal.")
                enabled: !settings.adaptiveColorScheme

                GridLayout
                {
                    columns: 3
                    width: parent.parent.width
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

                            template.iconComponent: Pane
                            {
                                implicitHeight: Math.max(contentHeight + topPadding + bottomPadding, 64)
                                padding: Maui.Style.space.small

                                background: Rectangle
                                {
                                    color: model.background
                                    radius: Maui.Style.radiusV
                                }

                                contentItem: Column
                                {
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

            RowLayout
            {
                width: parent.parent.width

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
                Layout.fillHeight: true
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
            //onClicked: control.addPage(_csPageComponent)

            ToolButton
            {
                checkable: true
                icon.name: "go-next"
                onToggled: control.addPage(_csPageComponent)
            }
        }
    }

    Maui.SectionGroup
    {
        title: i18n("Fonts")
        description: i18n("Configure the terminal font family and size.")

        Maui.SectionItem
        {
            label1.text:  i18n("Family")

            Maui.FontsComboBox
            {
                Layout.fillWidth: true
                model: Station.Fonts.monospaceFamilies
                Component.onCompleted: currentIndex = find(settings.font.family, Qt.MatchExactly)
                onActivated: settings.font.family = currentText
            }
        }

        Maui.SectionItem
        {
            label1.text:  i18n("Size")

            SpinBox
            {
                from: 0; to : 500
                value: settings.font.pointSize
                onValueChanged: settings.font.pointSize = value
            }
        }

        Maui.SectionItem
        {
            label1.text:  i18n("Line Spacing")

            SpinBox
            {
                from: 0; to : 500
                value: settings.tabSpace
                onValueChanged: settings.lineSpacing = value
            }
        }
    }
}
