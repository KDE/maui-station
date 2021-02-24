#include "commandsmodel.h"

#include <MauiKit/fmstatic.h>

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
    emit this->preListChanged();
    this->m_list.clear();
    this->m_commands.clear();

    m_commands = FMStatic::loadSettings("commands", "shortcuts", QStringList()).toStringList();

    for(const auto &command : m_commands)
    {
        m_list << FMH::MODEL {{FMH::MODEL_KEY::VALUE, command}};
    }

    qDebug()<< "Getting commands" << m_commands;
    emit this->postListChanged();
}

void CommandsModel::saveCommands()
{
    FMStatic::saveSettings("commands", m_commands, "shortcuts");
}

void CommandsModel::insert(const QString &command)
{
    if(m_commands.contains(command))
    {
        return;
    }

    qDebug() << "try to insert command" << command;

    emit preItemAppended();
    m_commands << command;
    m_list << FMH::MODEL {{FMH::MODEL_KEY::VALUE, command}};
    emit postItemAppended();

    this->saveCommands();
}

void CommandsModel::remove(const int &index)
{

}
