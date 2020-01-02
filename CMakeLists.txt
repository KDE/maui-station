cmake_minimum_required(VERSION 3.1)
set(STATION_VERSION 1.0.0)
project(station LANGUAGES CXX VERSION ${STATION_VERSION})

find_package(ECM 1.7.0 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake" ${ECM_MODULE_PATH})

include(ECMSetupVersion)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt5 REQUIRED NO_MODULE COMPONENTS Qml Quick Sql Svg QuickControls2 Widgets)

add_executable(${PROJECT_NAME}
    src/main.cpp
    src/helpers/keyshelper.cpp
    src/qml.qrc
    )

ecm_setup_version(${STATION_VERSION}
    VARIABLE_PREFIX STATION
    VERSION_HEADER "${CMAKE_CURRENT_BINARY_DIR}/station_version.h"
    )

target_compile_definitions(${PROJECT_NAME} PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt5::Sql Qt5::Qml Qt5::Widgets Qt5::Svg)
