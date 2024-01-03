//
// Created by Jason Biggs on 1/1/24.
//

#ifndef RECTANGLEPACKING_WLRECTANGLEPACKER_H
#define RECTANGLEPACKING_WLRECTANGLEPACKER_H

#include "Rect.h"
#include "LibraryLinkFunctionMacros/FunctionMacros.h"
#include "MaxRectsBinPack.h"

namespace rbp {

class Rect;
class GuillotineBinPack;



}


namespace RectanglePackingLibrary {


class RectanglePacker {

protected:
	RectanglePacker() = default;;

public:
	virtual ~RectanglePacker() = default;;

	virtual LLU::Tensor<mint> getDimensions() = 0;

	virtual rbp::Rect insertRectangle(const LLU::Tensor<mint> &dims) = 0;

	virtual LLU::Tensor<mint> insertRectangles(const LLU::Tensor<mint> &dims) = 0;

	virtual double occupancy() = 0;

	virtual void methodInformation(LLU::GenericDataList&) = 0;

	virtual std::vector<rbp::Rect> &getUsedRectangles() = 0;

	virtual std::vector<rbp::Rect> &getFreeRectangles() = 0;

	virtual void placeRectangle(const LLU::Tensor<mint> &dims) = 0;

};


}


#endif	  //RECTANGLEPACKING_WLRECTANGLEPACKER_H
