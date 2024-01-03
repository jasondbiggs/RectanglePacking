/*
 * RectanglePackUtilities.h
 *
 *  Created on: Feb 2, 2023
 *      Author: jasonb
 */

#ifndef RECTANGLEBINPACKLINKUTILITIES_H_
#define RECTANGLEBINPACKLINKUTILITIES_H_


#include "ManagedTypes.h"


namespace rbp {

struct Rect;
struct RectSize;
}

namespace LIBRARY_NAMESPACE {



LLU::Tensor<mint> sortedRectVecToTensor(std::vector<rbp::Rect> &packedRects, const LLU::Tensor<mint> &inputSizes,
	                                 bool allowFlip = true);


std::vector<rbp::RectSize> rectSizesFromTensor(const LLU::Tensor<mint>& rectangles);

LLU::Tensor<mint> rectToTensor(const rbp::Rect &input);


}


#endif /* RECTANGLEBINPACKLINKUTILITIES_H_ */
