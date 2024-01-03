/*
 * WLSkylineBinPack.cpp
 *
 *  Created on: Oct 28, 2022
 *      Author: jasonb
 */
#include "SkylineBinPack.h"
#include "LibraryLinkFunctionMacros/FunctionMacros.h"
#include "ManagedTypes.h"
#include "RectanglePackUtilities.h"


#include "WLRectanglePacker.h"

namespace {


/*
	Enumerate["LevelChoiceHeuristic",
		{
			"BottomLeft",
			"BestFit"
		}
	]
*/


std::string_view levelChoiceHeurisicName(const rbp::SkylineBinPack::LevelChoiceHeuristic &in) {
	switch(in) {
		case rbp::SkylineBinPack::LevelBottomLeft:
			return "BottomLeft";
		case rbp::SkylineBinPack::LevelMinWasteFit:
			return "BestFit";
	}
}


}

namespace LIBRARY_NAMESPACE {


class WLSkylinePacker : public RectanglePacker {

public:

	WLSkylinePacker(mint width, mint height, bool useWasteMap,
					   rbp::SkylineBinPack::LevelChoiceHeuristic choice);

	LLU::Tensor<mint> getDimensions() override;

	rbp::Rect insertRectangle(const LLU::Tensor<mint> &dims) override;

	LLU::Tensor<mint> insertRectangles(const LLU::Tensor<mint> &inputTensor) override;

	double occupancy() override;

	void methodInformation(LLU::GenericDataList&) override;

	std::vector<rbp::Rect> &getUsedRectangles() override;

	std::vector<rbp::Rect> &getFreeRectangles() override;

	void placeRectangle(const LLU::Tensor<mint>&) override;

	std::vector<rbp::Rect> insertedRectangles;

private:

	mint m_width;
	mint m_height;
	bool m_useWasteMap;
	rbp::SkylineBinPack::LevelChoiceHeuristic m_choice;
	std::unique_ptr<rbp::SkylineBinPack> m_ptr;


};





WLSkylinePacker::WLSkylinePacker(mint width, mint height, bool useWasteMap,
								 rbp::SkylineBinPack::LevelChoiceHeuristic choice)
	: m_choice(choice),
	  m_useWasteMap(useWasteMap),
	  m_height(height),
	  m_width(width),
	  m_ptr(std::make_unique<rbp::SkylineBinPack>(width, height, useWasteMap))
{
}

LLU::Tensor<mint> WLSkylinePacker::getDimensions() {
	LLU::Tensor<mint> res {m_width, m_height};
	return res;
}
rbp::Rect WLSkylinePacker::insertRectangle(const LLU::Tensor<mint>& dims) {

	auto res = m_ptr->Insert(dims.at(0), dims.at(1), m_choice);
	insertedRectangles.emplace_back(res);
	return res;
}
LLU::Tensor<mint> WLSkylinePacker::insertRectangles(const LLU::Tensor<mint>& inputTensor) {
	auto sizes = rectSizesFromTensor(inputTensor);
	std::vector<rbp::Rect> res;

	m_ptr->Insert(sizes, res, m_choice);
	for(const auto &rect : res) {
		insertedRectangles.emplace_back(rect);
	}
	return sortedRectVecToTensor(res, inputTensor, true);
}
double WLSkylinePacker::occupancy() {
	return m_ptr->Occupancy();
}

void WLSkylinePacker::methodInformation(LLU::GenericDataList &dsIn) {
	dsIn.push_back("Method", "Skyline");
	dsIn.push_back("UseWasteMap", (bool) m_useWasteMap);
	dsIn.push_back("FreeChoiceHeuristic", levelChoiceHeurisicName(m_choice));
}
std::vector<rbp::Rect>& WLSkylinePacker::getUsedRectangles() {
	return insertedRectangles;
}
std::vector<rbp::Rect>& WLSkylinePacker::getFreeRectangles() {
	LLU::ErrorManager::throwException("UnsupportedOperation", "Shelf", "GetFreeRectangles");
}
void WLSkylinePacker::placeRectangle(const LLU::Tensor<mint>&) {

	LLU::ErrorManager::throwException("UnsupportedOperation", "Skyline", "PlaceRectangle");
}


/**
 * @brief    Implements bin packing algorithms that use the SKYLINE data structure to store the bin contents. Uses \
 *           GuillotineBinPack as the waste map.
 *
 * @param    {Integer, "width"}
 * @param    {Integer, "height"}
 * @param    {"Boolean", "UseWasteMap" -> True}
 *           If true, uses GuillotineBinPack for the waste map.
 * @param    {enum["LevelChoiceHeuristic"], "FreeChoiceHeuristic" -> "BestFit"}
 *           The free rectangle choice heuristic rule to use, allowed options are
 *           {
				"BottomLeft",
                "BestFit"
				}

 * @return   Managed[WLRectanglePacker]
 */
BEGIN_LIBRARY_FUNCTION(SkylinePacker) {
	auto width = mngr.getInteger<int>(arg++);
	auto height = mngr.getInteger<int>(arg++);

	auto useWaste = mngr.getBoolean(arg++);

	auto freechoice = mngr.getInteger<rbp::SkylineBinPack::LevelChoiceHeuristic>(arg++);

	auto res = std::make_shared<WLSkylinePacker>(width, height, useWaste, freechoice);

	RectanglePackerStore.createInstance(mngr.getInteger<mint>(arg++), std::static_pointer_cast<RectanglePacker>(res));
}
END_LIBRARY_FUNCTION

}
