#include "keyshelper.h"
#include <QKeyEvent>
#include <QCoreApplication>
#include <QDebug>

KeysHelper::KeysHelper(QObject *parent) : QAbstractListModel(parent)
{
	this->setKeys();
}

int KeysHelper::rowCount(const QModelIndex &) const
{
	return this->m_keys.count ();
}

QVariant KeysHelper::data(const QModelIndex & index, int role) const
{
	const auto key = this->m_keys.at(index.row ());

	switch(role)
	{
		case ROLES::KEY:
			return key.key;
		case ROLES::LABEL:
			return key.label;
		case ROLES::ICON_NAME:
			return key.iconName;
		case ROLES::MODIFIER:
			return key.modifier;
		case ROLES::ITEM:
			return QVariant::fromValue(key);
		default: return QVariant();
	}
}

QHash<int, QByteArray> KeysHelper::roleNames() const
{
	static QHash<int, QByteArray> roles;
	roles[ROLES::ITEM] = "item";
	roles[ROLES::KEY] = "key";
	roles[ROLES::LABEL] = "label";
	roles[ROLES::ICON_NAME] = "iconName";
	roles[ROLES::MODIFIER] = "modifier";
	return roles;
}

void KeysHelper::setKeys()
{
	emit this->beginResetModel ();
	this->m_keys.append ({Qt::Key::Key_Down, "", "go-down"});
	this->m_keys.append ({Qt::Key::Key_Up, "", "go-up"});
	this->m_keys.append ({Qt::Key::Key_Tab, "Tab"});
	this->m_keys.append ({Qt::Key::Key_Escape, "Esc"});
	this->m_keys.append ({Qt::Key::Key_Control, "Ctrl"});
	this->m_keys.append ({Qt::Key::Key_Alt, "Alt"});
	this->m_keys.append ({Qt::Key::Key_C, "Ctrl+C", "", Qt::Modifier::CTRL});

	qDebug()<< "FINISHED EMITTIGN KEYS"<< this->m_keys.count ();

	emit this->endResetModel ();
}

void KeysHelper::sendKey(const int & index, QObject *object)
{
	if(index > this->m_keys.count () && index < 0)
		return;

	const auto key = this->m_keys.at(index);
	QKeyEvent *event = new QKeyEvent ( QEvent::KeyPress, key.key, {key.modifier});
	QCoreApplication::postEvent (object, event);
}
