# Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
# Copyright 2018-2020 Nitrux Latinoamericana S.C.
#
# SPDX-License-Identifier: GPL-3.0-or-later

set(station_SRCS
    main.cpp
    helpers/station.h
    helpers/keyshelper.cpp
    helpers/commandsmodel.cpp
    helpers/fonts.cpp
    server/server.cpp
    assets/img_assets.qrc)

if(QUICK_COMPILER)
        qtquick_compiler_add_resources(station_QML_QRC qml.qrc)
else()
        qt5_add_resources(station_QML_QRC qml.qrc)
endif()

qt_generate_dbus_interface(${CMAKE_CURRENT_SOURCE_DIR}/server/server.h org.kde.Station.xml)
qt_add_dbus_adaptor(station_dbus_SRCS ${CMAKE_CURRENT_BINARY_DIR}/org.kde.Station.xml server/server.h Server)
qt_add_dbus_interface(station_dbus_SRCS ${CMAKE_CURRENT_BINARY_DIR}/org.kde.Station.xml stationinterface)

add_executable(${PROJECT_NAME}
    ${station_SRCS}
    ${station_dbus_SRCS}
    ${station_QML_QRC})

target_compile_definitions(${PROJECT_NAME} PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)

target_link_libraries(${PROJECT_NAME}
    PRIVATE
    MauiKit3
    Qt5::Widgets
    Qt5::Quick
    Qt5::Qml
    Qt5::DBus
    KF5::I18n
    KF5::CoreAddons)

install(TARGETS ${PROJECT_NAME} ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
install(FILES org.kde.station.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})
install(FILES assets/station.svg DESTINATION ${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps)
