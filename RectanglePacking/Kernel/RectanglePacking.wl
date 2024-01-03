

BeginPackage["JasonB`RectanglePacking`"]


PackRectangles::usage = "PackRectangles[boundingbox,{rect1,rect2,..}] packs the given rectangles in the given bounding box."
(*PackingResult::usage = "PackingResult[..] is returned by PackRectangles"*)


RectanglePacker

$RectanglePackingMethods

Begin["`Private`"]

PackRectangles::notrec = "`1` is not a valid Rectangle for packing."
PackRectangles::nopac = "Failed to pack `1` rectangles."



Get["JasonB`RectanglePacking`RectanglePackingLibrary`"]


$MaxRectFreeChoiceMethods = {"BestShortSideFit", "BestLongSideFit", "BestAreaFit",
		"BottomLeftRule", "ContactPointRule"}
		
$GuillotineFreeChoiceMethods = {"BestAreaFit", "BestShortSideFit", "BestLongSideFit",
		"WorstAreaFit", "WorstShortSideFit", "WorstLongSideFit"}

$GuillotineSplitMethods = {
	"ShorterLeftoverAxis", "LongerLeftoverAxis", "MinimizeArea",
	"MaximizeArea", "ShorterAxis", "LongerAxis"
}
		


$RectangleMethods = {
		"MaximalRectangles", 
		
		"Guillotine"
	};
	
rpSubOptions["MaximalRectangles"] = <|"FreeChoiceRule" -> "BestAreaFit", "AllowFlip" -> True|>
	
rpSubOptions["Guillotine"] = <|"FreeChoiceRule" -> "BestAreaFit", "SplitRule" -> "MaximizeArea", "MergeFreeRectangles" -> True|>


