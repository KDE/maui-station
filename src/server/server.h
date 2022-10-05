#pragma once
#include <QObject>

class OrgKdeStationActionsInterface;

namespace AppInstance
{
QVector<QPair<QSharedPointer<OrgKdeStationActionsInterface>, QStringList>> appInstances(const QString& preferredService);

bool attachToExistingInstance(const QList<QUrl>& inputUrls, bool splitView, const QString& preferredService = QString());

bool registerService();
}

class Server : public QObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.kde.station.Actions")

public:
    explicit Server(QObject *parent = nullptr);
    void setQmlObject(QObject  *object);

public slots:
    /**
           * Tries to raise/activate the Dolphin window.
           */
    void activateWindow();

    /** Stores all settings and quits Dolphin. */
    void quit();

    /**
             * Opens a new tab in the background showing the URL \a url.
             */
    void openTabs(const QStringList &urls, bool splitView = false);
    void openNewTab(const QString& url);
    /**
             * Opens a new empty tab in the background.
             */
    void openEmptyTab();

    /**
             * Opens a new window showing the URL \a url.
             */
    void openNewWindow(const QString &url);



private:
    QObject* m_qmlObject = nullptr;

signals:

};

