import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import QtQml.Models 2.3
import Qt.labs.settings 1.0

import org.kde.kirigami 2.7 as Kirigami
import org.mauikit.controls 1.2 as Maui

Maui.SettingsDialog
{
    id: control

    persistent: false

    page.showTitle: false
    headBar.visible: false

    Maui.SettingsSection
    {
        Layout.fillWidth: true
        title: i18n("Navigation")

        Maui.SettingTemplate
        {
            label1.text: i18n("Up & Down")
            label2.text: i18n("Swipe up or down to navigate the commands history.")
        }

        Maui.SettingTemplate
        {
            label1.text: i18n("Left & Right")
            label2.text: i18n("Swipe left or right to move through the command line to edit.")
        }

        Maui.SettingTemplate
        {
            label1.text: i18n("Two Fingers Left & Right")
            label2.text: i18n("Swipe up or down with two fingers to scroll.")
        }
    }

    Maui.SettingsSection
    {
        Layout.fillWidth: true
        title: i18n("Shortcuts")

        Maui.SettingTemplate
        {
            label1.text: i18n("Up & Down")
            label2.text: i18n("Swipe up or down to navigate the commands history.")
        }

        Maui.SettingTemplate
        {
            label1.text: i18n("Left & Right")
            label2.text: i18n("Swipe left or right to move through the command line to edit.")


        }
    }

    Maui.SettingsSection
    {
        Layout.fillWidth: true
        title: i18n("Commands")

        Maui.SettingTemplate
        {
            label1.text: i18n("Create")
            label2.text: i18n("Create a new command shorcut to quickly trigger actions.")


        }

        Maui.SettingTemplate
        {
            label1.text: i18n("Left & Right")
            label2.text: i18n("Swipe left or right to move through the command line to edit.")


        }
    }
}
