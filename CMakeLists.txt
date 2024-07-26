cmake_minimum_required(VERSION 3.15)
project(server)

#======================= INCLUSION OF Qt =======================#
set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_PREFIX_PATH $ENV{QTDIR})
find_package(Qt6Core REQUIRED)
find_package(Qt6Network REQUIRED)
find_package(Qt6HttpServer REQUIRED)
find_package(Qt6Qml REQUIRED)
find_package(Qt6Quick REQUIRED)

# Set C++ standard to C++17
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# MSVC specific options to ensure proper __cplusplus value
if(MSVC)
    add_compile_options(/Zc:__cplusplus)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /Zc:__cplusplus")
endif()

# Find Qt
set(Qt6_DIR $ENV{QTDIR})

# Set source and header file directories
set(SOURCE_DIR src)
set(HEADER_DIR include)

# List source files
set(SOURCES
    ${SOURCE_DIR}/client.cpp
    ${SOURCE_DIR}/clientlistwrapper.cpp
    ${SOURCE_DIR}/configurationManager.cpp
    ${SOURCE_DIR}/connectionManager.cpp
    ${SOURCE_DIR}/json.cpp
    ${SOURCE_DIR}/main.cpp
)

# List header files
set(HEADERS
    ${HEADER_DIR}/client.h
    ${HEADER_DIR}/clientlistwrapper.h
    ${HEADER_DIR}/configurationManager.h
    ${HEADER_DIR}/connectionManager.h
    ${HEADER_DIR}/json.h
)

# Use qt6_add_resources to handle QML files (for Qt6)
qt6_add_resources(QML_RESOURCES ${PROJECT_SOURCE_DIR}/resources.qrc)

# Add executable target
add_executable(server ${SOURCES} ${HEADERS} ${QML_RESOURCES})

# Specify include directories for target
target_include_directories(server PUBLIC ${HEADER_DIR})

# Target Qt modules
target_link_libraries(server PRIVATE Qt6::Core Qt6::Network Qt6::HttpServer Qt6::Qml Qt6::Quick)

# Set build type (optional)
set(CMAKE_BUILD_TYPE Debug)

# Install target (optional)
install(TARGETS server DESTINATION bin)