rpMethodPick = With[
	{assoc = AssociationThread[$RectangleMethods -> Range[Length[$RectangleMethods]]]},
	Lookup[assoc, #]&
]

subMethodEnumWithMessage[submethod_, value_, valid_ ] := Replace[
	FirstPosition[valid, value], 
	{
		{x_Integer} :> x - 1 (* these library enums start at 0 *),
		_Missing :> (
			Message[RectangleBinPack::submtd, value, submethod, valid];
			Throw[$Failed, "rectanglePackError"];
		) 
	}
]


fail[msg_, other___] := Throw[Failure["RectanglePackingFailure", <|"Message" -> msg, other|>], $tag]
Attributes[catch] = {HoldFirst}
catch[arg_] := Catch[arg, $tag]




(* ************************************************************************* **

                        PackRectangles

** ************************************************************************* *)
(*{"BestShortSideFit", "BestLongSideFit", "BestAreaFit",
		"BottomLeftRule", "ContactPointRule"}*)

Options[PackRectangles] = {
	"AllowFlips" -> True,
	"FreeChoiceHeuristic" -> "BestAreaFit",
	"FixedRectangles" -> {}
}


$rectanglePattern = _Rectangle | {_Integer,_Integer}
$specifiedRectanglePattern = Rectangle[{_Integer,_Integer},{_Integer,_Integer}]|{{_Integer,_Integer},{_Integer,_Integer}}

PackRectangles[bb:$rectanglePattern, rects : {$rectanglePattern...}, opts:OptionsPattern[]] := catch @ iPackRectangles[
	bb, rects, Flatten @ {opts}
]




rectangleDims[dims:{_Integer, _Integer} ] := dims
rectangleDims[Rectangle[{_Integer, _Integer} ]  ] := {1,1}
rectangleDims[(Rectangle|Cuboid)[{xmin_Integer, ymin_Integer}, {xmax_Integer, ymax_Integer}] ] := {
	Abs[xmax - xmin], Abs[ymax - ymin]
}
rectangleDims[input_] := (Message[PackRectangles::notrec, input]; fail["Invalid rectangle encountered.", "InputRectangle" -> input])

translateResults[HoldPattern[Rectangle[{a_, b_}, _]], data_] := translateResults[{a,b}, data]

translateResults[{a_, b_}, data_ /; ArrayQ[data, 3, IntegerQ]] := Apply[
	Rectangle,
	TranslationTransform[{a, b}] @ data,
	{1}
]

translateResults[___] := $Failed


$UnpackedRectangle = ConstantArray[0, {2,2}]; 

iPackRectangles[bb_, rectsIn_, input_, opts:OptionsPattern[]] := Module[
	{width, height, packer, flips, freeChoice, fixed, failed = False, res, rectDims},
	rectDims = rectangleDims /@ rectsIn;
	{width, height} = rectangleDims @ bb;
	{flips, freeChoice, fixed} = OptionValue[
		PackRectangles, 
		{opts}, 
		{"AllowFlips", "FreeChoiceHeuristic", "FixedRectangles"}
	];
	packer = MaxRectsBinPack[width, height, flips];
	If[!ManagedLibraryExpressionQ[packer], fail["could not construct library object", "BadResult" -> packer]];
	If[!MatchQ[fixed, {$specifiedRectanglePattern...}], fail["invalid fixed rectangles", "BadResult" -> packer]];
	
	
	
	res = Replace[
		packer["InsertRectangles", rectDims, "FreeChoiceHeuristic" -> freeChoice],
		xx:$UnpackedRectangle :> (failed = True;Echo[xx]; $Failed),
		{1}
	];
	If[failed,
		Message[PackRectangles::nopac, Count[res, $Failed]];
		res = Replace[
			Thread[{res, rectsIn}],
			{
				{$Failed, x_} :> Failure["BadRectangle", <|"Input" -> x|>],
				{x_, _} :> x
			},
			{1}
		]
	];
	res
]    



(* ************************************************************************* **

                        $RectanglePackingMethods

** ************************************************************************* *)


$RectanglePackingMethods = {"MaxRects", "Guillotine", "Shelf", "Skyline"}

defineMethod[methodName_, expanded_] := (
	AppendTo[$RectanglePackingMethods, methodName];
	expandMethod[methodName] = expanded
)

defineMethod["MaxRectsBestShortSide", {"MaxRects", "FreeChoiceHeuristic" -> "BestShortSideFit"}]
defineMethod["MaxRectsBestLongSide", {"MaxRects", "FreeChoiceHeuristic" -> "BestLongSideFit"}]
defineMethod["MaxRectsBestArea", {"MaxRects", "FreeChoiceHeuristic" -> "BestAreaFit"}]
defineMethod["MaxRectsBottomLeft", {"MaxRects", "FreeChoiceHeuristic" -> "BottomLeftRule"}]
defineMethod["MaxRectsContactPoint", {"MaxRects", "FreeChoiceHeuristic" -> "ContactPointRule"}]

defineMethod["GuillotineBestShortSide", {"Guillotine", "FreeChoiceHeuristic" -> "BestShortSideFit"}]
defineMethod["GuillotineBestLongSide", {"Guillotine", "FreeChoiceHeuristic" -> "BestLongSideFit"}]
defineMethod["GuillotineBestArea", {"Guillotine", "FreeChoiceHeuristic" -> "BestAreaFit"}]
defineMethod["GuillotineWorstShortSide", {"Guillotine", "FreeChoiceHeuristic" -> "WorstShortSideFit"}]
defineMethod["GuillotineWorstLongSide", {"Guillotine", "FreeChoiceHeuristic" -> "WorstLongSideFit"}]
defineMethod["GuillotineWorstArea", {"Guillotine", "FreeChoiceHeuristic" -> "WorstAreaFit"}]

defineMethod["ShelfNextFit", {"Shelf", "FreeChoiceHeuristic" -> "NextFit"}]
defineMethod["ShelfFirstFit", {"Shelf", "FreeChoiceHeuristic" -> "FirstFit"}]
defineMethod["ShelfBestAreaFit", {"Shelf", "FreeChoiceHeuristic" -> "BestAreaFit"}]
defineMethod["ShelfBestHeightFit", {"Shelf", "FreeChoiceHeuristic" -> "BestHeightFit"}]
defineMethod["ShelfBestWidthFit", {"Shelf", "FreeChoiceHeuristic" -> "BestWidthFit"}]
defineMethod["ShelfWorstAreaFit", {"Shelf", "FreeChoiceHeuristic" -> "WorstAreaFit"}]
defineMethod["ShelfWorstWidthFit", {"Shelf", "FreeChoiceHeuristic" -> "WorstWidthFit"}]

defineMethod["SkylineBottomLeft", {"Shelf", "FreeChoiceHeuristic" -> "BottomLeft"}]
defineMethod["SkylineBestFit", {"Shelf", "FreeChoiceHeuristic" -> "BestFit"}]


expandMethod[Automatic] := {"MaxRects"}
expandMethod[{s_String, opts___}] := Replace[
	expandMethod[s],
	{a_, b___} :> {a, opts, b}
]

expandMethod[s_String] := {s}


(* ************************************************************************* **

                        RectanglePacker costructor

** ************************************************************************* *)

$Cache := $Cache = PacletSymbol["JasonB/WeakCache", "WeakHashTable"]["RectanglePacking"]

$rectanglePattern = _Rectangle | {_Integer,_Integer}

RectanglePacker[r:$rectanglePattern, o:OptionsPattern[]] := RectanglePacker[r, "MaxRects", o]

RectanglePacker[r:$rectanglePattern, method: Automatic|_String|{_String, ___Rule}:Automatic, o:OptionsPattern[]] := catch @ Block[
	{res},
	res = iRectanglePacker[rectangleDims @ r, expandMethod @ method, Flatten[{o}]];
	
	If[$Cache["KeyExistsQ", res], res, $Failed]
]



makeRectanglePacker[mle_?ManagedLibraryExpressionQ] := Block[
	{res},
	res = RectanglePacker @ CreateUUID[];
	$Cache["Insert", res, mle];
	res
]



iRectanglePacker[{w_, h_}, {method_String, methodOpts___Rule}, o_] := Block[
	{mle, function = Lookup[methodDispatch, method, fail["Unknown method", "BadMethod" -> method]], res},
	mle = Echo @ function[w, h, Echo @ FilterRules[Echo @ {o, methodOpts}, Options[function]]];
	If[!ManagedLibraryExpressionQ[mle], fail["could not construct library object", "BadResult" -> mle]];
	makeRectanglePacker @ mle
]

methodDispatch = <|
	"MaxRects" -> MaxRectsPacker, "Guillotine" -> GuillotinePacker,
	"Shelf" -> ShelfPacker, "Skyline" -> SkylinePacker
|>


(* ************************************************************************* **

                        RectanglePacker subvalues

** ************************************************************************* *)


HoldPattern[(pr_RectanglePacker)[args__]] := catch @ Replace[
	$Cache["Lookup", pr],
	{
		mle_?ManagedLibraryExpressionQ :> rpSubvalue[pr,mle,{args}],
		_ :> Failure["RectangleOutOfScope", <|"Message" -> "RectanglePacker data not available."|>]
	}
]

rpSubvalue[_, p_,{"Occupancy"}] := Replace[
	p["GetOccupancy"], 
	Except[_Real] :> fail["Invalid occupancy"]
]

rpSubvalue[_, p_, {"Dimensions"|"BoundingBoxDimensions"}] := Replace[
	p["GetDimensions"], 
	Except[{_Integer, _Integer}] :> fail["Invalid dimensions"]
]

rpSubvalue[rp_, p_,{"BoundingRectangle"}] := Rectangle[
	{0, 0}, rpSubvalue[rp, p, {"BoundingBoxDimensions"}]
]

rpSubvalue[_, p_,{"PackedRectangleCoordinates"}] := Replace[
	p["GetUsedRectangles"],
	Except[{} | (m_ /; ArrayQ[m, 3, IntegerQ])] :> fail["invalid packed rectangles"]
]

rpSubvalue[_, p_,{"FreeRectangleCoordinates"}] := Replace[
	p["GetUsedRectangles"],
	Except[{} | (m_ /; ArrayQ[m, 3, IntegerQ])] :> fail["invalid packed rectangles"]
]

rpSubvalue[_, p_,{"PackedRectangles"|"Rectangles"}] := Rectangle @@@ rpSubvalue[_, p, {"PackedRectangleCoordinates"}]
rpSubvalue[_, p_,{"FreeRectangles"}] := Rectangle @@@ rpSubvalue[_, p, {"FreeRectangleCoordinates"}]


rpSubvalue[rp_, p_,{"Insert", rect : $rectanglePattern}] := Replace[
	rpSubvalue[rp, p, {"Insert", {rect}}],
	{e_} :> e
]


rpSubvalue[_, p_,{"Insert", rectsIn:{$rectanglePattern...}}] := Block[
	{rectDims, res, opts, failed},
	rectDims = rectangleDims /@ rectsIn;
	res = Replace[
		p["InsertRectangles", rectDims],
		$UnpackedRectangle :> (failed = True;$Failed),
		{1}
	];
	If[failed,
		Message[PackRectangles::nopac, Count[res, $Failed]];
		res = Replace[
			Thread[{res, rectsIn}],
			{
				{$Failed, x_} :> Failure["UnplacedRectangle", <|"Input" -> x|>],
				{x_, _} :> x
			},
			{1}
		]
	];
	res
	
]


rpSubvalue[rp_, p_, {"Graphics", opts___ ? OptionQ}] := Catch @ Module[
	{br, rects, colors},
	br = rpSubvalue[rp, p, {"BoundingRectangle"}];
	rects = rpSubvalue[rp, p, {"Rectangles"}];
	colors = getColors[First @ rp, Length @ rects, {opts}];
	Graphics[
		{
			{
				EdgeForm @ {Thick, RGBColor[0.17, 0.13, 0.7]},
				FaceForm @ Opacity @ 0,
				br
			},
			{EdgeForm @ Black, Thread @ {colors, rects}}
		},
		FilterRules[{opts}, Options @ Graphics]
	]
]

rpSubvalue[___] := $Failed

getColors[seed_, ncolors_, opts_] := BlockRandom[
	Module[{cf},
		cf = OptionValue[
			{ColorFunction -> Automatic},
			FilterRules[opts, ColorFunction],
			ColorFunction
		];
		If[StringQ[cf],
			Map[ColorData @ cf, RandomReal[1, ncolors]],
			(* For a given seed RandomColor[3] is not the same as RandomColor[5][[;;3]], see bug(350033) *)
			RGBColor @@@ RandomReal[1, {ncolors, 3}]
		]
	],
	RandomSeeding -> seed
]


(* ************************************************************************* **

                        RectanglePacker Formatting

** ************************************************************************* *)

RectanglePacker /: MakeBoxes[pr:RectanglePacker[_String], fmt_] := Block[{res},
	res = If[
		TrueQ @ $Cache["KeyExistsQ", Unevaluated @ pr],
		rpSummaryBox[pr, fmt],
		rpInvalidBox[pr, fmt]
	];
	res /; res =!= $Failed
]
	
rpSummaryBox[pr_, fmt_]	:= Block[
	{gr = pr["Graphics", ImageSize -> {UpTo[200], UpTo[100]}],p = $Cache["Lookup",pr], grid},
	If[MatchQ[gr, _Graphics],
		grid = Replace[p["information"],
			{
				a_Association :> KeyValueMap[BoxForm`SummaryItem@{StringJoin[#1,": "],ElisionsDump`expandablePane@#2}&,a],
				_ :> {BoxForm`SummaryItem[{"Packed rectangles: ",Length[pr["PackedRectangleCoordinates"]]}]}
			}
		];
		BoxForm`ArrangeSummaryBox[
			RectanglePacker, pr, gr,
			grid, {}, fmt, "Interpretable" -> False
		],
		$Failed
	]
]

rpInvalidBox[rp_, fmt_] := With[{failed = BoxForm`SurroundWithAngleBrackets["invalid packing object"]},
	MakeBoxes[Interpretation[RectanglePacker[failed], $Failed], fmt]
]


With[
	{list = $RectanglePackingMethods},
	FE`Evaluate[FEPrivate`AddSpecialArgCompletion["RectanglePacker" -> {0, list}]]
]

End[] (* End Private Context *)

EndPackage[]