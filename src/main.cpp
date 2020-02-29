#include <QQmlApplicationEngine>
#include <QIcon>

#include "station_version.h"

#ifdef Q_OS_ANDROID
#include <QGuiApplication>
#else
#include <QApplication>
#endif

#ifdef STATIC_KIRIGAMI
#include "3rdparty/kirigami/src/kirigamiplugin.h"
#endif

#ifdef STATIC_MAUIKIT
#include "./mauikit/src/mauikit.h"
#endif

#include "helpers/keyshelper.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

#ifdef Q_OS_ANDROID
    QGuiApplication app(argc, argv);
#else
    QApplication app(argc, argv);
#endif

    app.setApplicationName("station");
    app.setApplicationDisplayName("Station");
    app.setOrganizationName("Maui");
    app.setOrganizationDomain("org.maui.station");
    app.setApplicationVersion(STATION_VERSION_STRING);
    app.setApplicationDisplayName("Station");
    app.setWindowIcon(QIcon(":/station.svg"));

#ifdef STATIC_KIRIGAMI
    KirigamiPlugin::getInstance().registerTypes();
#endif

#ifdef STATIC_MAUIKIT
    MauiKit::getInstance().registerTypes();
#endif

    qmlRegisterType<Key> ();
    qmlRegisterType<KeysHelper> ("org.maui.station", 1, 0, "KeysModel");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
