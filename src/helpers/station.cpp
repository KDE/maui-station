#include "station.h"

Q_GLOBAL_STATIC(Station, stationInstance)

Station::Station(QObject *parent)
{

}

Station * Station::instance()
{
    return stationInstance();
}
