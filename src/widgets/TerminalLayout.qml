import QtQuick 2.14
import QtQuick.Controls 2.14

import org.mauikit.controls 1.3 as Maui

Maui.SplitView
{
    id: control

    height: ListView.view.height
    width:  ListView.view.width

    orientation: width >= 600 ? Qt.Horizontal : Qt.Vertical

    readonly property string title: currentItem.title

    property string path : "$HOME"

    Maui.TabViewInfo.tabTitle: title
    Maui.TabViewInfo.tabToolTipText: currentItem.session.currentDir

    function forceActiveFocus()
    {
        control.currentItem.forceActiveFocus()
    }

    Component
    {
        id: _confirmCloseDialogComponent

        Maui.Dialog
        {
            title: i18n("Close")
            message: i18n("A process is currently still running. Are oyu sure you want to close it?")

            onAccepted: pop()
        }
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
            if(control.currentItem.session.hasActiveProcess)
            {
                _dialogLoader.sourceComponent = _confirmCloseDialogComponent
                dialog.open()
            }else
            {
                pop()
            }

            return
        }//close the innactive split

        control.addSplit(_terminalComponent, {'path': control.path});
    }

    function pop()
    {
        control.closeSplit(control.currentIndex === 1 ? 0 : 1)
    }

    function closeCurrentView()
    {
        control.closeSplit(control.currentIndex)
    }
}
