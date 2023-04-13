import QtQuick 2.14
import QtQuick.Controls 2.14

import org.mauikit.controls 1.3 as Maui

Maui.SplitView
{
    id: control

    orientation: width >= 600 ? Qt.Horizontal : Qt.Vertical

    property string path : "$PWD"

    readonly property bool hasActiveProcess : count === 2 ?  contentModel.get(0).session.hasActiveProcess || contentModel.get(1).session.hasActiveProcess : currentItem.session.hasActiveProcess
readonly property bool isCurrentTab : SwipeView.isCurrentItem

        readonly property string title : count === 2 ?  contentModel.get(0).title  + " - " + contentModel.get(1).title : currentItem.title

    Maui.TabViewInfo.tabTitle: title
    Maui.TabViewInfo.tabToolTipText: currentItem.session.currentDir
    Maui.TabViewInfo.tabColor: control.hasActiveProcess ? Maui.Theme.neutralBackgroundColor : "transparent"
    Maui.TabViewInfo.tabIcon: control.hasActiveProcess ? "indicator-messages" : ""

    onHasActiveProcessChanged:
    {
        if(!control.isCurrentTab && settings.alertProcess)
        {
            root.notify("dialog-warning", i18n("Process Finished"), i18n("Running task has finished for tab: %1", control.title), ()=>{_layout.setCurrentIndex(control.SwipeView.index)}, i18n("Check"))
        }
    }

    function forceActiveFocus()
    {
        control.currentItem.forceActiveFocus()
    }

    Component
    {
        id: _terminalComponent
        Terminal{}
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
