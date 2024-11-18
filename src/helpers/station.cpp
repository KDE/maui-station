#include "station.h"
#include <QFileInfo>
#include <QUrl>

Q_GLOBAL_STATIC(Station, stationInstance)

Station::Station(QObject *parent)
{

}

Station * Station::instance()
{
    return stationInstance();
}


bool Station::isLocalUrl(const QString &url)
{
    QFileInfo file(QUrl(url).toLocalFile());
    return file.exists();
}


QString Station::resolveUrl(const QString &url, const QString &dir)
{
    QUrl m_dir = QUrl::fromLocalFile(dir+"/");
    QUrl m_url (url);

    // if(!m_url.isRelative())
    //     return url;
auto const resolved = m_dir.resolved(m_url).toString();
qDebug() << "RESOLVED URL" << resolved << m_dir << m_url;
    return resolved;
}
