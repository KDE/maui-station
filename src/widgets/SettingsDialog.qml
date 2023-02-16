import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.3 as Maui
import org.mauikit.terminal 1.0 as Term

import org.maui.station 1.0 as Station

Maui.SettingsDialog
{
    id: control

    Maui.SectionGroup
    {
        title: i18n("Interface")
        description: i18n("Configure the application components and behaviour.")


        Maui.SectionItem
        {
            label1.text: i18n("Color")
            label2.text: i18n("Switch between light and dark colorscheme")

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

                //                Action
                //                {
                //                    text: i18n("System")
                //                    onTriggered:
                //                    {
                //                        Maui.Style.styleType = undefined
                //                        settings.colorStyle = Maui.Style.styleType
                //                    }

                //                    checked: Maui.Style.styleType === 'undefined'
                //                }

                Action
                {
                    text: i18n("Adaptive")
                    onTriggered:
                    {
                        settings.colorStyle = Maui.Style.Adaptive
                    }

                    checked: settings.colorStyle === Maui.Style.Adaptive
                }
            }
        }

        Maui.SectionItem
        {
            label1.text: i18n("Opacity")
            label2.text: i18n("Background opacity")

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
            label1.text: i18n("Color Scheme")
            label2.text: i18n("Change the color scheme of the terminal")

            ComboBox
            {
                id: _colorSchemesCombobox

                textRole: "name"
                valueRole: "name"

                model: Maui.BaseModel
                {
                    list: Term.ColorSchemesModel
                    {
                    }
                }
                Component.onCompleted: currentIndex = indexOfValue(settings.colorScheme)
                onActivated:
                {
                    //                    settings.setValue("colorScheme", currentValue)
                    settings.colorScheme = _colorSchemesCombobox.currentValue
                }



            }
        }
    }

    Maui.SectionGroup
    {
        title: i18n("Fonts")
        description: i18n("Configure the terminal font family and size")

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
