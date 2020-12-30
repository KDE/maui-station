#include "keyshelper.h"
#include <QCoreApplication>
#include <QDebug>
#include <QKeyEvent>

KeysHelper::KeysHelper(QObject *parent)
    : QAbstractListModel(parent)
{
    this->setKeys();
}

int KeysHelper::rowCount(const QModelIndex &) const
{
    return this->m_keys.count();
}

QVariant KeysHelper::data(const QModelIndex &index, int role) const
{
    const auto key = this->m_keys.at(index.row());

    switch (role) {
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
    default:
        return QVariant();
    }
}

KeysHelper::Group KeysHelper::group() const
{
    return m_group;
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
    emit this->beginResetModel();

    switch (m_group) {
    case Group::FN_GROUP: {
        this->m_keys = fnKeys();
        break;
    }
    case Group::NAV_GROUP: {
        this->m_keys = navKeys();
        break;
    }
    case Group::CTRL_GROUP: {
        this->m_keys = ctrlKeys();
        break;
    }
    case Group::NANO_GROUP: {
        this->m_keys = nanoKeys();
        break;
    }
    case Group::DEFAULT_GROUP: {
        this->m_keys = defaultKeys();
        break;
    }
    default: {
        this->m_keys = defaultKeys();
    }
    }

    qDebug() << "FINISHED EMITTIGN KEYS" << this->m_keys.count();

    emit this->endResetModel();
}

QVector<Key> KeysHelper::ctrlKeys() const
{
    QVector<Key> res;
    res.append({Qt::Key::Key_C, "Ctrl+C", "", Qt::Modifier::CTRL});
    res.append({Qt::Key::Key_V, "Ctrl+V", "", Qt::Modifier::CTRL});
    res.append({Qt::Key::Key_M, "Ctrl+M", "", Qt::Modifier::CTRL});
    res.append({Qt::Key::Key_F, "Ctrl+F", "", Qt::Modifier::CTRL});
    res.append({Qt::Key::Key_X, "Ctrl+X", "", Qt::Modifier::CTRL});

    return res;
}

QVector<Key> KeysHelper::fnKeys() const
{
    QVector<Key> res;
    res.append({Qt::Key::Key_F1, "F1"});
    res.append({Qt::Key::Key_F2, "F2"});
    res.append({Qt::Key::Key_F3, "F3"});
    res.append({Qt::Key::Key_F4, "F4"});
    res.append({Qt::Key::Key_F5, "F5"});
    res.append({Qt::Key::Key_F6, "F6"});
    res.append({Qt::Key::Key_F7, "F7"});
    res.append({Qt::Key::Key_F8, "F8"});
    res.append({Qt::Key::Key_F9, "F10"});
    res.append({Qt::Key::Key_F10, "F10"});
    res.append({Qt::Key::Key_F11, "F11"});
    res.append({Qt::Key::Key_F12, "F12"});

    return res;
}

QVector<Key> KeysHelper::navKeys() const
{
    QVector<Key> res;
    res.append({Qt::Key::Key_Up, "", "go-up"});
    res.append({Qt::Key::Key_Down, "", "go-down"});
    res.append({Qt::Key::Key_Left, "", "go-previous"});
    res.append({Qt::Key::Key_Right, "", "go-next"});

    return res;
}

QVector<Key> KeysHelper::nanoKeys() const
{
    QVector<Key> res;
    res.append({Qt::Key::Key_Up, "", "go-up"});
    res.append({Qt::Key::Key_Down, "", "go-down"});

    res.append({Qt::Key::Key_Left, "", "go-previous"});
    res.append({Qt::Key::Key_Right, "", "go-next"});

    res.append({Qt::Key::Key_G, "Ctrl+G", "", Qt::Modifier::CTRL});
    res.append({Qt::Key::Key_X, "Ctrl+X", "", Qt::Modifier::CTRL});
    res.append({Qt::Key::Key_O, "Ctrl+O", "", Qt::Modifier::CTRL});
    res.append({Qt::Key::Key_R, "Ctrl+R", "", Qt::Modifier::CTRL});
    res.append({Qt::Key::Key_W, "Ctrl+W", "", Qt::Modifier::CTRL});
    res.append({Qt::Key::Key_K, "Ctrl+K", "", Qt::Modifier::CTRL});
    res.append({Qt::Key::Key_T, "Ctrl+T", "", Qt::Modifier::CTRL});
    res.append({Qt::Key::Key_C, "Ctrl+C", "", Qt::Modifier::CTRL});

    return res;
}

QVector<Key> KeysHelper::defaultKeys() const
{
    QVector<Key> res;
    res.append({Qt::Key::Key_Up, "", "go-up"});
    res.append({Qt::Key::Key_Down, "", "go-down"});
    res.append({Qt::Key::Key_Tab, "Tab"});
    res.append({Qt::Key::Key_Escape, "Esc"});
    res.append({Qt::Key::Key_Control, "Ctrl"});
    res.append({Qt::Key::Key_Alt, "Alt"});
    res.append({Qt::Key::Key_C, "Ctrl+C", "", Qt::Modifier::CTRL});

    return res;
}

void KeysHelper::sendKey(const int &index, QObject *object)
{
    if (index > this->m_keys.count() && index < 0)
        return;

    const auto key = this->m_keys.at(index);
    QKeyEvent *event = new QKeyEvent(QEvent::KeyPress, key.key, {key.modifier});
    QCoreApplication::postEvent(object, event);
}

void KeysHelper::setGroup(Group group)
{
    if (m_group == group)
        return;

    m_group = group;
    this->setKeys();
    emit groupChanged();
}
