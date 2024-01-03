################################################################################
######
###### LLU Demo Project Configuration File
######
################################################################################

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel." FORCE)
endif()


file(GLOB_RECURSE RECTANGLEBINPACKLINK_SOURCE_FILES "${RECTANGLEBINPACKLINK_SOURCE_DIR}/*.cpp")
set(RECTANGLEBINPACKLINK_SOURCE_FILES ${RECTANGLEBINPACKLINK_SOURCE_FILES} PARENT_SCOPE)

#add the main library
add_library(RectanglePackingLibrary SHARED ${RECTANGLEBINPACKLINK_SOURCE_FILES})

set_property(TARGET RectanglePackingLibrary PROPERTY PREFIX "")

set_target_properties(RectanglePackingLibrary PROPERTIES
		CXX_STANDARD 17
		CXX_STANDARD_REQUIRED YES
		CXX_EXTENSIONS NO
)


if(UNIX AND NOT APPLE)
	target_link_libraries(RectanglePackingLibrary PRIVATE 
	        LLU::LLU
	        RectangleBinPack::RectangleBinPack
	)
else()
	target_link_libraries(RectanglePackingLibrary PRIVATE 
		LLU::LLU
		RectangleBinPack::RectangleBinPack
	)
endif()

target_include_directories(RectanglePackingLibrary PUBLIC 
	"${RECTANGLEBINPACKLINK_SOURCE_DIR}"
)

if(WIN32)
	target_compile_options(RectanglePackingLibrary PRIVATE /EHsc)
	target_compile_options(RectanglePackingLibrary PRIVATE /DWIN32)
	target_compile_options(RectanglePackingLibrary PRIVATE /wd4244)
	target_compile_options(RectanglePackingLibrary PRIVATE /DNOMINMAX)
	target_compile_options(RectanglePackingLibrary PRIVATE /MT)
endif()

message("the target paclet dir is ${TARGET_PACLET_DIRECTORY}")

install(TARGETS RectanglePackingLibrary
        CONFIGURATIONS Release
        DESTINATION "${TARGET_PACLET_DIRECTORY}/${PACKAGE_NAME}/LibraryResources/${SYSTEM_ID}"
)
