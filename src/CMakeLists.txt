# Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
# Copyright 2018-2020 Nitrux Latinoamericana S.C.
#
# SPDX-License-Identifier: GPL-3.0-or-later

set(station_SRCS
    main.cpp
    helpers/station.h
    helpers/keyshelper.cpp
    helpers/commandsmodel.cpp
    qml.qrc
    assets/assets.qrc
    )

add_executable(${PROJECT_NAME} ${station_SRCS})


target_compile_definitions(${PROJECT_NAME} PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)
target_link_libraries(${PROJECT_NAME} PRIVATE MauiKit MauiKit::FileBrowsing Qt5::Sql Qt5::Qml Qt5::Svg KF5::I18n KF5::CoreAddons)

install(TARGETS station ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
install(FILES org.kde.station.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})
install(FILES assets/station.svg DESTINATION ${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps)
