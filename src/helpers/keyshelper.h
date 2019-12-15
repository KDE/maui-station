#ifndef KEYSHELPER_H
#define KEYSHELPER_H

#include <QObject>
#include <QAbstractListModel>

struct Key
{
        Q_GADGET
        Q_PROPERTY (Qt::Modifier modifier MEMBER modifier)
    public:
        Qt::Key key;
        QString label;
        QString iconName;
        Qt::Modifier modifier;
};

class KeysHelper : public QAbstractListModel
{
        Q_OBJECT
    public:
        enum ROLES : uint8_t
            {
            ICON_NAME,
            LABEL,
            KEY,
            MODIFIER,
            ITEM
            }; Q_ENUM(ROLES)

        explicit KeysHelper(QObject *parent = nullptr);
        int rowCount(const QModelIndex&) const override;
        QVariant data(const QModelIndex& index, int role) const override;


    protected:
        QHash<int, QByteArray> roleNames() const override;

    private:
        void setKeys();
        QVector<Key> m_keys;
    signals:

    public slots:
        void sendKey(const int &index, QObject * object);

};

#endif // KEYSHELPER_H
