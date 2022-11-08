#include <QApplication>
#include <QQmlApplicationEngine>
#include <QCommandLineParser>
#include <QQmlContext>
#include <QIcon>
#include <QDate>

#include <MauiKit/Core/mauiapp.h>

#include <KI18n/KLocalizedString>
#include <KAboutData>

#include "helpers/keyshelper.h"
#include "helpers/commandsmodel.h"
#include "helpers/station.h"
#include "helpers/fonts.h"

#include "server/server.h"

#include "../station_version.h"

#define STATION_URI "org.maui.station"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QCoreApplication::setAttribute(Qt::AA_UseHighDpiPixmaps, true);

    QApplication app(argc, argv);

    app.setOrganizationName("Maui");
    app.setWindowIcon(QIcon(":/station/station.svg"));

    MauiApp::instance()->setIconName("qrc:/station/station.svg");

    KLocalizedString::setApplicationDomain("station");
    KAboutData about(QStringLiteral("station"), i18n("Station"), STATION_VERSION_STRING, i18n("Convergent terminal emulator."), KAboutLicense::LGPL_V3, i18n("© 2019-%1 Maui Development Team", QString::number(QDate::currentDate().year())), QString(GIT_BRANCH) + "/" + QString(GIT_COMMIT_HASH));
    about.addAuthor(i18n("Camilo Higuita"), i18n("Developer"), QStringLiteral("milo.h@aol.com"));
    about.setHomepage("https://mauikit.org");
    about.setProductName("maui/station");
    about.setBugAddress("https://invent.kde.org/maui/station/-/issues");
    about.setOrganizationDomain(STATION_URI);
    about.setProgramLogo(app.windowIcon());

    KAboutData::setApplicationData(about);

    QCommandLineParser parser;

    about.setupCommandLine(&parser);
    parser.process(app);

    about.processCommandLine(&parser);
    const QStringList args = parser.positionalArguments();

    QStringList paths;
    if (!args.isEmpty())
    {
        for(const auto &path : args)
            paths << QUrl::fromUserInput(path).toString();
    }

    if (AppInstance::attachToExistingInstance(QUrl::fromStringList(paths), false))
    {
        // Successfully attached to existing instance of Nota
        return 0;
    }

    AppInstance::registerService();
    auto server = std::make_unique<Server>();

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(
                &engine,
                &QQmlApplicationEngine::objectCreated,
                &app,
                [url, args, &server](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);

        server->setQmlObject(obj);
        if (!args.isEmpty())
            server->openTabs(args, false);
        else
        {
            server->openTabs({"$HOME"}, false);
        }

    },
    Qt::QueuedConnection);

    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));

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
