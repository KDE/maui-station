#include <QApplication>
#include <QQmlApplicationEngine>
#include <QCommandLineParser>
#include <QQmlContext>
#include <QIcon>

#include <MauiKit4/Core/mauiapp.h>
#include <MauiKit4/Terminal/moduleinfo.h>

#include <KLocalizedString>
#include <KAboutData>

#include "helpers/keyshelper.h"
#include "helpers/commandsmodel.h"
#include "helpers/station.h"

#include "server/server.h"

#include "../station_version.h"

#define STATION_URI "org.maui.station"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    app.setOrganizationName("Maui");
    app.setWindowIcon(QIcon(":/station/station.svg"));

    KLocalizedString::setApplicationDomain("station");
    KAboutData about(QStringLiteral("station"),
                     i18n("Station"),
                     STATION_VERSION_STRING,
                     i18n("Convergent terminal emulator."),
                     KAboutLicense::LGPL_V3,
                     i18n("© 2019-2023 Maui Development Team"),
                     QString(GIT_BRANCH) + "/" + QString(GIT_COMMIT_HASH));
    about.addAuthor(i18n("Camilo Higuita"), i18n("Developer"), QStringLiteral("milo.h@aol.com"));
    about.setHomepage("https://mauikit.org");
    about.setProductName("maui/station");
    about.setBugAddress("https://invent.kde.org/maui/station/-/issues");
    about.setOrganizationDomain(STATION_URI);
    about.setProgramLogo(app.windowIcon());

    const auto TData = MauiKitTerminal::aboutData();
    about.addComponent(TData.name(), MauiKitTerminal::buildVersion(), TData.version(), TData.webAddress());

    about.addCredit("QMLTermWidget");
    about.addCredit("UBPorts Terminal");
    about.addCredit("Cutefish Terminal");

    KAboutData::setApplicationData(about);

    MauiApp::instance()->setIconName("qrc:/station/station.svg");

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
    const QUrl url(QStringLiteral("qrc:/app/maui/station/main.qml"));
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
            server->openTabs({"$PWD"}, false);
        }

    },
    Qt::QueuedConnection);

    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));

    qmlRegisterAnonymousType<Key> (STATION_URI, 1);
    qmlRegisterType<KeysHelper> (STATION_URI, 1, 0, "KeysModel");
    qmlRegisterType<CommandsModel> (STATION_URI, 1, 0, "CommandsModel");
    qmlRegisterSingletonInstance<Station>(STATION_URI, 1, 0, "Station", Station::instance());

    engine.load(url);

    return app.exec();
}
