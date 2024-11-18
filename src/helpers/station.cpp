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


bool Station::isValidUrl(const QString &url)
{
    QUrl m_url(url);
    if(m_url.isLocalFile())
    {
        QFileInfo file(QUrl(url).toLocalFile());
        return file.exists();
    }else
    {
        return m_url.isValid();
    }
}


QString Station::resolveUrl(const QString &url, const QString &dir)
{
    QUrl m_dir = QUrl::fromLocalFile(dir+"/");
    QUrl m_url (url.simplified());

    // if(!m_url.isRelative())
    //     return url;
auto const resolved = m_dir.resolved(m_url).toString();
qDebug() << "RESOLVED URL" << resolved << m_dir << m_url;
    return resolved;
}
