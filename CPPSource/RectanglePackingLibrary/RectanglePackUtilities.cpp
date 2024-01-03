/*
 * RectanglePackUtilities.cpp
 *
 *  Created on: Feb 2, 2023
 *      Author: jasonb
 */

#include "RectanglePackUtilities.h"
#include "MaxRectsBinPack.h"

namespace {

bool addRectWithDims(std::vector<rbp::Rect> &packedRects, const LLU::Tensor<mint> &inputSizes, LLU::Tensor<mint>& res,
	                 unsigned int rectIdx, bool allowFlip) {
	auto width = inputSizes.at({rectIdx, 0});
	auto height = inputSizes.at({rectIdx, 1});
	for(unsigned int i = 0; i < packedRects.size(); i++ ) {
		auto *rect = &(packedRects[i]);
		if( (rect->width == width && rect->height == height) ||
			(allowFlip && (rect->width == height && rect->height == width)) ) {
			res[{rectIdx, 0, 0}] = rect->x;
			res[{rectIdx, 0, 1}] = rect->y;
			res[{rectIdx, 1, 0}] = rect->x + rect->width;
			res[{rectIdx, 1, 1}] = rect->y + rect->height;
			packedRects.erase(packedRects.begin() + i);
			return true;
		}
	}
	return false;
}

}

namespace LIBRARY_NAMESPACE {


LLU::Tensor<mint> sortedRectVecToTensor(std::vector<rbp::Rect> &packedRects, const LLU::Tensor<mint> &inputSizes,
	                                 bool allowFlip) {
	mint len = inputSizes.dimension(0);
	LLU::Tensor<mint> res(0, {len, 2, 2});
	for(unsigned int num = 0; num < len; ++num) {
		addRectWithDims(packedRects, inputSizes, res, num, allowFlip);
	}
	return res;
}

std::vector<rbp::RectSize> rectSizesFromTensor(const LLU::Tensor<mint>& rectangles) {
	auto nrows = rectangles.dimension(0);
	std::vector<rbp::RectSize> res(nrows);

	mint idx = 0;
	for(auto &rect : res) {
		rect.width = rectangles.at({idx, 0});
		rect.height = rectangles.at({idx, 1});
		++idx;
	}

	return res;
}

LLU::Tensor<mint> rectToTensor(const rbp::Rect &rect) {
	LLU::Tensor<mint> res(0, {2, 2});
	if(!(rect.width && rect.height)) {
		return res;
	}
	res[{0, 0}] = rect.x;
	res[{0, 1}] = rect.y;
	res[{1, 0}] = rect.x + rect.width;
	res[{1, 1}] = rect.y + rect.height;
	return res;
}

}

