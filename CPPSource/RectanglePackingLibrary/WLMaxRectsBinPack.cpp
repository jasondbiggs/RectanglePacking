/*
 * WLMaxRectsBinPack.cpp
 *
 *  Created on: Oct 28, 2022
 *      Author: jasonb
 */
#include "CustomTypes.h"
#include "LibraryLinkFunctionMacros/FunctionMacros.h"
#include "ManagedTypes.h"
#include "MaxRectsBinPack.h"
#include "RectanglePackUtilities.h"
#include "WLRectanglePacker.h"

namespace {

void check() { LLU::ProgressMonitor::checkAbort(); }


/*
	Enumerate["FreeRectChoiceHeuristic",
		{
			"BestShortSideFit",
			"BestLongSideFit",
			"BestAreaFit",
			"BottomLeftRule",
			"ContactPointRule"
		}
	]
*/

std::string_view freeRectChoiceHeuristicName(const rbp::MaxRectsBinPack::FreeRectChoiceHeuristic &in) {
	switch (in) {
		case rbp::MaxRectsBinPack::RectBestShortSideFit:
			return "BestShortSideFit";
		case rbp::MaxRectsBinPack::RectBestLongSideFit:
			return "BestLongSideFit";
		case rbp::MaxRectsBinPack::RectBestAreaFit:
			return "BestAreaFit";
		case rbp::MaxRectsBinPack::RectBottomLeftRule:
			return "BottomLeftRule";
		case rbp::MaxRectsBinPack::RectContactPointRule:
			return "ContactPointRule";
	}
}

}	 // namespace

namespace LIBRARY_NAMESPACE {




class WLMaxRectcsPacker : public RectanglePacker {

public:

	WLMaxRectcsPacker(mint width, mint height, bool allowFlips, rbp::MaxRectsBinPack::FreeRectChoiceHeuristic);

	LLU::Tensor<mint> getDimensions() override;

	rbp::Rect insertRectangle(const LLU::Tensor<mint> &dims) override;

	LLU::Tensor<mint> insertRectangles(const LLU::Tensor<mint> &dims) override;

	double occupancy() override;

	void methodInformation(LLU::GenericDataList &dsIn) override;

	std::vector<rbp::Rect> &getUsedRectangles() override;

	std::vector<rbp::Rect> &getFreeRectangles() override;

	void placeRectangle(const LLU::Tensor<mint> &dims) override;

private:


	rbp::MaxRectsBinPack::FreeRectChoiceHeuristic m_freeChoice;
	std::unique_ptr<rbp::MaxRectsBinPack> m_ptr;


};





WLMaxRectcsPacker::WLMaxRectcsPacker(mint width, mint height, bool allowFlips,
									 rbp::MaxRectsBinPack::FreeRectChoiceHeuristic freeChoice)
	: m_freeChoice(freeChoice),
	  m_ptr(std::make_unique<rbp::MaxRectsBinPack>(width, height, allowFlips))
{
}

LLU::Tensor<mint> WLMaxRectcsPacker::getDimensions() {
	LLU::Tensor<mint> res {(mint) m_ptr->getWidth(), (mint) m_ptr->getHeight()};
	return res;
}
rbp::Rect WLMaxRectcsPacker::insertRectangle(const LLU::Tensor<mint>& dims) {
	return m_ptr->Insert(dims.at(0), dims.at(1), m_freeChoice);
}
LLU::Tensor<mint> WLMaxRectcsPacker::insertRectangles(const LLU::Tensor<mint>& inputTensor) {
	auto sizes = rectSizesFromTensor(inputTensor);

	std::vector<rbp::Rect> res;

	m_ptr->Insert(sizes, res, m_freeChoice, &LLU::ProgressMonitor::checkAbort);
	return sortedRectVecToTensor(res, inputTensor, m_ptr->getAllowFlip());
}
double WLMaxRectcsPacker::occupancy() { return m_ptr->Occupancy(); }

void WLMaxRectcsPacker::methodInformation(LLU::GenericDataList &dsIn) {
	dsIn.push_back("Method", "MaxRectangles");
	dsIn.push_back("AllowFlips", (bool) m_ptr->getAllowFlip());
	dsIn.push_back("FreeChoiceHeuristic", freeRectChoiceHeuristicName(m_freeChoice));
}
std::vector<rbp::Rect>& WLMaxRectcsPacker::getUsedRectangles() {
	return m_ptr->GetUsedRectangles();
}
std::vector<rbp::Rect>& WLMaxRectcsPacker::getFreeRectangles() {
	return m_ptr->GetFreeRectangles();
}
void WLMaxRectcsPacker::placeRectangle(const LLU::Tensor<mint>& rectData) {

		rbp::Rect r{};
		r.x = rectData.at({0, 0});
		r.y = rectData.at({0, 1});
		r.width = rectData.at({1, 0}) - r.x;
		r.height = rectData.at({1, 1}) - r.y;
		m_ptr->PlaceRect(r);
}






/**
 * @brief    implements the MAXRECTS data structure and different bin packing \
 *           algorithms that use this structure.
 *
 * @param    {Integer, "width"}
 * @param    {Integer, "height"}
 * @param    {"Boolean", "AllowFlips" -> True}
 * @param    {enum["FreeRectChoiceHeuristic"], "FreeChoiceHeuristic" -> "BestAreaFit"}
 *           The free rectangle choice heuristic rule to use.  Can be one of
 *           {
			  "BestShortSideFit",
			  "BestLongSideFit",
			  "BestAreaFit",
			  "BottomLeftRule",
			  "ContactPointRule"
		  }
 * @return   Managed[WLRectanglePacker]
 */
BEGIN_LIBRARY_FUNCTION(MaxRectsPacker) {
	auto width = mngr.getInteger<int>(arg++);
	auto height = mngr.getInteger<int>(arg++);

	auto allowFlip = mngr.getBoolean(arg++);

	auto freechoice = mngr.getInteger<rbp::MaxRectsBinPack::FreeRectChoiceHeuristic>(arg++);

	auto res = std::make_shared<WLMaxRectcsPacker>(width, height, allowFlip, freechoice);

	RectanglePackerStore.createInstance(mngr.getInteger<mint>(arg++), std::static_pointer_cast<RectanglePacker>(res));
}
END_LIBRARY_FUNCTION


}
