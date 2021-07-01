import QtQuick 2.14
import QtQuick.Controls 2.14

import org.mauikit.controls 1.3 as Maui
import org.kde.kirigami 2.4 as Kirigami

Maui.SplitViewItem
{
    id: control

    property string path : "$HOME"

    function forceActiveFocus()
    {
        control.kterminal.forceActiveFocus()
    }

    property alias terminal : _terminal
    property alias session : _terminal.session
    property alias title : _terminal.title
    property alias kterminal : _terminal.kterminal

    Maui.Terminal
    {
        id: _terminal

        anchors.fill: parent
        session.initialWorkingDirectory : control.path
//        Component.onCompleted:
//        {
//            control.session.initialWorkingDirectory = control.path
//            control.session.sendText("cd "+ control.path + "\n")
//        }

        //    onClicked:
        //    {
        //        SplitView.view.currentIndex = control._index
        //    }

        onUrlsDropped:
        {
            for(var i in urls)
                control.session.sendText(urls[i].replace("file://", "")+ " ")
        }

        kterminal.font: settings.font
        kterminal.colorScheme: settings.colorScheme
        kterminal.lineSpacing: settings.lineSpacing

        onKeyPressed:
        {
            if ((event.key == Qt.Key_Tab) && (event.modifiers & Qt.ControlModifier))
            {
                control.SplitView.view.incrementCurrentIndex();
                currentTerminal.forceActiveFocus()
            }

            if ((event.key == Qt.Key_Right) && (event.modifiers & Qt.ControlModifier) && (event.modifiers & Qt.ShiftModifier))
            {
                split()
            }

            if ((event.key == Qt.Key_T) && (event.modifiers & Qt.ControlModifier) && (event.modifiers & Qt.ShiftModifier))
            {
                root.openTab(control.session.intialWorkingDirectory)
            }
        }
    }
}
