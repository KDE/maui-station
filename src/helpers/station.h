#pragma once

#include <QFileInfo>
#include <QObject>
#include <QDebug>

class Station : public QObject
{
    Q_OBJECT

public:
    static Station *instance()
    {
        static Station station;
        return &station;
    }

    Station(const Station &) = delete;
    Station &operator=(const Station &) = delete;
    Station(Station &&) = delete;
    Station &operator=(Station &&) = delete;

private:
    explicit Station(QObject *parent = nullptr)
        : QObject(parent)
    {
    }
};
