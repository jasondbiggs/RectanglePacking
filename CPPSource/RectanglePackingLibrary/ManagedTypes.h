/*
 *
 *  Include this file in any source file that uses an expression store.
 */

#ifndef EXAMPLEPACLET_EXAMPLEPACLET_MANAGEDTYPES_H_
#define EXAMPLEPACLET_EXAMPLEPACLET_MANAGEDTYPES_H_

#include <LLU/LLU.h>

#define LIBRARY_NAMESPACE RectanglePackingLibrary

// Define all managed expressions here
#define MANAGED_CLASS_LIST                                 \
	MANAGED_CLASS(RectanglePackingLibrary::RectanglePacker, RectanglePackerStore, "WLRectanglePacker")
// Forward declare all the classes being managed



namespace LIBRARY_NAMESPACE {


class RectanglePacker;

// Declare the expression stores, which are created in ManagedTypes.cpp

#define MANAGED_CLASS(className, storeName, wlType) extern LLU::ManagedExpressionStore<className> storeName;
MANAGED_CLASS_LIST
#undef MANAGED_CLASS

// Declare the list of library exceptions

// clang-format off
const std::vector<std::pair<std::string, std::string>> libraryExceptionList = {
	{"StandardException", "Uncaught exception: `1`"},
	{"WrongLength", "Expecting a vector of length `2` instead of `1`"},
	{"InvalidRectangleParameter", "Invalid rectangle parameter `1`."},
	{"UnsupportedOperation", "Operation `2` is not supported in the `1` method."}
};
// clang-format on

}	 // namespace LIBRARY_NAMESPACE
#endif /* EXAMPLEPACLET_EXAMPLEPACLET_MANAGEDTYPES_H_ */
