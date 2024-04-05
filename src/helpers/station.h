#pragma once

#include <QObject>

class Station : public QObject
{
    Q_OBJECT

public:
    explicit Station(QObject *parent = nullptr);
    static Station *instance();

};

