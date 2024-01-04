

BeginPackage["JasonB`RectanglePacking`"]


PackRectangles::usage = "PackRectangles[boundingbox,{rect1,rect2,..}] packs the given rectangles in the given bounding box.
PackRectangles[boundingbox,rectangles,method] uses the given method to pack rectangles."



RectanglePacker::usage = "RectanglePacker[boundingbox] creates a mutable data structure into which rectangles can be packed.
RectanglePacker[boundingbox, method] uses the given method to pack rectangles."

$RectanglePackingMethods
$DefaultRectanglePackingMethod = "MaxRects"


Begin["`Private`"]

PackRectangles::notrec = "`1` is not a valid Rectangle for packing."
PackRectangles::nopac = "Failed to pack `1` rectangles."



Get["JasonB`RectanglePacking`RectanglePackingLibrary`"]


fail[msg_, other___] := Throw[Failure["RectanglePackingFailure", <|"Message" -> msg, other|>], $tag]
Attributes[catch] = {HoldFirst}
catch[arg_] := Catch[arg, _]





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


expandMethod[Automatic] := {$DefaultRectanglePackingMethod}
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

RectanglePacker[r:$rectanglePattern, method: Automatic|_String|{_String, ___Rule}:Automatic, o:OptionsPattern[]] := catch @ Block[
	{res},
	res = iRectanglePacker[rectangleDims @ r, expandMethod @ method, Flatten[{o}]];
	
	If[$Cache["KeyExistsQ", res], res, $Failed]
]

RectanglePacker[in:Except[$rectanglePattern | _String], ___] := catch @ (Message[PackRectangles::notrec, in]; fail["Invalid rectangle encountered.", "InputRectangle" -> in])


rectangleDims[dims:{_Integer, _Integer} ] := dims
rectangleDims[Rectangle[{_Integer, _Integer} ]  ] := {1,1}
rectangleDims[(Rectangle|Cuboid)[{xmin_Integer, ymin_Integer}, {xmax_Integer, ymax_Integer}] ] := {
	Abs[xmax - xmin], Abs[ymax - ymin]
}
rectangleDims[input_] := (Message[PackRectangles::notrec, input]; fail["Invalid rectangle encountered.", "InputRectangle" -> input])






iRectanglePacker[{w_, h_}, {method_String, methodOpts___Rule}, o_] := Block[
	{mle, function = Lookup[methodDispatch, method, fail["Unknown method", "BadMethod" -> method]], res},
	mle = function[w, h, FilterRules[{o, methodOpts}, Options[function]]];
	If[!ManagedLibraryExpressionQ[mle], fail["could not construct library object", "BadResult" -> mle]];
	res = RectanglePacker @ CreateUUID[];
	$Cache["Insert", res, mle];
	res
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
	Except[_List] :> fail["invalid packed rectangles"]
]

rpSubvalue[_, p_,{"PackedRectangleCount"}] := Replace[
	p["GetPackedRectangleCount"],
	Except[_Integer] :> fail["invalid packed rectangles"]
]

rpSubvalue[_, p_,{"FreeRectangleCoordinates"}] := Replace[
	p["GetUsedRectangles"],
	Except[_List] :> fail["invalid packed rectangles"]
]

rpSubvalue[_, p_,{"PackedRectangles"|"Rectangles"}] := Rectangle @@@ rpSubvalue[_, p, {"PackedRectangleCoordinates"}]
rpSubvalue[_, p_,{"FreeRectangles"}] := Rectangle @@@ rpSubvalue[_, p, {"FreeRectangleCoordinates"}]


rpSubvalue[rp_, p_,{"Insert", rect : $rectanglePattern}] := Replace[
	rpSubvalue[rp, p, {"Insert", {rect}}],
	{e_} :> e
]


$specifiedRectanglePattern = Rectangle[{_Integer,_Integer},{_Integer,_Integer}]|{{_Integer,_Integer},{_Integer,_Integer}}
rpSubvalue[_, p_,{"PlaceRectangle", rectIn_}] := Module[
	{rect},
	rect = Replace[rectIn,
		{
			r:Rectangle[{_Integer,_Integer},{_Integer,_Integer}] :> List @@ r,
			r:{{_Integer,_Integer},{_Integer,_Integer}} :> r,
			r_ :> fail["Invalid rectangle encountered.", "InputRectangle" -> r]
		}
	];
	
	p["PlaceRectangle", rect]
]

$UnpackedRectangle = ConstantArray[0, {2,2}];

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


(* ************************************************************************* **

                        PackRectangles

** ************************************************************************* *)


Options[PackRectangles] = {
	"FixedRectangles" -> {}
}



PackRectangles[r_, rectsIn_, method:Automatic|_String|{_String, ___Rule}:Automatic, o:OptionsPattern[]] := catch @ Module[
	{packer, fixed},
	packer = RectanglePacker[r, method, o];
	If[FailureQ[packer], Throw[packer, $tag]];
	fixed = OptionValue[PackRectangles, FilterRules[{o}, "FixedRectangles"], "FixedRectangles"];
	addFixed[packer, fixed];
	
	packer["Insert", rectsIn]
]

addFixed[_, {}] := Null
addFixed[p_, fixed_List] := addFixed[p] /@ fixed
addFixed[p_, r_Rectangle] := addFixed[p, {r}]
addFixed[_, l_] := fail["invalid fixed rectangles l"]

addFixed[p_][r_] := Replace[p["PlaceRectangle", r], f_?FailureQ :> Throw[f, $tag]]



With[
	{list = $RectanglePackingMethods},
	FE`Evaluate[FEPrivate`AddSpecialArgCompletion["RectanglePacker" -> {0, list}]];
	FE`Evaluate[FEPrivate`AddSpecialArgCompletion["PackRectangles" -> {0, 0, list}]]
]

End[] (* End Private Context *)

EndPackage[]