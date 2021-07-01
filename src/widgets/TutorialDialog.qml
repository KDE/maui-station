import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

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
        title: i18n("Shortcuts")
        description: i18n("When using a keyboard you can use the following shortcuts to navigate.")

        Maui.SettingTemplate
        {
            label1.text: i18n("Split")
            label2.text: i18n("Open a new split view, vertically or horizontally.")

            Maui.ToolActions
            {
                checkable: false
                autoExclusive: false
                Action
                {
                    text: "↑"
                }

                Action
                {
                    text: "Ctrl"
                }

                Action
                {
                    text: "Shift"
                }
            }
        }

        Maui.SettingTemplate
        {
            label1.text: i18n("New Tab")

            Maui.ToolActions
            {
                checkable: false
                autoExclusive: false
                Action
                {
                    text: "Ctrl"
                }

                Action
                {
                    text: "T"
                }
            }
        }

        Maui.SettingTemplate
        {
            label1.text: i18n("Find")
            label2.text: i18n("Open the find bar.")

            Maui.ToolActions
            {
                checkable: false
                autoExclusive: false
                Action
                {
                    text: "Ctrl"
                }

                Action
                {
                    text: "F"
                }
            }
        }

        Maui.SettingTemplate
        {
            label1.text: i18n("Switch")
            label2.text: i18n("Switch between split views.")

            Maui.ToolActions
            {
                checkable: false
                autoExclusive: false
                Action
                {
                    text: "Tab"
                }

                Action
                {
                    text: "Ctrl"
                }
            }
        }
    }

    Maui.SettingsSection
    {
        Layout.fillWidth: true
        title: i18n("Navigation")
        description: i18n("On touch devices you can use the following gestures to navigate.")

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
        title: i18n("Commands")

        Maui.SettingTemplate
        {
            label1.text: i18n("Create")
            label2.text: i18n("Create a new command shorcut to quickly trigger actions.")

            Button
            {
                text: i18n("Add")
                onClicked: _shortcuts.newCommand()
            }
        }
    }
}
