//
// Created by Jason Biggs on 1/1/24.
//

#include "CustomTypes.h"
#include "LibraryLinkFunctionMacros/FunctionMacros.h"
#include "ManagedTypes.h"

#include "WLRectanglePacker.h"
#include "RectanglePackUtilities.h"

namespace LIBRARY_NAMESPACE {





/**
 * @brief    inserts a single rectangle.
 *
 * @param    {{Integer, 1}, "rectangle"}
 *           a list of {width, height} for the rectangle to be inserted.
 * @return   {Integer, 2}
 *           Returns a list {{x1, y1}, {x2, y2}} representing the inserted rectangle.
 */
MEMBER_FUNCTION(WLRectanglePacker_InsertRectangle) {

	auto& obj = RectanglePackerStore.getInstance(mngr.getInteger<mint>(arg++));
	auto input = mngr.getTensor<mint>(arg++);
	auto res = obj.insertRectangle(input);

	mngr.set(res);
}
END_LIBRARY_FUNCTION

/**
 * @brief    computes the ratio of used/total surface area. \
 *           0.00 means no space is yet used, 1.00 means the whole bin is used.
 * @return   Real
 */
MEMBER_FUNCTION(WLRectanglePacker_GetOccupancy) {
	auto& obj = RectanglePackerStore.getInstance(mngr.getInteger<mint>(arg++));
	mngr.setReal(obj.occupancy());
}
END_LIBRARY_FUNCTION

/**
 * @brief    inserts a list of rectangles.
 *
 * @param    {{Integer, 2}, "rects"}
 *           list of {width, height} pairs
 * @return   {Integer, 3}
 */
MEMBER_FUNCTION(WLRectanglePacker_InsertRectangles) {

	auto& obj = RectanglePackerStore.getInstance(mngr.getInteger<mint>(arg++));
	auto inputTensor = mngr.get<LLU::Tensor<mint>>(arg++);
	auto len = inputTensor.getFlattenedLength();
	for(auto i = 0; i < len; ++i) {
		CHECK_NUMBER(inputTensor[i]);
	}
	mngr.set(obj.insertRectangles(inputTensor));
}
END_LIBRARY_FUNCTION


/**
 * @brief    places a single rectangle in the list of used rectangles and adjusts the
 *           free rectangles accordingly.
 * @param    {{Integer, 2}, "rect"}
 *
 * @return  "Void"
 */
MEMBER_FUNCTION(WLRectanglePacker_PlaceRectangle) {
	auto& obj = RectanglePackerStore.getInstance(mngr.getInteger<mint>(arg++));
	const auto& rectData = mngr.getTensor<mint>(arg++);
	auto len = rectData.getFlattenedLength();
	for(auto i = 0; i < len; ++i) {
		CHECK_NUMBER(rectData[i]);
	}
	obj.placeRectangle(rectData);
}
END_LIBRARY_FUNCTION

/**
 * @brief    returns the internal list of disjoint rectangles that track the free area of the bin. \
 * @return   {Integer, 3}
 */
MEMBER_FUNCTION(WLRectanglePacker_GetFreeRectangles) {
	auto& obj = RectanglePackerStore.getInstance(mngr.getInteger<mint>(arg++));
	const auto& rectangles = obj.getFreeRectangles();

	mngr.set(rectangles);
}
END_LIBRARY_FUNCTION

/**
 * @brief    returns the list of packed rectangles.
 * @return   {Integer, 3}
 */
MEMBER_FUNCTION(WLRectanglePacker_GetUsedRectangles) {
	auto& obj = RectanglePackerStore.getInstance(mngr.getInteger<mint>(arg++));
	const auto& rectangles = obj.getUsedRectangles();

	mngr.set(rectangles);
}
END_LIBRARY_FUNCTION

/**
 * @brief    returns the bounding box dimensions {w,h}.
 * @return   {Integer, 1}
 */
MEMBER_FUNCTION(WLRectanglePacker_GetDimensions) {
	auto& obj = RectanglePackerStore.getInstance(mngr.getInteger<mint>(arg++));
	mngr.set(obj.getDimensions());
}
END_LIBRARY_FUNCTION

/**
 * @brief    gives object information.
 * @return   "DataStore"
 */
MEMBER_FUNCTION(WLRectanglePacker_information) {
	auto& obj = RectanglePackerStore.getInstance(mngr.getInteger<mint>(arg++));
	LLU::GenericDataList dsOut;
	dsOut.push_back("Dimensions", obj.getDimensions());
	dsOut.push_back("Occupancy", obj.occupancy());
	dsOut.push_back("Packed", (mint) obj.getUsedRectangles().size());
	obj.methodInformation(dsOut);


	mngr.set(dsOut);
}
END_LIBRARY_FUNCTION

/**
 * @brief    returns the number of packed rectangles
 * @return   Integer
 */
MEMBER_FUNCTION(WLRectanglePacker_GetPackedRectangleCount) {
	auto& obj = RectanglePackerStore.getInstance(mngr.getInteger<mint>(arg++));
	mngr.set((mint) obj.getUsedRectangles().size());
}
END_LIBRARY_FUNCTION

}