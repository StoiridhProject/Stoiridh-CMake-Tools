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
stoiridh_include("Stoiridh.Assert" INTERNAL)
stoiridh_include("Stoiridh.Qt.Helper" INTERNAL)

####################################################################################################
##  stoiridh_qt_qml_add_autotest(<target> [ALIAS <alias>]                                         ##
##                               SOURCES <source1> [<source2>...]                                 ##
##                               DEPENDS <dependency1> [<dependency2>...]                         ##
##                               DATA_DIR <data dir>                                              ##
##                               [TEST_NAME <name>]                                               ##
##                               [OTHER_FILES <file1> [<file2>...]])                              ##
##                                                                                                ##
##------------------------------------------------------------------------------------------------##
##                                                                                                ##
##  Add a Qt autotest to the project.                                                             ##
##                                                                                                ##
##  An <alias> can be set to the <target> in order to be linked with an elegant name in others    ##
##  projects.                                                                                     ##
##                                                                                                ##
##  The DATA_DIR argument corresponds to the root directory for test cases. Each test files must  ##
##  be use the following signature: tst_<test_name>.qml                                           ##
##                                                                                                ##
##  If the TEST_NAME argument is specified, then a custom test name will be associated with       ##
##  target in order to be used with ctest.                                                        ##
##                                                                                                ##
##  If the OTHER_FILES argument is specified, then the other files will be added to the target    ##
##  without to be compiled. This option is useful to append some extra files in the project view  ##
##  of an IDE, e.g., QtCreator.                                                                   ##
##                                                                                                ##
##  Using CTest, you can specify the "autotest" label in order to run only the autotests.         ##
##                                                                                                ##
##  Note: This function is targeting a C++14 compiler and Qt5 API.                                ##
##                                                                                                ##
####################################################################################################
function(STOIRIDH_QT_QML_ADD_AUTOTEST target)
    set(OVK "ALIAS" "DATA_DIR" "TEST_NAME")
    set(MVK "SOURCES" "DEPENDS" "OTHER_FILES")
    cmake_parse_arguments(STOIRIDH_COMMAND "" "${OVK}" "${MVK}" ${ARGN})

    # preconditions
    stoiridh_assert(STOIRIDH_COMMAND_DATA_DIR "DATA_DIR is not specified or is empty.")
    stoiridh_assert(STOIRIDH_COMMAND_DEPENDS "DEPENDS is not specified or is an empty list.")
    stoiridh_assert(STOIRIDH_COMMAND_SOURCES "SOURCES is not specified or is an empty list.")

    if(STOIRIDH_COMMAND_TEST_NAME)
        set(TEST_NAME "${STOIRIDH_COMMAND_TEST_NAME}")
    else()
        set(TEST_NAME "tst_${target}")
    endif()

    if(IS_ABSOLUTE ${STOIRIDH_COMMAND_DATA_DIR})
        set(DATA_DIR ${STOIRIDH_COMMAND_DATA_DIR})
    else()
        set(DATA_DIR "${CMAKE_CURRENT_LIST_DIR}/${STOIRIDH_COMMAND_DATA_DIR}")
    endif()

    if(NOT IS_DIRECTORY ${DATA_DIR})
        message(FATAL_ERROR "${DATA_DIR} is not a valid 'data' directory.")
    endif()

    # create the autotest executable
    stoiridh_qt_helper(APPLICATION ${target}
                       SOURCES ${STOIRIDH_COMMAND_SOURCES}
                       DEPENDS ${STOIRIDH_COMMAND_DEPENDS}
                       OTHER_FILES ${STOIRIDH_COMMAND_OTHER_FILES})

     # make an alias of the library for CMake use, e.g., <PROJECT_NAME>::<SUBPROJECT_NAME>.
     if(STOIRIDH_COMMAND_ALIAS)
         add_executable(${STOIRIDH_COMMAND_ALIAS} ALIAS ${target})
     endif()

     set(IMPORT_DIR "${STOIRIDH_INSTALL_ROOT}/${STOIRIDH_INSTALL_QML_DIR}")
     set(ARGUMENTS -input ${DATA_DIR} -import ${IMPORT_DIR})

     # add a test for target and set the LABELS property to "autotest" in order to act as a filter
     # with ctest (e.g., ctest -L "^autotest$").
     add_test(NAME ${TEST_NAME} COMMAND ${target} ${ARGUMENTS})
     set_tests_properties(${TEST_NAME} PROPERTIES LABELS "autotest")
endfunction()
