####################################################################################################
##                                                                                                ##
##            Copyright (C) 2016 William McKIE                                                    ##
##                                                                                                ##
##            This program is free software: you can redistribute it and/or modify                ##
##            it under the terms of the GNU General Public License as published by                ##
##            the Free Software Foundation, either version 3 of the License, or                   ##
##            (at your option) any later version.                                                 ##
##                                                                                                ##
##            This program is distributed in the hope that it will be useful,                     ##
##            but WITHOUT ANY WARRANTY; without even the implied warranty of                      ##
##            MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                       ##
##            GNU General Public License for more details.                                        ##
##                                                                                                ##
##            You should have received a copy of the GNU General Public License                   ##
##            along with this program.  If not, see <http://www.gnu.org/licenses/>.               ##
##                                                                                                ##
####################################################################################################
##  stoiridh_qt_helper(<APPLICATION|LIBRARY> <target>                                             ##
##                     SOURCES <source1> [<source2>...]                                           ##
##                     DEPENDS <dependency1> [<dependency2>...]                                   ##
##                     [OTHER_FILES <file1> [<file2>...]]                                         ##
##                     [USE_QT_PRIVATE_API])                                                      ##
##                                                                                                ##
##------------------------------------------------------------------------------------------------##
##                                                                                                ##
##  This helper function groups the common features in order to make either an application or a   ##
##  shared library.                                                                               ##
##                                                                                                ##
####################################################################################################
function(stoiridh_qt_helper command target)
    set(COMMANDS "APPLICATION" "LIBRARY" "MODULE")
    set(OPTIONS "USE_QT_PRIVATE_API")
    set(MVK "SOURCES" "DEPENDS" "OTHER_FILES")
    cmake_parse_arguments(STOIRIDH_COMMAND "${OPTIONS}" "" "${MVK}" ${ARGN})

    if(NOT command IN_LIST COMMANDS)
        message(FATAL_ERROR "stoiridh_qt_helper(${command}): invalid command.")
    endif()

    if(NOT STOIRIDH_COMMAND_SOURCES)
        message(FATAL_ERROR "stoiridh_qt_helper(${command}): SOURCES is missing or not defined.")
    endif()

    if(NOT STOIRIDH_COMMAND_DEPENDS)
        message(FATAL_ERROR "stoiridh_qt_helper(${command}): DEPENDS is missing or not defined.")
    endif()

    # include the private headers from the Qt API to ${target} if the USE_QT_PRIVATE_API option is
    # given.
    if(STOIRIDH_COMMAND_USE_QT_PRIVATE_API)
        foreach(DEPENDENCY ${STOIRIDH_COMMAND_DEPENDS})
            if(DEPENDENCY MATCHES "^Qt5::[0-9A-Za-z]+$")
                string(REPLACE "::" "" QT5_LIBRARY_MODULE ${DEPENDENCY})
                include_directories(${${QT5_LIBRARY_MODULE}_PRIVATE_INCLUDE_DIRS})
            endif()
        endforeach()
    endif()

    if(command STREQUAL "APPLICATION")
        add_executable(${target} ${STOIRIDH_COMMAND_SOURCES})
    elseif(command STREQUAL "LIBRARY")
        add_library(${target} SHARED ${STOIRIDH_COMMAND_SOURCES})
    elseif(command STREQUAL "MODULE")
        add_library(${target} MODULE ${STOIRIDH_COMMAND_SOURCES})
    endif()

    target_link_libraries(${target} ${STOIRIDH_COMMAND_DEPENDS})
    set_target_properties(${target} PROPERTIES CXX_STANDARD 14 CXX_STANDARD_REQUIRED YES)

    # add extra files that will not be compiled.
    if(STOIRIDH_COMMAND_OTHER_FILES)
        add_custom_target("${target}_OTHER_FILES" SOURCES ${STOIRIDH_COMMAND_OTHER_FILES})
    endif()
endfunction()
