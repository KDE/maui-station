import QtQuick 2.14
import QtQml 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.14 as Kirigami
import org.mauikit.controls 1.3 as Maui

Maui.SplitView
{
    id: control

    height: ListView.view.height
    width:  ListView.view.width

    orientation: width >= 600 ? Qt.Horizontal : Qt.Vertical

    readonly property string title: currentItem.title

    property string path : "~"

    Maui.TabViewInfo.tabTitle: title
    Maui.TabViewInfo.tabToolTipText: currentItem.session.currentDir

    function forceActiveFocus()
    {
        control.currentItem.forceActiveFocus()
    }

    Maui.Dialog
    {
        id: _confirmCloseDialog
        title: i18n("Close")
        message: i18n("A process is currently still running. Are oyu sure you want to close it?")

        onAccepted: pop()
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
                _confirmCloseDialog.open()
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
}
