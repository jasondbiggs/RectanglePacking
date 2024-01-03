/*
 * CustomTypes.h
 *
 *  Created on: Oct 28, 2022
 *      Author: jasonb
 */

#ifndef CUSTOMTYPES_H_
#define CUSTOMTYPES_H_

#include "Rect.h"
#include <LLU/LLU.h>
#include <LLU/MArgumentManager.h>


#include <ManagedTypes.h>



namespace LLU {

template<>
struct MArgumentManager::Setter<rbp::Rect> {
	static void set(MArgumentManager& mngr, const rbp::Rect& rect) {
		LLU::Tensor<mint> res(0, {2, 2});
		res[{0, 0}] = rect.x;
		res[{0, 1}] = rect.y;
		res[{1, 0}] = rect.x + rect.width;
		res[{1, 1}] = rect.y + rect.height;
		mngr.setTensor(res);
	}
};



template<>
struct MArgumentManager::Setter<std::vector<rbp::Rect>> {
	static void set(MArgumentManager& mngr, const std::vector<rbp::Rect> &rects) {
		LLU::Tensor<mint> res(0, {(mint)rects.size(), 2, 2});
		for(auto i = 0; i < rects.size(); ++i) {
			res[{i, 0, 0}] = rects[i].x;
			res[{i, 0, 1}] = rects[i].y;
			res[{i, 1, 0}] = rects[i].x + rects[i].width;
			res[{i, 1, 1}] = rects[i].y + rects[i].height;
		}
		mngr.setTensor(res);
	}
};

template<>
struct MArgumentManager::Getter<std::vector<rbp::RectSize>> {
	static std::vector<rbp::RectSize> get(const MArgumentManager& mngr, size_type index) {
		auto rects = mngr.getTensor<mint>(index);
		std::vector<rbp::RectSize> res(rects.dimension(0));
		for(auto i = 0; i < res.size(); ++i) {
			res[i].width = rects.at({i, 0});
			res[i].height = rects.at({i, 1});
		}
		return std::move(res);
	}
};
}

#endif /* CUSTOMTYPES_H_ */
