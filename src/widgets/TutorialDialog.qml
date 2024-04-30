import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.mauikit.controls as Maui

Maui.SettingsDialog
{
    id: control

    Maui.Controls.title: i18n("Shortcuts")

    Maui.SectionGroup
    {
        Layout.fillWidth: true
        title: i18n("Shortcuts")
        description: i18n("When using a keyboard you can use the following shortcuts to navigate.")

        Maui.FlexSectionItem
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

        Maui.FlexSectionItem
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

        Maui.FlexSectionItem
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

        Maui.FlexSectionItem
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

    Maui.SectionGroup
    {
        Layout.fillWidth: true
        title: i18n("Navigation")
        description: i18n("On touch devices you can use the following gestures to navigate.")

        Maui.SectionItem
        {
            label1.text: i18n("Up & Down")
            label2.text: i18n("Swipe up or down to navigate the commands history.")
        }

        Maui.SectionItem
        {
            label1.text: i18n("Left & Right")
            label2.text: i18n("Swipe left or right to move through the command line to edit.")
        }

        Maui.SectionItem
        {
            label1.text: i18n("Two Fingers Left & Right")
            label2.text: i18n("Swipe up or down with two fingers to scroll.")
        }
    }

    Maui.SectionGroup
    {
        Layout.fillWidth: true
        title: i18n("Commands")

        Maui.SectionItem
        {
            label1.text: i18n("Create")
            label2.text: i18n("Create a new command shortcut to quickly trigger actions.")

            Button
            {
                text: i18n("Add")
                onClicked: _shortcutsLoader.item.newCommand()
            }
        }
    }
}
