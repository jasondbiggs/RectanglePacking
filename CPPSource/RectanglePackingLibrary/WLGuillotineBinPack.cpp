/*
 * WLGuillotineBinPack.cpp
 *
 *  Created on: Oct 28, 2022
 *      Author: jasonb
 */
#include "CustomTypes.h"
#include "GuillotineBinPack.h"
#include "LibraryLinkFunctionMacros/FunctionMacros.h"
#include "ManagedTypes.h"
#include "RectanglePackUtilities.h"
#include "WLRectanglePacker.h"

namespace {


/*
	Enumerate["FreeRectChoiceHeuristicGuillotine",
		{
			"BestAreaFit",
			"BestShortSideFit",
			"BestLongSideFit",
			"WorstAreaFit",
			"WorstShortSideFit",
			"WorstLongSideFit"
		}
	]
*/
std::string_view freeRectChoiceHeuristicName(const rbp::GuillotineBinPack::FreeRectChoiceHeuristic &in) {
	switch (in) {
		case rbp::GuillotineBinPack::RectBestAreaFit:
			return "BestAreaFit";
		case rbp::GuillotineBinPack::RectBestShortSideFit:
			return "BestShortSideFit";
		case rbp::GuillotineBinPack::RectBestLongSideFit:
			return "BestLongSideFit";
		case rbp::GuillotineBinPack::RectWorstAreaFit:
			return "WorstAreaFit";
		case rbp::GuillotineBinPack::RectWorstShortSideFit:
			return "WorstShortSideFit";
		case rbp::GuillotineBinPack::RectWorstLongSideFit:
			return "WorstLongSideFit";
	}
}

/*
	Enumerate["GuillotineSplitHeuristic",
		{
			"ShorterLeftoverAxis",
			"LongerLeftoverAxis",
			"MinimizeArea",
			"MaximizeArea",
			"ShorterAxis",
			"LongerAxis"
		}
	]
*/

std::string_view guillotineSplitHeuristicName(const rbp::GuillotineBinPack::GuillotineSplitHeuristic &in) {
	switch (in) {
		case rbp::GuillotineBinPack::SplitShorterLeftoverAxis:
			return "ShorterLeftoverAxis";
		case rbp::GuillotineBinPack::SplitLongerLeftoverAxis:
			return "LongerLeftoverAxis";
		case rbp::GuillotineBinPack::SplitMinimizeArea:
			return "MinimizeArea";
		case rbp::GuillotineBinPack::SplitMaximizeArea:
			return "MaximizeArea";
		case rbp::GuillotineBinPack::SplitShorterAxis:
			return "ShorterAxis";
		case rbp::GuillotineBinPack::SplitLongerAxis:
			return "LongerAxis";
	}
}


}

namespace LIBRARY_NAMESPACE {






class WLGuillotinePacker : public RectanglePacker {

public:

	WLGuillotinePacker(mint width, mint height, bool merge,
					   rbp::GuillotineBinPack::GuillotineSplitHeuristic split,
					   rbp::GuillotineBinPack::FreeRectChoiceHeuristic choice);

	LLU::Tensor<mint> getDimensions() override;

	rbp::Rect insertRectangle(const LLU::Tensor<mint> &dims) override;

	LLU::Tensor<mint> insertRectangles(const LLU::Tensor<mint> &inputTensor) override;

	double occupancy() override;

	void methodInformation(LLU::GenericDataList&) override;

	std::vector<rbp::Rect> &getUsedRectangles() override;

	std::vector<rbp::Rect> &getFreeRectangles() override;

	void placeRectangle(const LLU::Tensor<mint>&) override;

private:

