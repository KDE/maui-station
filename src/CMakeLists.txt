# Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
# Copyright 2018-2020 Nitrux Latinoamericana S.C.
#
# SPDX-License-Identifier: GPL-3.0-or-later

set(station_SRCS
    main.cpp
    helpers/station.cpp
    helpers/keyshelper.cpp
    helpers/commandsmodel.cpp
    server/server.cpp)

qt_add_resources(station_QML_QRC
    assets/img_assets.qrc)

qt_generate_dbus_interface(${CMAKE_CURRENT_SOURCE_DIR}/server/server.h org.kde.Station.xml)
qt_add_dbus_adaptor(station_dbus_SRCS ${CMAKE_CURRENT_BINARY_DIR}/org.kde.Station.xml server/server.h Server)
qt_add_dbus_interface(station_dbus_SRCS ${CMAKE_CURRENT_BINARY_DIR}/org.kde.Station.xml stationinterface)

qt_add_executable(${PROJECT_NAME}
    ${station_SRCS}
    ${station_dbus_SRCS}
    ${station_QML_QRC})

qt_add_qml_module(${PROJECT_NAME} URI app.maui.station
    NO_PLUGIN
    QML_FILES
    main.qml
    widgets/TutorialDialog.qml
    widgets/CommandShortcuts.qml
    widgets/SettingsDialog.qml
    widgets/Terminal.qml
    widgets/TerminalLayout.qml)

target_compile_definitions(${PROJECT_NAME} PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)

target_link_libraries(${PROJECT_NAME}
    PRIVATE
    MauiKit4
    MauiKit4::Terminal
    Qt6::Widgets
    Qt6::Quick
    Qt6::Qml
    Qt6::DBus
    KF6::I18n
    KF6::CoreAddons)

install(TARGETS ${PROJECT_NAME} ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
install(FILES org.kde.station.desktop DESTINATION ${KDE_INSTALL_APPDIR})
install(FILES assets/station.svg DESTINATION ${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps)
