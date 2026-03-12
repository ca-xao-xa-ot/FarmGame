cmake_minimum_required(VERSION 3.14)
project(farm_game LANGUAGES CXX)

set(BINARY_NAME "farm_game")
cmake_policy(SET CMP0063 NEW)

set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install")
set(CMAKE_CXX_STANDARD 17)

set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")
add_subdirectory(${FLUTTER_MANAGED_DIR})

set(PLUGIN_BUNDLED_LIBRARIES)

add_subdirectory("runner")

foreach(bundled_library ${PLUGIN_BUNDLED_LIBRARIES})
  install(FILES "${bundled_library}" DESTINATION "${CMAKE_INSTALL_PREFIX}")
endforeach(bundled_library)
