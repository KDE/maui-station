#pragma once
#include <QObject>

#if (defined Q_OS_LINUX || defined Q_OS_FREEBSD) && !defined Q_OS_ANDROID
class OrgKdeNotaActionsInterface;

namespace AppInstance
{
QVector<QPair<QSharedPointer<OrgKdeNotaActionsInterface>, QStringList>> appInstances(const QString& preferredService);

bool attachToExistingInstance(const QList<QUrl>& inputUrls, bool splitView, const QString& preferredService = QString());

bool registerService();
}
#endif

class Server : public QObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.kde.nota.Actions")

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
           * Opens the directories which contain the files \p files and selects all files.
           * If \a splitView is set, 2 directories are collected within one tab.
           * \pre \a files must contain at least one url.
           *
           * @note this is overloaded so that this function is callable via DBus.
           */
    void openFiles(const QStringList &urls, bool splitView);


    /**
             * Opens a new tab in the background showing the URL \a url.
             */
    void openNewTab(const QString& url);
    /**
             * Opens a new empty tab in the background.
             */
    void openEmptyTab();

    void focusFile(const QString& url);

    /**
             * Opens a new tab  showing the URL \a url and activate it.
             */
    void openNewTabAndActivate(const QString &url);

    /**
             * Opens a new window showing the URL \a url.
             */
    void openNewWindow(const QString &url);

    /**
                * Determines if a URL is open in any tab.
                * @note Use of QString instead of QUrl is required to be callable via DBus.
                *
                * @param url URL to look for
                * @returns true if url is currently open in a tab, false otherwise.
                */
    bool isUrlOpen(const QString &url);


private:
    QObject* m_qmlObject = nullptr;
    QStringList filterFiles(const QStringList &urls);

signals:

};