	bool m_merge;
	rbp::GuillotineBinPack::GuillotineSplitHeuristic m_split;
	rbp::GuillotineBinPack::FreeRectChoiceHeuristic m_freeChoice;
	std::unique_ptr<rbp::GuillotineBinPack> m_ptr;


};


WLGuillotinePacker::WLGuillotinePacker(mint width, mint height, bool merge,
									   rbp::GuillotineBinPack::GuillotineSplitHeuristic split,
									   rbp::GuillotineBinPack::FreeRectChoiceHeuristic choice)
	: m_freeChoice(choice),
	  m_split(split),
	  m_merge(merge),
	  m_ptr(std::make_unique<rbp::GuillotineBinPack>(width, height))
{
}

LLU::Tensor<mint> WLGuillotinePacker::getDimensions() {
	LLU::Tensor<mint> res {(mint) m_ptr->getWidth(), (mint) m_ptr->getHeight()};
	return res;
}
rbp::Rect WLGuillotinePacker::insertRectangle(const LLU::Tensor<mint>& dims) {
	return m_ptr->Insert(dims.at(0), dims.at(1), m_merge, m_freeChoice, m_split);
}
LLU::Tensor<mint> WLGuillotinePacker::insertRectangles(const LLU::Tensor<mint>& inputTensor) {
	auto sizes = rectSizesFromTensor(inputTensor);
	auto res = m_ptr->Insert(sizes, m_merge, m_freeChoice, m_split);

	return sortedRectVecToTensor(res, inputTensor, true);
}
double WLGuillotinePacker::occupancy() {
	return m_ptr->Occupancy();
}

void WLGuillotinePacker::methodInformation(LLU::GenericDataList &dsIn) {
	dsIn.push_back("Method", "Guillotine");
	dsIn.push_back("MergeFreeRectangles", (bool) m_merge);
	dsIn.push_back("FreeChoiceHeuristic", freeRectChoiceHeuristicName(m_freeChoice));
	dsIn.push_back("SplitHeuristic", guillotineSplitHeuristicName(m_split));
}
std::vector<rbp::Rect>& WLGuillotinePacker::getUsedRectangles() {
	return m_ptr->GetUsedRectangles();
}
std::vector<rbp::Rect>& WLGuillotinePacker::getFreeRectangles() {
	return m_ptr->GetFreeRectangles();
}
void WLGuillotinePacker::placeRectangle(const LLU::Tensor<mint>&) {

	LLU::ErrorManager::throwException("UnsupportedOperation", "Guillotine", "PlaceRectangle");
}


/**
 * @brief    implements different variants of bin packer algorithms that use the \
 *           GUILLOTINE data structure to keep track of the free space of the bin where rectangles may be placed.
 *
 * @param    {Integer, "width"}
 * @param    {Integer, "height"}
 * @param    {"Boolean", "MergeFreeRectangles" -> True}
 *           If true, performs Rectangle Merge operations during the packing process.
 * @param    {enum["FreeRectChoiceHeuristicGuillotine"], "FreeChoiceHeuristic" -> "BestAreaFit"}
 *           The free rectangle choice heuristic rule to use, allowed options are
 *           {
				"BestAreaFit",
				"BestShortSideFit",
				"BestLongSideFit",
				"WorstAreaFit",
				"WorstShortSideFit",
				"WorstLongSideFit"
				}
 * @param    {enum["GuillotineSplitHeuristic"], "SplitHeuristic" -> "ShorterLeftoverAxis"}
 *           The free rectangle split heuristic rule to use, options include
 *           {
				"ShorterLeftoverAxis",
				"LongerLeftoverAxis",
				"MinimizeArea",
				"MaximizeArea",
				"ShorterAxis",
				"LongerAxis"
				}
 * @return   Managed[WLRectanglePacker]
 */
BEGIN_LIBRARY_FUNCTION(GuillotinePacker) {
	auto width = mngr.getInteger<int>(arg++);
	auto height = mngr.getInteger<int>(arg++);
	CHECK_NUMBER(width)
	CHECK_NUMBER(height)

	auto merge = mngr.getBoolean(arg++);
	auto freechoice = mngr.getInteger<rbp::GuillotineBinPack::FreeRectChoiceHeuristic>(arg++);
	auto split = mngr.getInteger<rbp::GuillotineBinPack::GuillotineSplitHeuristic>(arg++);

	auto res = std::make_shared<WLGuillotinePacker>(width, height, merge, split, freechoice);

	RectanglePackerStore.createInstance(mngr.getInteger<mint>(arg++), std::static_pointer_cast<RectanglePacker>(res));
}
END_LIBRARY_FUNCTION

}
