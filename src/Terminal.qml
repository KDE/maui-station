import QtQuick 2.14
import QtQuick.Controls 2.14

import org.kde.mauikit 1.2 as Maui
import org.kde.kirigami 2.4 as Kirigami

import QtQml.Models 2.3

Maui.Terminal
{
    id: control
    property string path
    readonly property int _index : ObjectModel.index
    property int orientation : _splitView.orientation

    function forceActiveFocus()
    {
        control.kterminal.forceActiveFocus()
    }


    SplitView.fillHeight: true
    SplitView.fillWidth: true
    SplitView.preferredHeight: _splitView.orientation === Qt.Vertical ? _splitView.height / (_splitView.count) :  _splitView.height
    SplitView.minimumHeight: _splitView.orientation === Qt.Vertical ?  200 : 0


    SplitView.preferredWidth: _splitView.orientation === Qt.Horizontal ? _splitView.width / (_splitView.count) : _splitView.width
    SplitView.minimumWidth: _splitView.orientation === Qt.Horizontal ? 300 :  0


    opacity: _splitView.currentIndex === control._index ? 1 : 0.5

   Component.onCompleted:
   {
       control.session.initialWorkingDirectory = control.path
   }

   onClicked:
   {
       _splitView.currentIndex = control._index
   }

   onUrlsDropped:
   {
       for(var i in urls)
       control.session.sendText(urls[i].replace("file://", "")+ " ")
   }


    kterminal.colorScheme: settings.colorScheme
    onKeyPressed:
    {
        if ((event.key == Qt.Key_Tab) && (event.modifiers & Qt.ControlModifier))
        {
            _splitView.currentIndex = control.index === 1 ? 0 : (_splitView.count > 1 ? 1 : 0)
            terminal.forceActiveFocus()
        }

        if ((event.key == Qt.Key_Down) && (event.modifiers & Qt.ControlModifier) && (event.modifiers & Qt.ShiftModifier))
        {
            split(Qt.Vertical)
        }

        if ((event.key == Qt.Key_Right) && (event.modifiers & Qt.ControlModifier) && (event.modifiers & Qt.ShiftModifier))
        {
            split(Qt.Horizontal)
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
