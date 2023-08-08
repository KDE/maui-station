#pragma once

#include <QObject>

#include <MauiKit3/Core/mauilist.h>

class CommandsModel : public MauiList
{
    Q_OBJECT
public:
    explicit CommandsModel(QObject * parent = nullptr);

public:
    void componentComplete() override final;

    const FMH::MODEL_LIST &items() const override final;

private:
    FMH::MODEL_LIST m_list;
    QStringList m_commands;

    void setList();
    void saveCommands();

public Q_SLOTS:
    bool insert(const QString &command);
    void remove(const int &index);
};

