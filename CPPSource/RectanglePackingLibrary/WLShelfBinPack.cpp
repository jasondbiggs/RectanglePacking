/*
 * WLShelfBinPack.cpp
 *
 *  Created on: Oct 28, 2022
 *      Author: jasonb
 */
#include "CustomTypes.h"
#include "LibraryLinkFunctionMacros/FunctionMacros.h"
#include "LibraryLinkFunctionMacros/WLPrint.h"
#include "ManagedTypes.h"
#include "RectanglePackUtilities.h"
#include "ShelfBinPack.h"
#include "WLRectanglePacker.h"

namespace {

std::string_view shelfChoiceHeuristicName(const rbp::ShelfBinPack::ShelfChoiceHeuristic &in) {
	switch (in) {
		case rbp::ShelfBinPack::ShelfNextFit:
			return "NextFit";
		case rbp::ShelfBinPack::ShelfFirstFit:
			return "FirstFit";
		case rbp::ShelfBinPack::ShelfBestAreaFit:
			return "BestAreaFit";
		case rbp::ShelfBinPack::ShelfWorstAreaFit:
			return "WorstAreaFit";
		case rbp::ShelfBinPack::ShelfBestHeightFit:
			return "BestHeightFit";
		case rbp::ShelfBinPack::ShelfBestWidthFit:
			return "BestWidthFit";
		case rbp::ShelfBinPack::ShelfWorstWidthFit:
			return "WorstWidthFit";
	}
}


}

namespace LIBRARY_NAMESPACE {


/*
	Enumerate["ShelfChoiceHeuristic",
		{
			"NextFit",
			"FirstFit",
			"BestAreaFit",
			"WorstAreaFit",
			"BestHeightFit",
			"BestWidthFit",
			"WorstWidthFit"
		}
	]
 */


class WLShelfPacker : public RectanglePacker {
	
public:

	WLShelfPacker(mint width, mint height, bool useWasteMap,
					   rbp::ShelfBinPack::ShelfChoiceHeuristic choice);

	LLU::Tensor<mint> getDimensions() override;

	rbp::Rect insertRectangle(const LLU::Tensor<mint> &dims) override;

	LLU::Tensor<mint> insertRectangles(const LLU::Tensor<mint> &inputTensor) override;

	double occupancy() override;

	void methodInformation(LLU::GenericDataList&) override;

	std::vector<rbp::Rect> &getUsedRectangles() override;

	std::vector<rbp::Rect> &getFreeRectangles() override;

	void placeRectangle(const LLU::Tensor<mint>&) override;

	std::vector<rbp::Rect> m_insertedRectangles;

private:

	bool m_useWasteMap;
	rbp::ShelfBinPack::ShelfChoiceHeuristic m_freeChoice;
	std::unique_ptr<rbp::ShelfBinPack> m_ptr;


};





WLShelfPacker::WLShelfPacker(mint width, mint height, bool useWasteMap,
							 rbp::ShelfBinPack::ShelfChoiceHeuristic choice)
	: m_freeChoice(choice),
	  m_useWasteMap(useWasteMap),
	  m_ptr(std::make_unique<rbp::ShelfBinPack>(width, height, useWasteMap))
{
}

LLU::Tensor<mint> WLShelfPacker::getDimensions() {
	LLU::Tensor<mint> res {(mint) m_ptr->getWidth(), (mint) m_ptr->getHeight()};
	return res;
}
rbp::Rect WLShelfPacker::insertRectangle(const LLU::Tensor<mint>& dims) {
	auto res = m_ptr->Insert(dims.at(0), dims.at(1), m_freeChoice);
	m_insertedRectangles.emplace_back(res);

	return res;
}
LLU::Tensor<mint> WLShelfPacker::insertRectangles(const LLU::Tensor<mint>& inputTensor) {
	auto rects = rectSizesFromTensor(inputTensor);
	std::vector<rbp::Rect> res;
	res.reserve(rects.size());

	for(auto &rect : rects) {
		auto inserted = res.emplace_back(m_ptr->Insert(rect.width, rect.height, m_freeChoice));
		m_insertedRectangles.emplace_back(inserted);
	}

	return sortedRectVecToTensor(res, inputTensor, true);
}
double WLShelfPacker::occupancy() {
	return m_ptr->Occupancy();
}

void WLShelfPacker::methodInformation(LLU::GenericDataList &dsIn) {
	dsIn.push_back("Method", "Shelf");
	dsIn.push_back("UseWasteMap", (bool) m_useWasteMap);
	dsIn.push_back("FreeChoiceHeuristic", shelfChoiceHeuristicName(m_freeChoice));
}
std::vector<rbp::Rect>& WLShelfPacker::getUsedRectangles() {
	return m_insertedRectangles;
}
std::vector<rbp::Rect>& WLShelfPacker::getFreeRectangles() {
	LLU::ErrorManager::throwException("UnsupportedOperation", "Shelf", "GetFreeRectangles");
}
void WLShelfPacker::placeRectangle(const LLU::Tensor<mint>&) {

	LLU::ErrorManager::throwException("UnsupportedOperation", "Shelf", "PlaceRectangle");
}




/**
 * @brief    ShelfBinPack implements different bin packing algorithms that use the SHELF \
 *           data structure. ShelfBinPack also uses GuillotineBinPack for the waste map if it is enabled.
 *
 * @param    {Integer, "width"}
 * @param    {Integer, "height"}
 * @param    {"Boolean", "UseWasteMap" -> True}
 *           If true, uses GuillotineBinPack for the waste map.
 * @param    {enum["ShelfChoiceHeuristic"], "FreeChoiceHeuristic" -> "BestAreaFit"}
 *           The free rectangle choice heuristic rule to use, allowed options are
 *           {
				"NextFit",
				"FirstFit",
				"BestAreaFit",
				"WorstAreaFit",
				"BestHeightFit",
				"BestWidthFit",
				"WorstWidthFit"
 * @return   Managed[WLRectanglePacker]
 */
BEGIN_LIBRARY_FUNCTION(ShelfPacker) {
	auto width = mngr.getInteger<int>(arg++);
	auto height = mngr.getInteger<int>(arg++);

	auto useWaste = mngr.getBoolean(arg++);

	auto freechoice = mngr.getInteger<rbp::ShelfBinPack::ShelfChoiceHeuristic>(arg++);

	auto res = std::make_shared<WLShelfPacker>(width, height, useWaste, freechoice);

	RectanglePackerStore.createInstance(mngr.getInteger<mint>(arg++), std::static_pointer_cast<RectanglePacker>(res));
}
END_LIBRARY_FUNCTION

}




