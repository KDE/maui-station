import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQml 2.14
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.7 as Kirigami
import org.mauikit.controls 1.3 as Maui

import org.maui.station 1.0 as Station

Maui.SettingsDialog
{
    id: control

    Maui.SettingsSection
    {
        title: i18n("Interface")
        description: i18n("Configure the application components and behaviour.")

        Maui.SettingTemplate
        {
            label1.text: i18n("Focus Mode")
            label2.text: i18n("Hides the main header for a distraction free console experience")

            Switch
            {

                checkable: true
                checked: settings.focusMode
                onToggled: settings.focusMode = !settings.focusMode
            }
        }
    }

    Maui.SettingsSection
    {
        title: i18n("Terminal")
        description: i18n("Configure the app UI and plugins.")
        lastOne: true

        Maui.SettingTemplate
        {
            label1.text: i18n("Color Scheme")
            label2.text: i18n("Change the color scheme of the terminal")

            ComboBox
            {
                id: _colorSchemesCombobox
                model: _dummyTerminal.kterminal.availableColorSchemes
                //                currentIndex: _dummyTerminal.kterminal.availableColorSchemes.indexOf(root.colorScheme)
                onActivated:
                {
                    //                    settings.setValue("colorScheme", currentValue)
                    settings.colorScheme = _colorSchemesCombobox.currentValue
                }


                Maui.Terminal
                {
                    id: _dummyTerminal
                    visible: false
                }
            }
        }
    }

    Maui.SettingsSection
    {
        title: i18n("Fonts")
        description: i18n("Configure the terminal font family and size")

        Maui.SettingTemplate
        {
            label1.text:  i18n("Family")

            ComboBox
            {
                Layout.fillWidth: true
                model: Station.Fonts.monospaceFamilies
                Component.onCompleted: currentIndex = find(settings.font.family, Qt.MatchExactly)
                onActivated: settings.font.family = currentText
            }
        }

        Maui.SettingTemplate
        {
            label1.text:  i18n("Size")

            SpinBox
            {
                from: 0; to : 500
                value: settings.font.pointSize
                onValueChanged: settings.font.pointSize = value
            }
        }

        Maui.SettingTemplate
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
