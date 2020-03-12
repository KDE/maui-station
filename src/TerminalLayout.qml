import QtQuick 2.9
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import QtQml.Models 2.3

ColumnLayout
{
    id: control
    spacing: 0
    height: _browserList.height
    width: _browserList.width
    focus: true

    property alias terminal : _splitView.currentItem
    property alias orientation : _splitView.orientation
    property alias count : _splitView.count

    function forceActiveFocus()
    {
        control.terminal.forceActiveFocus()
    }

    ObjectModel { id: splitObjectModel }

    SplitView
    {
        id: _splitView
        focus: true
        Layout.fillWidth: true
        Layout.fillHeight: true

        Repeater
        {
            model: splitObjectModel
        }

        onOrientationChanged:
        {
            _splitView.width = _splitView.width +1
            _splitView.width = control.width
            _splitView.height = _splitView.height +1
            _splitView.height = control.height
        }

        onCurrentItemChanged: currentItem.forceActiveFocus()
    }

    Maui.PathBar
    {
        //    Kirigami.Theme.backgroundColor:"transparent"
        //    Kirigami.Theme.textColor:c"white"
        border.color: "transparent"
        radius: 0
        Layout.fillWidth: true
        Layout.alignment:Qt.AlignBottom
        onPlaceClicked:
        {
            terminal.session.sendText("cd " + path.trim() + "\n")
        }
        url: control.terminal.title.slice(control.terminal.title.indexOf(":")+1)
    }

    Component.onCompleted: split(Qt.Vertical)

    function split(orientation)
    {
        _splitView.orientation = orientation

        if(_splitView.count === 2)
            return;

        const component = Qt.createComponent("Terminal.qml");
        if (component.status === Component.Ready)
        {
            const object = component.createObject(splitObjectModel, {'path': control.path, 'index': _splitView.count});
            splitObjectModel.append(object)
        }
    }

}
