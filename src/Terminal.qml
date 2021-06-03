import QtQuick 2.14
import QtQuick.Controls 2.14

import org.mauikit.controls 1.3 as Maui
import org.kde.kirigami 2.4 as Kirigami

Maui.SplitViewItem
{
    id: control

    property string path


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
        Component.onCompleted:
        {
            control.session.initialWorkingDirectory = control.path
        }

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

            if ((event.key == Qt.Key_Down) && (event.modifiers & Qt.ControlModifier) && (event.modifiers & Qt.ShiftModifier))
            {
                split()
            }

            if ((event.key == Qt.Key_Right) && (event.modifiers & Qt.ControlModifier) && (event.modifiers & Qt.ShiftModifier))
            {
                split()
            }

            if ((event.key == Qt.Key_T) && (event.modifiers & Qt.ControlModifier) && (event.modifiers & Qt.ShiftModifier))
            {
                root.openTab(control.session.intialWorkingDirectory)
            }

            if ((event.key == Qt.Key_C) && (event.modifiers & Qt.ControlModifier) && (event.modifiers & Qt.ShiftModifier))
            {
                kterminal.copyClipboard()
            }

            if ((event.key == Qt.Key_V) && (event.modifiers & Qt.ControlModifier) && (event.modifiers & Qt.ShiftModifier))
            {
                kterminal.pasteClipboard()
            }

            if ((event.key == Qt.Key_F) && (event.modifiers & Qt.ControlModifier) && (event.modifiers & Qt.ShiftModifier))
            {
                footBar.visible = !footBar.visible
            }
        }
    }
}
