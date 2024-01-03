################################################################################
######
###### RectanglePacking Project Configuration File
######
################################################################################

cmake_minimum_required(VERSION 3.14.0)

project(RectanglePacking
		VERSION     0.0.1
		DESCRIPTION "RectanglePacking."
		LANGUAGES   CXX
)

set(PACKAGE_NAME "RectanglePacking")
set(LIBRARY_NAME "RectanglePackingLibrary")

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel." FORCE)
endif()


set(CPP_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/CPPSource")

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set(CMAKE_BUILD_WITH_INSTALL_RPATH ON)

    set(CMAKE_INSTALL_PREFIX "${CMAKE_CURRENT_SOURCE_DIR}" CACHE PATH "Paclet install prefix" FORCE)
endif()


set(TARGET_PACLET_DIRECTORY "${CMAKE_INSTALL_PREFIX}")
message("target install directory: ${TARGET_PACLET_DIRECTORY}") 

#=============================================
#=============== FIND LLU ====================
#=============================================

set(LLU_SOURCE_DIR "${CPP_SOURCE_DIR}/LibraryLinkUtilities")
set(LLU_INSTALL_DIR "${CMAKE_BINARY_DIR}/LLU" CACHE PATH "Location of LLU installation.")
	
# If LLU is not installed on the system, try building from sources
if(NOT EXISTS "${LLU_INSTALL_DIR}")
	include("${LLU_SOURCE_DIR}/cmake/Wolfram/Common.cmake")
	if(NOT EXISTS "${LLU_SOURCE_DIR}")
		# Here we could also checkout the appropriate version of LLU from Stash
		message(FATAL_ERROR "A path to LLU installation or LLU sources must be provided.")
	endif()
	
	message(STATUS "Building LLU from sources.")
	
	# Choose build directory for LLU.
	set(LLU_BUILD_DIR "${CMAKE_BINARY_DIR}/LLU/build")
	file(MAKE_DIRECTORY "${LLU_BUILD_DIR}")
	
	# Configure LLU
	set(LLU_CMAKE_OPTS
		"-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}"
		"-DCMAKE_INSTALL_PREFIX=${LLU_INSTALL_DIR}"
		"-DWolframLanguage_INSTALL_DIR=${WolframLanguage_INSTALL_DIR}"
	)
	
	list(APPEND LLU_CMAKE_OPTS -G ${CMAKE_GENERATOR})
	if(CMAKE_GENERATOR_TOOLSET)
		list(APPEND LLU_CMAKE_OPTS -T ${CMAKE_GENERATOR_TOOLSET})
	endif()
	if(CMAKE_GENERATOR_PLATFORM)
		list(APPEND LLU_CMAKE_OPTS -A ${CMAKE_GENERATOR_PLATFORM})
	endif()
	
	execute_process(
		COMMAND ${CMAKE_COMMAND} ${LLU_CMAKE_OPTS} "${LLU_SOURCE_DIR}"
		WORKING_DIRECTORY "${LLU_BUILD_DIR}"
	)
	# Build and install LLU
	set_from_env(JLLU _JLLU)
	if(_JLLU)
		set(_JLLU "-j${_JLLU}")
	endif()
	execute_process(
		COMMAND ${CMAKE_COMMAND} --build "${LLU_BUILD_DIR}" --config ${CMAKE_BUILD_TYPE} --target install ${_JLLU}
	)
endif()
	
# Add cmake scripts distributed with LLU to cmake prefix path
set(CMAKE_PREFIX_PATH "${LLU_INSTALL_DIR}/cmake")


find_package(LLU REQUIRED)



detect_system_id(SYSTEM_ID)
detect_system_id(SYSTEMID)


set(WL_CODE_GENERATOR "${CMAKE_CURRENT_SOURCE_DIR}/scripts/GetFunctions.m")
set(WL_RESOURCE_BUILDER "${CMAKE_CURRENT_SOURCE_DIR}/scripts/BuildPacletResources.m")
set(RESOURCE_BUILD_DIR "${TARGET_PACLET_DIRECTORY}/${PACKAGE_NAME}/Resources")
set(INTERNAL_COMPONENTS_DIR "${CMAKE_CURRENT_SOURCE_DIR}/Components")


set(WL_CODE_GENERATOR "${CMAKE_CURRENT_SOURCE_DIR}/scripts/LibraryLinkCodeGenerator/LibraryLinkCodeGenerator.m")
set(WL_DEFINITION_FILE "${CMAKE_CURRENT_SOURCE_DIR}/${PACKAGE_NAME}/Kernel/${LIBRARY_NAME}.wl")


#=============================================
#=========== MAIN PACLET LIBRARY =============
#=============================================


# define source files
set(RECTANGLEBINPACK_SOURCE_DIR "${CPP_SOURCE_DIR}/RectangleBinPack/")
add_subdirectory(${RECTANGLEBINPACK_SOURCE_DIR})

set(RECTANGLEBINPACKLINK_SOURCE_DIR "${CPP_SOURCE_DIR}/RectanglePackingLibrary/")

add_subdirectory(${RECTANGLEBINPACKLINK_SOURCE_DIR})



include("${CMAKE_CURRENT_SOURCE_DIR}/scripts/WolframKernel.cmake")
message("found wolfram kernel")
message("${WOLFRAMKERNEL_DEFAULT}")

set(WL_CODE
			[===[
			params = <|"LibraryName" -> "${LIBRARY_NAME}", "LibraryContext" -> "RectanglePackingLibrary`", "Pretty" -> True|>;
			res = Catch[
				Get @ "${WL_CODE_GENERATOR}";
				GetFunctions`WriteLibrarySignatures[
				StringSplit["${RECTANGLEBINPACKLINK_SOURCE_FILES}",";"],
				"${WL_DEFINITION_FILE}", params
			], _];
			If[FailureQ[res], 
				Exit[1], 
				Exit[0]
			]
			]===])

string(REGEX REPLACE "[\t\r\n]+" "" WL_CODE "${WL_CODE}")
string(CONFIGURE "${WL_CODE}" WL_CODE)


message("ws: " "${WolframLanguage_wolframscript_EXE}")

add_custom_target(wlcode
	COMMAND ${WOLFRAMKERNEL_DEFAULT} -run "${WL_CODE}"
	COMMENT "Generating WL source code"
	VERBATIM
)

set(TESTFILE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/Tests/")
add_subdirectory("${TESTFILE_DIR}")

if(NOT ${TARGET_PACLET_DIRECTORY} EQUAL "${CMAKE_CURRENT_SOURCE_DIR}")
	install(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/${PACKAGE_NAME}/Kernel/"
		DESTINATION "${TARGET_PACLET_DIRECTORY}/${PACKAGE_NAME}/Kernel"
		FILES_MATCHING PATTERN "*.wl"
	)
	install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/${PACKAGE_NAME}/PacletInfo.wl"
		DESTINATION "${TARGET_PACLET_DIRECTORY}/${PACKAGE_NAME}"
	)
endif()


