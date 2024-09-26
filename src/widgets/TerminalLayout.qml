import QtQuick
import QtQuick.Controls

import org.mauikit.controls as Maui

Maui.SplitView
{
    id: control

    orientation: width >= 600 ? Qt.Horizontal : Qt.Vertical

    property string path : "$PWD"

    readonly property bool hasActiveProcess : count === 2 ?  contentModel.get(0).hasActiveProcess || contentModel.get(1).hasActiveProcess : currentItem.hasActiveProcess

    readonly property bool isCurrentTab : SwipeView.isCurrentItem

    readonly property string title : count === 2 ?  contentModel.get(0).title  + " - " + contentModel.get(1).title : currentItem.title

    Maui.Controls.title: title
    Maui.Controls.toolTipText: currentItem.session.currentDir
    Maui.Controls.color: currentItem.tabColor
    Maui.Controls.iconName: control.hasActiveProcess ? "run-build" : ""

    Action
    {
        id: _reviewAction
        text: i18n("View")
        onTriggered:
        {
            _layout.setCurrentIndex(control.SwipeView.index)
        }
    }

    onHasActiveProcessChanged:
    {
        if(!control.isCurrentTab && settings.alertProcess)
        {
            root.notify("dialog-warning", i18n("Process Finished"), i18n("Running task has finished for tab: %1", control.title), [_reviewAction])
        }
    }

    function forceActiveFocus()
    {
        control.currentItem.forceActiveFocus()
    }

    Component
    {
        id: _terminalComponent

        Terminal
        {
            watchForSlience: settings.watchForSilence
            onSilenceWarning:
            {
                if(!control.isCurrentTab)
                {
                    root.notify("dialog-warning", i18n("Pending Process"), i18n("Running process '%1' has been inactive for more than 30 seconds.", title), [_reviewAction])
                }
            }
        }
    }

    Component.onCompleted: split()

    function split()
    {
        if(control.count === 2)
        {
            pop()
            return
        }//close the innactive split

        control.addSplit(_terminalComponent, {'path': control.path});
    }

    function pop()
    {
        var index = control.currentIndex === 1 ? 0 : 1
        if(control.contentModel.get(index).session.hasActiveProcess && settings.preventClosing)
        {
            _dialogLoader.sourceComponent = _confirmCloseDialogComponent
            dialog.index = index
            dialog.cb = control.closeSplit
            dialog.open()
        }else
        {
            control.closeSplit(index)
        }
    }

    function closeCurrentView()
    {
        control.closeSplit(control.currentIndex)
    }
}
