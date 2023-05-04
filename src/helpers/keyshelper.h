#pragma once

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
    Q_PROPERTY(QVariantList signalsGroup READ signalsGroup CONSTANT FINAL)

public:
    enum ROLES : uint8_t { ICON_NAME, LABEL, KEY, MODIFIER, ITEM };
    Q_ENUM(ROLES)

    enum Group : uint8_t { FN_GROUP, NANO_GROUP, CTRL_GROUP, NAV_GROUP, DEFAULT_GROUP, SIGNALS_GROUP };
    Q_ENUM(Group)

    explicit KeysHelper(QObject *parent = nullptr);
    int rowCount(const QModelIndex &) const override;
    QVariant data(const QModelIndex &index, int role) const override;

    Group group() const;

    QVariantList signalsGroup() const;

protected:
    QHash<int, QByteArray> roleNames() const override;


public Q_SLOTS:
    void sendKey(const int &index, QObject *object);
    void setGroup(Group group);

private:
    void setKeys();
    QVector<Key> m_keys;
    Group m_group = Group::DEFAULT_GROUP;

    static QVector<Key> ctrlKeys();
    static QVector<Key> fnKeys();
    static QVector<Key> navKeys();
    static QVector<Key> nanoKeys();
    static QVector<Key> defaultKeys();
    static QVector<Key> signalKeys();    

Q_SIGNALS:
    void groupChanged();

};
