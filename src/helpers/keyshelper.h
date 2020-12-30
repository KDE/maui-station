#ifndef KEYSHELPER_H
#define KEYSHELPER_H

#include <QAbstractListModel>
#include <QObject>

struct Key {
    Q_GADGET
    Q_PROPERTY(Qt::Modifier modifier MEMBER modifier)
public:
    Qt::Key key;
    QString label;
    QString iconName;
    Qt::Modifier modifier;
};

class KeysHelper : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(Group group WRITE setGroup READ group NOTIFY groupChanged)
public:
    enum ROLES : uint8_t { ICON_NAME, LABEL, KEY, MODIFIER, ITEM };
    Q_ENUM(ROLES)

    enum Group : uint8_t { FN_GROUP, NANO_GROUP, CTRL_GROUP, NAV_GROUP, DEFAULT_GROUP };
    Q_ENUM(Group)

    explicit KeysHelper(QObject *parent = nullptr);
    int rowCount(const QModelIndex &) const override;
    QVariant data(const QModelIndex &index, int role) const override;

    Group group() const;

protected:
    QHash<int, QByteArray> roleNames() const override;

private:
    void setKeys();
    QVector<Key> m_keys;
    Group m_group = Group::DEFAULT_GROUP;

    QVector<Key> ctrlKeys() const;
    QVector<Key> fnKeys() const;
    QVector<Key> navKeys() const;
    QVector<Key> nanoKeys() const;
    QVector<Key> defaultKeys() const;

signals:
    void groupChanged();

public slots:
    void sendKey(const int &index, QObject *object);
    void setGroup(Group group);
};

#endif // KEYSHELPER_H
