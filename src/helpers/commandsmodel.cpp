#include "commandsmodel.h"
#include <QDebug>
#include <QSettings>

CommandsModel::CommandsModel(QObject *parent)
{

}

void CommandsModel::componentComplete()
{
    this->setList();
}

const FMH::MODEL_LIST &CommandsModel::items() const
{
    return m_list;
}

void CommandsModel::setList()
{
    Q_EMIT this->preListChanged();
    this->m_list.clear();
    this->m_commands.clear();

    QSettings settings;
    settings.beginGroup("shortcuts");

    m_commands = settings.value("commands",QStringList()).toStringList();

    settings.endGroup();

    for(const auto &command : m_commands)
    {
        m_list << FMH::MODEL {{FMH::MODEL_KEY::VALUE, command}};
    }

    qDebug()<< "Getting commands" << m_commands;
    Q_EMIT this->postListChanged();
}

void CommandsModel::saveCommands()
{
    QSettings settings;
    settings.beginGroup("shortcuts");
    settings.setValue("commands", m_commands);
    settings.endGroup();
}

bool CommandsModel::insert(const QString &command)
{
    if(m_commands.contains(command))
    {
        return false;
    }

    qDebug() << "try to insert command" << command;

    Q_EMIT preItemAppended();
    m_commands << command;
    m_list << FMH::MODEL {{FMH::MODEL_KEY::VALUE, command}};
    Q_EMIT postItemAppended();

    this->saveCommands();

    return true;
}

void CommandsModel::remove(int index)
{
    Q_EMIT preItemRemoved(index);
m_commands.removeAt(index);
Q_EMIT postItemRemoved();
Q_EMIT countChanged();
this->saveCommands();

}

bool CommandsModel::edit(int index, const QString &newCommand)
{
    qDebug() << "Editing command " << index  << m_commands[index] << newCommand;

    m_commands[index] = newCommand;


     m_list[index].insert(FMH::MODEL_KEY::VALUE, m_commands[index]);

    qDebug() << "Editing command " << index  << m_commands[index] << newCommand << m_commands;

    Q_EMIT updateModel(index, {FMH::MODEL_KEY::VALUE});

    this->saveCommands();

    return true;
}
