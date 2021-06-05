#ifndef STATION_H
#define STATION_H

#include <QFileInfo>
#include <QObject>
#include <QDebug>

#include <MauiKit/FileBrowsing/fmstatic.h>

class Station : public QObject
{
    Q_OBJECT

public:
    static Station *instance()
    {
        static Station nota;
        return &nota;
    }

    Station(const Station &) = delete;
    Station &operator=(const Station &) = delete;
    Station(Station &&) = delete;
    Station &operator=(Station &&) = delete;

public slots:
    void requestPaths(const QStringList &urls)
    {
        qDebug() << "REQUEST FILES" << urls;
        QStringList res;
        for (const auto &url : urls) {
            const auto url_ = QUrl::fromUserInput(url);

            if(url_.isLocalFile())
            {
                if (FMStatic::isDir(url_))
                {
                    res << url_.toLocalFile();
                }
                else
                {
                    res << QUrl(FMStatic::fileDir(url_)).toLocalFile();
                }
            }
        }

        emit this->openPaths(res);
    }


signals:
    void openPaths(QStringList urls);

private:
    explicit Station(QObject *parent = nullptr)
        : QObject(parent)
    {
    }
};

#endif // NOTA_H
