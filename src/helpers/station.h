#pragma once

#include <QObject>

class Station : public QObject
{
    Q_OBJECT

public:
    explicit Station(QObject *parent = nullptr);
    static Station *instance();

public Q_SLOTS:
    static bool isLocalUrl(const QString &url);
    static QString resolveUrl(const QString &url, const QString &dir);
};

