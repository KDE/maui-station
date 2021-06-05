#include <QApplication>
#include <QQmlApplicationEngine>
#include <QCommandLineParser>
#include <QIcon>
#include <QDate>

#include <MauiKit/Core/mauiapp.h>

#include <KI18n/KLocalizedString>
#include <KAboutData>

#include "helpers/keyshelper.h"
#include "helpers/commandsmodel.h"
#include "helpers/station.h"
#include "helpers/fonts.h"

#include "../station_version.h"

#define STATION_URI "org.maui.station"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QCoreApplication::setAttribute(Qt::AA_DontCreateNativeWidgetSiblings);
    QCoreApplication::setAttribute(Qt::AA_UseHighDpiPixmaps, true);
    QCoreApplication::setAttribute(Qt::AA_DisableSessionManager, true);

    QApplication app(argc, argv);

    app.setOrganizationName("Maui");
    app.setWindowIcon(QIcon(":/station.svg"));

    MauiApp::instance()->setIconName("qrc:/station.svg");

    KLocalizedString::setApplicationDomain("station");
    KAboutData about(QStringLiteral("station"), i18n("Station"), STATION_VERSION_STRING, i18n("Convergent terminal emulator."), KAboutLicense::LGPL_V3, i18n("© 2019-%1 Nitrux Development Team", QString::number(QDate::currentDate().year())), QString(GIT_BRANCH) + "/" + QString(GIT_COMMIT_HASH));
    about.addAuthor(i18n("Camilo Higuita"), i18n("Developer"), QStringLiteral("milo.h@aol.com"));
    about.setHomepage("https://mauikit.org");
    about.setProductName("maui/station");
    about.setBugAddress("https://invent.kde.org/maui/station/-/issues");
    about.setOrganizationDomain(STATION_URI);
    about.setProgramLogo(app.windowIcon());

    KAboutData::setApplicationData(about);

    QCommandLineParser parser;
    parser.process(app);

    about.setupCommandLine(&parser);
    about.processCommandLine(&parser);
    const QStringList args = parser.positionalArguments();

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(
                &engine,
                &QQmlApplicationEngine::objectCreated,
                &app,
                [url, args](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);

        if (!args.isEmpty())
            Station::instance()->requestPaths(args);
    },
    Qt::QueuedConnection);

    qmlRegisterAnonymousType<Key> (STATION_URI, 1);
    qmlRegisterType<KeysHelper> (STATION_URI, 1, 0, "KeysModel");
    qmlRegisterType<CommandsModel> (STATION_URI, 1, 0, "CommandsModel");
    qmlRegisterSingletonInstance<Station>(STATION_URI, 1, 0, "Station", Station::instance());
    qmlRegisterSingletonType<Fonts>(STATION_URI, 1, 0, "Fonts", [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
           Q_UNUSED(engine)
           Q_UNUSED(scriptEngine)
           return new Fonts;
       });

    engine.load(url);

    return app.exec();
}
