(* Wolfram Language Package *)

BeginPackage["JasonB`RectanglePacking`RectanglePackingLibrary`"]


$RectangleBinPackLinkFailure = "RectanglePackingLibrary"

ThrowRectangleBinPackLinkFailure
CatchPacletExceptions

(* ::Subsection::Closed:: *)
(*Symbols list*)

(* This list is auto-generated, changes will not be preserved *)

GuillotinePacker
MaxRectsPacker
WLRectanglePacker
ShelfPacker
SkylinePacker

(* End autogenerated symbols block *)


Begin["`Private`"]





(* 
	WARNING: The following code is automatically generated, 
	manual changes will not be preserved.
*)



(* ::Subsection::Closed:: *)
(*Error handling code, adapted from LibraryLinkUtilities.wl*)



If[
	StringQ[$RectanglePackingLibrary = FindLibrary["RectanglePackingLibrary"]] && TrueQ[Check[LibraryLoad[$RectanglePackingLibrary];True, False]],
	libraryFunctionLoad[args__] := Replace[
		Quiet @ Check[LibraryFunctionLoad @ args, $Failed],
		Except[_LibraryFunction] :> Throw[$Failed[args], RectanglePackingLibraryFailureTag]
	];
	libraryFunctionLoad[___] := $Failed
]

With[
	{fun = libraryFunctionLoad[$RectanglePackingLibrary, "setExceptionDetailsContext", {String}, String]},
	fun[$Context]
]



If[!AssociationQ[$CorePacletFailureLUT],
	$CorePacletFailureLUT = <|
		"GeneralFailure" -> {31, "`1`"},
		"UnknownEnumValue" -> {27, "`1` is not a known value for type `2`, available types include `3`."}
	|>
];

With[
	{fun = libraryFunctionLoad[$RectanglePackingLibrary, "sendRegisteredErrors", LinkObject, LinkObject]},
	AssociateTo[$CorePacletFailureLUT, fun[]]
]


With[{rdtag = RectanglePackingLibraryFailureTag},
	ThrowRectanglePackingLibraryFailure[type_String, params_List] := ThrowRectanglePackingLibraryFailure[type, "MessageParameters" -> params];
	ThrowRectanglePackingLibraryFailure[type_ ? StringQ, opts:OptionsPattern[createPacletFailure]] := ThrowRectanglePackingLibraryFailure[createPacletFailure[type, opts]];
	ThrowRectanglePackingLibraryFailure[failure_Failure] := Throw[failure, rdtag, cleanFailure]
]


Attributes[CatchRectanglePackingLibraryFailure] = {HoldAll}
CatchRectanglePackingLibraryFailure[arg_] := Catch[arg, RectanglePackingLibraryFailureTag]
	

Options[createPacletFailure] = {
	"CallingFunction" -> None,
	"MessageParameters" -> <||>,
	"Parameters" -> {}
};

createPacletFailure[type_?StringQ, opts:OptionsPattern[]] :=
Block[{msgParam, param, errorCode, msgTemplate, errorType, assoc},
	msgParam = Replace[OptionValue["MessageParameters"], Except[_?AssociationQ | _List] -> <||>];
	param = Replace[OptionValue["Parameters"], {p_?StringQ :> {p}, Except[{_?StringQ.. }] -> {}}];
	{errorCode, msgTemplate} =
		Lookup[
			$CorePacletFailureLUT
			,
			errorType = type
			,
			(
				AppendTo[msgParam, "ErrorName" -> type];
				$CorePacletFailureLUT[errorType = "UnknownFailure"]
			)
		];
	If[errorCode < 0, (* if failure comes from the C++ code, extract message template parameters *)
		{msgParam, param} = GetCCodeFailureParams[msgTemplate];
	];
	assoc = <|
		"MessageTemplate" -> msgTemplate,
		"MessageParameters" -> msgParam,
		"ErrorCode" -> errorCode
	|>;
	If[OptionValue["CallingFunction"] =!= None, 
		assoc["CallingFunction"] = OptionValue["CallingFunction"]
	];
	If[Length[param] > 0, 
		assoc["Parameters"] = param
	];
	Failure[errorType,
		assoc
	]
];



GetCCodeFailureParams[msgTemplate_String ? StringQ] := Block[
	{slotNames, slotValues, msgParams, selectedSlotValues, params = {}},
	slotNames = DeleteDuplicates @ Cases[First @ StringTemplate @ msgTemplate, TemplateSlot[s_] :> s];
	slotValues = If[ListQ[$LastFailureParameters], $LastFailureParameters, {}];
	$LastFailureParameters = {};
	msgParams = If[MatchQ[slotNames, {Repeated[_Integer]}],
		slotValues,
		{selectedSlotValues, params} = TakeList[slotValues, {UpTo @ Length @ slotNames, All}];
		selectedSlotValues = PadRight[slotValues, Length @ slotNames, ""];
		If[VectorQ[slotNames, StringQ],
			AssociationThread[slotNames, selectedSlotValues],
			MapThread[Function[If[StringQ[#], <|# -> #2|>, #2]],
				{slotNames, selectedSlotValues}
			]
		]
	];
	{msgParams, params}
];


catchThrowErrors[HoldPattern[LibraryFunctionError[_, b_]], caller_] := ThrowRectanglePackingLibraryFailure[errorCodeToName[b], "CallingFunction" -> caller]
catchThrowErrors[ulf : HoldPattern[LibraryFunction[__][__]], _] := ThrowRectanglePackingLibraryFailure[Failure["UnevaluatedLibraryFunction", <|"Input" -> HoldForm[ulf]|>]]
catchThrowErrors[a_, _] := a

catchReleaseErrors[HoldPattern[LibraryFunctionError[_, b_]], caller_] := createPacletFailure[errorCodeToName[b], "CallingFunction" -> caller]
catchThrowErrors[ulf : HoldPattern[LibraryFunction[__][__]], _] := Failure["UnevaluatedLibraryFunction", <|"Input" -> HoldForm[ulf]|>]
catchReleaseErrors[a_, _] := a


errorCodeToName[errorCode_Integer]:=
Block[{name = Select[$CorePacletFailureLUT, MatchQ[#, {errorCode, _}] &]},
	If[Length[name] > 0 && Depth[name] > 2,
		First @ Keys @ name
		,
		""
	]
];


cleanFailure[f:Failure[type_,ass:KeyValuePattern[Rule["MessageParameters", {str_}]]],___] := Module[
	{failureArg = ass, res},
	If[ass["MessageTemplate"] === "`1`",
		failureArg["RawMessage"] = First[ass["MessageParameters"], ""];
		failureArg["MessageParameters"] = fixLibraryMessage[ass["MessageParameters"]];
	];
	res = Failure[type, failureArg]
]

cleanFailure[f_,__] := f

fixLibraryMessage[{str_String}] /; StringContainsQ[str, "
"] := Module[
	{lines = Map[StringTrim, ImportString[str, "Lines"]]},
	{StringJoin[StringTake[StringRiffle[lines, ", "], UpTo[50]], "\[Ellipsis]"]}
]

fixLibraryMessage[{str_String}] /; StringLength[str] > 50 := {
	StringJoin[StringTake[str, UpTo[50]], "\[Ellipsis]"]
}

fixLibraryMessage[arg__] := arg







(* ::Subsection::Closed:: *)
(*enumerate*)


(*
	For converting between String values and enums
*)

enumerate[name_, enums:{__String}] := enumerate[name, AssociationThread[enums -> Range[0, Length@enums - 1]]]
enumerate[name_, enums_?AssociationQ] := With[
	{
		data = Join[
			enums,
			Association @ Map[Reverse, Normal[enums]]
		]
	},
	enum[name][num_] := Lookup[
		data, 
		num, 
		ThrowRectanglePackingLibraryFailure["UnknownEnumValue", "MessageParameters" -> {num, name, Keys[enums]}]
	];
]



(* ::Subsection::Closed:: *)
(*DataStore helpers*)


toDataStore[ds_Developer`DataStore] := ds;
toDataStore[Rule[s_String, v_]] := Developer`DataStore[Rule[s, dsPrimitive @ v]]
toDataStore[rules:{__Rule}] := Developer`DataStore @@ MapAt[dsPrimitive, rules, {All, 2}]
toDataStore[obj_List] := Developer`DataStore @@ (dsPrimitive /@ obj)
toDataStore[ass_?AssociationQ /; AllTrue[Keys[ass], StringQ]] := Developer`DataStore @@ Normal[dsPrimitive /@ ass]

dsPrimitive[obj : (_String | _Integer | _Real | {__Integer} | {__Real} | True | False | _Rule)] := obj
dsPrimitive[{s__String}] := Developer`DataStore[s]
dsPrimitive[in : _Association | {__Rule}] := toDataStore[in]
dsPrimitive[in_List] := Block[{pa},Which[
	Developer`PackedArrayQ[in],
		in,
	Developer`PackedArrayQ[pa = Developer`ToPackedArray @ in],
		pa,
	True,
		toDataStore[in]
]]
dsPrimitive[ds_Developer`DataStore] := ds;
dsPrimitive[obj_] := ThrowRectanglePackingLibraryFailure["NoDataStore", "MessageParameters" -> {obj}]


fromDataStore[arg_] := Block[
	{Developer`DataStore},
	Developer`DataStore[r__Rule] := Association[r];
	Developer`DataStore[r___] := List[r];
	arg
];

(* ::Subsection::Closed:: *)
(*Managed library expression helper functions*)

getManagedID[type_][(type_)[id_]] := id
getManagedID[type_][l_List] := getManagedID[type] /@ l

normalizeFormattingGrid[ass_?AssociationQ] := Module[
	{res},
	res = KeyValueMap[BoxForm`SummaryItem @ {StringJoin[#1, ": "], ElisionsDump`expandablePane @ #2}&, ass];
	If[Length[res] > 10,
		Partition[res, UpTo[2]],
		res
	]
]
normalizeFormattingGrid[ass:{__?AssociationQ}] := normalizeFormattingGrid /@ ass
normalizeFormattingGrid[x_] := x

$gridPattern = {__BoxForm`SummaryItem} | {{_BoxForm`SummaryItem,___}..}

addMethods[dat_ : $gridPattern, obj_] := Module[
	{methods = methodData[Head @ obj]},
	If[AssociationQ[methods],
		methods = BoxForm`SummaryItem[{"Operations: ", getMethodButton[obj, #]& /@ Keys[methods]}];
		If[ListQ[dat[[1]]], methods = {methods, SpanFromLeft}];
		Append[dat, methods]
		,
		dat
	]
]
addMethods[dat_,___] := dat

getIcon[___] := None;


getMethodButton[obj_, name_] := name

getMethodButton[obj_, name_] := Module[
	{data = methodData[Head @ obj, name]},
	With[
		{params = If[MatchQ[data["Parameters"], {__String}], Placeholder /@ data["Parameters"], Sequence @@ {}]},
		ClickToCopy[name, Defer[obj[name, params]]]
	]
]


$clearManagedInstances := $clearManagedInstances = libraryFunctionLoad[$RectanglePackingLibrary, "clearManagedInstances", {"UTF8String"}, "Void"]
clearManagedInstances[type_ : "All"] := $clearManagedInstances[type]

$managedInstanceIDList := $managedInstanceIDList = libraryFunctionLoad[$RectanglePackingLibrary, "managedInstanceIDList", {"UTF8String"}, {Integer, 1}]
managedInstanceIDList[type_] := $managedInstanceIDList[type]

$deleteInstance := $deleteInstance = libraryFunctionLoad[$RectanglePackingLibrary, "deleteInstance", {"UTF8String", Integer}, "Void"]

methodData = <||>


Do[
	If[ListQ[type]
		,
		With[
			{t = Last[type], owner = First[type]},
			t /: t[{owner[n_Integer],___}]["GetOwner"] := owner[n];
			t /: MakeBoxes[obj$:t[{owner[n_Integer],___}], fmt$_] /; ManagedLibraryExpressionQ[Unevaluated[owner[n]]] := Module[{res}, res /; !FailureQ[res = getMLEBox[obj$, fmt$, True]]];
			methodData[t] = <|"GetOwner" -> <|"Usage" -> StringJoin["returns the owning ", ToString[owner], " object."]|>|>;
			t /: (_t)["Operations"] := Keys[methodData[t]]
		]
		,
		With[
			{t = type},
			
			t /: t[n_Integer]["Delete"] /; ManagedLibraryExpressionQ[t[n]] := $deleteInstance[SymbolName[t], n];
			t /: MakeBoxes[obj$:t[_Integer], fmt$_] /; validObject[Unevaluated[obj$]] := Module[{res}, res /; !FailureQ[res = getMLEBox[obj$, fmt$, True]]];
			methodData[t] = <||>;
			t /: (_t)["Operations"] := Keys[methodData[t]]
		]
	],
	{type, {WLRectanglePacker}}
]

validObject[x_] := ManagedLibraryExpressionQ[Unevaluated[x]]



ClearAll @ dynamicEvaluate;
SetAttributes[dynamicEvaluate, HoldAllComplete];
dynamicEvaluate[expr_, cachedValue_] := Dynamic[
	expr, SynchronousUpdating -> False, TrackedSymbols :> {},
	CachedValue :> cachedValue
];

ClearAll @ addDeclarations;
SetAttributes[addDeclarations, HoldAll];
addDeclarations[DynamicModuleBox[{a__}, b__], expr__] := DynamicModuleBox[{a, expr}, b];
addDeclarations[a_, ___] := a;


getMLEBox[obj_, fmt_, Optional[interpretable_, True]] := Module[
	{icon, grid, sym, methods = methodData[Head @ obj], box, sometimesGrid},
	sym = Head @ obj;
	icon = getIcon @ obj;
	grid = normalizeFormattingGrid @ obj["information"];
	If[!MatchQ[grid, $gridPattern],
		grid = Which[
			ManagedLibraryExpressionQ[obj],
				{BoxForm`SummaryItem @ {"ID: ", ManagedLibraryExpressionID @ obj}},
			MatchQ[obj, _[{_?ManagedLibraryExpressionQ, _Integer}]],
				{
					BoxForm`SummaryItem @ {"Parent: ", Head @ obj[[1,1]]},
					BoxForm`SummaryItem @ {"ID: ", obj[[1,2]]}
				},
			True,
				Return[$Failed, Module]
		]
	];
	sometimesGrid = Part[grid, Span[1, UpTo @ 2]];
	If[Length[methods] > 0,
		grid = addMethodsToGrid[methods, grid]
	];
	(
		box = BoxForm`ArrangeSummaryBox[sym,
			obj, icon, sometimesGrid,
			grid,
			fmt, "CompleteReplacement" -> True, "Interpretable" -> interpretable
		];
		If[Length[methods] > 0,
			addMethodsToBox[methods, box, obj],
			box
		]
	) /; MatchQ[grid, $gridPattern]
];
getIcon[___] := None;

addMethodsToGrid[methodsData_, grid_] := Module[
	{item},
	item = BoxForm`SummaryItem[
		{
			"Operations: ", 
			dynamicEvaluate[
				ElisionsDump`expandablePane @ Replace[
					getMethodButtons[Typeset`sobj$$, Typeset`sops$$],
					Except[_List] :> Typeset`sops$$
				],
				Typeset`sops$$
			]
		}
	];
	If[MatchQ[grid, {__BoxForm`SummaryItem}],
		Append[grid, item],
		Append[grid, {item, SpanFromLeft}]
	]
	
]

addMethodsToBox[methods_, box_, obj_] := Module[
	{dbox},
	dbox = Cases[box, a_DynamicModuleBox :> a, Infinity, 1];
	dbox = With[
		{a = First[dbox], ops = Sort @ Keys @ methods}, 
		addDeclarations[a, Typeset`sobj$$ = obj, Typeset`sops$$ = ops]
	];
	box /. (_DynamicModuleBox -> dbox)
		
]
		
		
getMethodButtons[obj_, operations_] := Map[
	Function[
		Button[
			Tooltip[#,methodData[Head[obj], #, "Usage"]],
			CopyToClipboard[
				Replace[getInput[obj, #], _getInput :> StringJoin["\"", #, "\""]]
			],
			Appearance -> None, BaseStyle -> Automatic
		]
	],
	operations
]


getInput[obj: HoldPattern[(head_)[__]], method_] := Module[
	{md = methodData[head, method], vars},
	(
		vars = Replace[
			md["Parameters"],
			{
				x:{__String} :> Apply[Sequence, Placeholder /@ x],
				_ :> Sequence[]
			}
		];
		With[{expr = Defer[obj][method, vars]},
			{box = MakeBoxes[expr, StandardForm]},
			Cell[BoxData @ box, "Input"]
		]
	) /; AssociationQ[md]
]


		
		
		
		
		
		
		
		
		
		



(* ::Subsection::Closed:: *)
(*WLGuillotineBinPack*)

GuillotinePacker::usage = "GuillotinePacker[width, height, options] \
implements different variants of bin packer algorithms that use the \
GUILLOTINE data structure to keep track of the free space of the bin where rectangles may be placed.

Variables:
width - Integer
height - Integer
Options:
\"MergeFreeRectangles\" - (Boolean : True) - If true, performs Rectangle Merge operations during the packing process.
\"FreeChoiceHeuristic\" - (FreeRectChoiceHeuristicGuillotine : \"BestAreaFit\") - The free rectangle choice heuristic rule to use, allowed options are
{
\"BestAreaFit\",
\"BestShortSideFit\",
\"BestLongSideFit\",
\"WorstAreaFit\",
\"WorstShortSideFit\",
\"WorstLongSideFit\"
}
\"SplitHeuristic\" - (GuillotineSplitHeuristic : \"ShorterLeftoverAxis\") - The free rectangle split heuristic rule to use, options include
{
\"ShorterLeftoverAxis\",
\"LongerLeftoverAxis\",
\"MinimizeArea\",
\"MaximizeArea\",
\"ShorterAxis\",
\"LongerAxis\"
}

Returns: WLRectanglePacker object"

Options[GuillotinePacker] = {"FreeChoiceHeuristic" -> "BestAreaFit", "MergeFreeRectangles" -> True, "SplitHeuristic" -> "ShorterLeftoverAxis"};
libfun["GuillotinePacker"] := libfun["GuillotinePacker"] = libraryFunctionLoad[
	$RectanglePackingLibrary, "GuillotinePacker", {Integer, Integer, "Boolean", Integer, Integer, Integer},
	"Void"
];
GuillotinePacker[width_, height_, OptionsPattern[]] := Block[
	{
		options = OptionValue @ {"MergeFreeRectangles", "FreeChoiceHeuristic", "SplitHeuristic"},
		res = CreateManagedLibraryExpression["WLRectanglePacker", WLRectanglePacker]
	},
	Part[options, 2] = enum["FreeRectChoiceHeuristicGuillotine"][options[[2]]];
	Part[options, 3] = enum["GuillotineSplitHeuristic"][options[[3]]];
	Replace[
		Quiet[
			catchThrowErrors[
				libfun["GuillotinePacker"][
					width, height, Sequence @@ options, getManagedID[WLRectanglePacker][res]
				],
				GuillotinePacker
			]
		],
		Null :> res
	]
]



enumerate["FreeRectChoiceHeuristicGuillotine",
	{
		"BestAreaFit", "BestShortSideFit", "BestLongSideFit", "WorstAreaFit", "WorstShortSideFit",
		"WorstLongSideFit"
	}
]



enumerate["GuillotineSplitHeuristic",
	{
		"ShorterLeftoverAxis", "LongerLeftoverAxis", "MinimizeArea", "MaximizeArea",
		"ShorterAxis", "LongerAxis"
	}
]


(* ::Subsection::Closed:: *)
(*WLMaxRectsBinPack*)

MaxRectsPacker::usage = "MaxRectsPacker[width, height, options] \
implements the MAXRECTS data structure and different bin packing \
algorithms that use this structure.

Variables:
width - Integer
height - Integer
Options:
\"AllowFlips\" - (Boolean : True)
\"FreeChoiceHeuristic\" - (FreeRectChoiceHeuristic : \"BestAreaFit\") - The free rectangle choice heuristic rule to use.  Can be one of
{
\"BestShortSideFit\",
\"BestLongSideFit\",
\"BestAreaFit\",
\"BottomLeftRule\",
\"ContactPointRule\"
}

Returns: WLRectanglePacker object"

Options[MaxRectsPacker] = {"AllowFlips" -> True, "FreeChoiceHeuristic" -> "BestAreaFit"};
libfun["MaxRectsPacker"] := libfun["MaxRectsPacker"] = libraryFunctionLoad[
	$RectanglePackingLibrary, "MaxRectsPacker", {Integer, Integer, "Boolean", Integer, Integer},
	"Void"
];
MaxRectsPacker[width_, height_, OptionsPattern[]] := Block[
	{
		options = OptionValue @ {"AllowFlips", "FreeChoiceHeuristic"},
		res = CreateManagedLibraryExpression["WLRectanglePacker", WLRectanglePacker]
	},
	Part[options, 2] = enum["FreeRectChoiceHeuristic"][options[[2]]];
	Replace[
		Quiet[
			catchThrowErrors[
				libfun["MaxRectsPacker"][
					width, height, Sequence @@ options, getManagedID[WLRectanglePacker][res]
				],
				MaxRectsPacker
			]
		],
		Null :> res
	]
]



enumerate["FreeRectChoiceHeuristic",
	{"BestShortSideFit", "BestLongSideFit", "BestAreaFit", "BottomLeftRule", "ContactPointRule"}
]


(* ::Subsection::Closed:: *)
(*WLRectanglePacker*)

methodData[WLRectanglePacker, "InsertRectangle"] = <|
	"Usage" -> "wlrectanglepacker[\"InsertRectangle\", rectangle] \
inserts a single rectangle.

Variables:
rectangle - Integer vector - a list of {width, height} for the rectangle to be inserted.

Returns: Integer matrix - Returns a list {{x1, y1}, {x2, y2}} representing the inserted rectangle.",
	"Parameters" -> {"rectangle"}
|>

libfun["WLRectanglePacker_InsertRectangle"] := libfun["WLRectanglePacker_InsertRectangle"] = libraryFunctionLoad[
	$RectanglePackingLibrary, "WLRectanglePacker_InsertRectangle", {Integer, {Integer, _}},
	{Integer, 2}
];
Pattern[expr, _WLRectanglePacker]["InsertRectangle", rectangle_] := Quiet @ catchThrowErrors[
	libfun["WLRectanglePacker_InsertRectangle"][getManagedID[WLRectanglePacker][expr], rectangle],
	{"WLRectanglePacker", "InsertRectangle"}
]

methodData[WLRectanglePacker, "GetOccupancy"] = <|
	"Usage" -> "wlrectanglepacker[\"GetOccupancy\"] \
computes the ratio of used/total surface area. \
0.00 means no space is yet used, 1.00 means the whole bin is used.

Returns: Real"
|>

libfun["WLRectanglePacker_GetOccupancy"] := libfun["WLRectanglePacker_GetOccupancy"] = libraryFunctionLoad[$RectanglePackingLibrary, "WLRectanglePacker_GetOccupancy", {Integer}, Real];
Pattern[expr, _WLRectanglePacker]["GetOccupancy"] := Quiet @ catchThrowErrors[
	libfun["WLRectanglePacker_GetOccupancy"][getManagedID[WLRectanglePacker][expr]],
	{"WLRectanglePacker", "GetOccupancy"}
]

methodData[WLRectanglePacker, "InsertRectangles"] = <|
	"Usage" -> "wlrectanglepacker[\"InsertRectangles\", rects] \
inserts a list of rectangles.

Variables:
rects - Integer matrix - list of {width, height} pairs

Returns: rank-3 tensor of Integers",
	"Parameters" -> {"rects"}
|>

libfun["WLRectanglePacker_InsertRectangles"] := libfun["WLRectanglePacker_InsertRectangles"] = libraryFunctionLoad[
	$RectanglePackingLibrary, "WLRectanglePacker_InsertRectangles", {Integer, {Integer, _}},
	{Integer, 3}
];
Pattern[expr, _WLRectanglePacker]["InsertRectangles", rects_] := Quiet @ catchThrowErrors[
	libfun["WLRectanglePacker_InsertRectangles"][getManagedID[WLRectanglePacker][expr], rects],
	{"WLRectanglePacker", "InsertRectangles"}
]

methodData[WLRectanglePacker, "PlaceRectangle"] = <|
	"Usage" -> "wlrectanglepacker[\"PlaceRectangle\", rect] \
places a single rectangle in the list of used rectangles and adjusts the
free rectangles accordingly.

Variables:
rect - Integer matrix

Returns: Null",
	"Parameters" -> {"rect"}
|>

libfun["WLRectanglePacker_PlaceRectangle"] := libfun["WLRectanglePacker_PlaceRectangle"] = libraryFunctionLoad[
	$RectanglePackingLibrary, "WLRectanglePacker_PlaceRectangle", {Integer, {Integer, _}},
	"Void"
];
Pattern[expr, _WLRectanglePacker]["PlaceRectangle", rect_] := Quiet @ catchThrowErrors[
	libfun["WLRectanglePacker_PlaceRectangle"][getManagedID[WLRectanglePacker][expr], rect],
	{"WLRectanglePacker", "PlaceRectangle"}
]

methodData[WLRectanglePacker, "GetFreeRectangles"] = <|
	"Usage" -> "wlrectanglepacker[\"GetFreeRectangles\"] \
returns the internal list of disjoint rectangles that track the free area of the bin. \

Returns: rank-3 tensor of Integers"
|>

libfun["WLRectanglePacker_GetFreeRectangles"] := libfun["WLRectanglePacker_GetFreeRectangles"] = libraryFunctionLoad[
	$RectanglePackingLibrary, "WLRectanglePacker_GetFreeRectangles", {Integer}, {Integer, 3}
];
Pattern[expr, _WLRectanglePacker]["GetFreeRectangles"] := Quiet @ catchThrowErrors[
	libfun["WLRectanglePacker_GetFreeRectangles"][getManagedID[WLRectanglePacker][expr]],
	{"WLRectanglePacker", "GetFreeRectangles"}
]

methodData[WLRectanglePacker, "GetUsedRectangles"] = <|
	"Usage" -> "wlrectanglepacker[\"GetUsedRectangles\"] \
returns the list of packed rectangles.

Returns: rank-3 tensor of Integers"
|>

libfun["WLRectanglePacker_GetUsedRectangles"] := libfun["WLRectanglePacker_GetUsedRectangles"] = libraryFunctionLoad[
	$RectanglePackingLibrary, "WLRectanglePacker_GetUsedRectangles", {Integer}, {Integer, 3}
];
Pattern[expr, _WLRectanglePacker]["GetUsedRectangles"] := Quiet @ catchThrowErrors[
	libfun["WLRectanglePacker_GetUsedRectangles"][getManagedID[WLRectanglePacker][expr]],
	{"WLRectanglePacker", "GetUsedRectangles"}
]

methodData[WLRectanglePacker, "GetDimensions"] = <|
	"Usage" -> "wlrectanglepacker[\"GetDimensions\"] \
returns the bounding box dimensions {w,h}.

Returns: Integer vector"
|>

libfun["WLRectanglePacker_GetDimensions"] := libfun["WLRectanglePacker_GetDimensions"] = libraryFunctionLoad[
	$RectanglePackingLibrary, "WLRectanglePacker_GetDimensions", {Integer}, {Integer, 1}
];
Pattern[expr, _WLRectanglePacker]["GetDimensions"] := Quiet @ catchThrowErrors[
	libfun["WLRectanglePacker_GetDimensions"][getManagedID[WLRectanglePacker][expr]],
	{"WLRectanglePacker", "GetDimensions"}
]

methodData[WLRectanglePacker, "information"] = <|
	"Usage" -> "wlrectanglepacker[\"information\"] \
gives object information.

Returns: datastore"
|>

libfun["WLRectanglePacker_information"] := libfun["WLRectanglePacker_information"] = libraryFunctionLoad[
	$RectanglePackingLibrary, "WLRectanglePacker_information", {Integer}, "DataStore"
];
Pattern[expr, _WLRectanglePacker]["information"] := fromDataStore @ Quiet @ catchThrowErrors[
	libfun["WLRectanglePacker_information"][getManagedID[WLRectanglePacker][expr]],
	{"WLRectanglePacker", "information"}
]


(* ::Subsection::Closed:: *)
(*WLShelfBinPack*)

ShelfPacker::usage = "ShelfPacker[width, height, options] \
ShelfBinPack implements different bin packing algorithms that use the SHELF \
data structure. ShelfBinPack also uses GuillotineBinPack for the waste map if it is enabled.

Variables:
width - Integer
height - Integer
Options:
\"UseWasteMap\" - (Boolean : True) - If true, uses GuillotineBinPack for the waste map.
\"FreeChoiceHeuristic\" - (ShelfChoiceHeuristic : \"BestAreaFit\") - The free rectangle choice heuristic rule to use, allowed options are
{
\"NextFit\",
\"FirstFit\",
\"BestAreaFit\",
\"WorstAreaFit\",
\"BestHeightFit\",
\"BestWidthFit\",
\"WorstWidthFit\"

Returns: WLRectanglePacker object"

Options[ShelfPacker] = {"FreeChoiceHeuristic" -> "BestAreaFit", "UseWasteMap" -> True};
libfun["ShelfPacker"] := libfun["ShelfPacker"] = libraryFunctionLoad[
	$RectanglePackingLibrary, "ShelfPacker", {Integer, Integer, "Boolean", Integer, Integer},
	"Void"
];
ShelfPacker[width_, height_, OptionsPattern[]] := Block[
	{
		options = OptionValue @ {"UseWasteMap", "FreeChoiceHeuristic"},
		res = CreateManagedLibraryExpression["WLRectanglePacker", WLRectanglePacker]
	},
	Part[options, 2] = enum["ShelfChoiceHeuristic"][options[[2]]];
	Replace[
		Quiet[
			catchThrowErrors[
				libfun["ShelfPacker"][
					width, height, Sequence @@ options, getManagedID[WLRectanglePacker][res]
				],
				ShelfPacker
			]
		],
		Null :> res
	]
]



enumerate["ShelfChoiceHeuristic",
	{
		"NextFit", "FirstFit", "BestAreaFit", "WorstAreaFit", "BestHeightFit", "BestWidthFit",
		"WorstWidthFit"
	}
]


(* ::Subsection::Closed:: *)
(*WLSkylineBinPack*)

SkylinePacker::usage = "SkylinePacker[width, height, options] \
Implements bin packing algorithms that use the SKYLINE data structure to store the bin contents. Uses \
GuillotineBinPack as the waste map.

Variables:
width - Integer
height - Integer
Options:
\"UseWasteMap\" - (Boolean : True) - If true, uses GuillotineBinPack for the waste map.
\"FreeChoiceHeuristic\" - (LevelChoiceHeuristic : \"BestFit\") - The free rectangle choice heuristic rule to use, allowed options are
{
\"BottomLeft\",
\"BestFit\"
}

Returns: WLRectanglePacker object"

Options[SkylinePacker] = {"FreeChoiceHeuristic" -> "BestFit", "UseWasteMap" -> True};
libfun["SkylinePacker"] := libfun["SkylinePacker"] = libraryFunctionLoad[
	$RectanglePackingLibrary, "SkylinePacker", {Integer, Integer, "Boolean", Integer, Integer},
	"Void"
];
SkylinePacker[width_, height_, OptionsPattern[]] := Block[
	{
		options = OptionValue @ {"UseWasteMap", "FreeChoiceHeuristic"},
		res = CreateManagedLibraryExpression["WLRectanglePacker", WLRectanglePacker]
	},
	Part[options, 2] = enum["LevelChoiceHeuristic"][options[[2]]];
	Replace[
		Quiet[
			catchThrowErrors[
				libfun["SkylinePacker"][
					width, height, Sequence @@ options, getManagedID[WLRectanglePacker][res]
				],
				SkylinePacker
			]
		],
		Null :> res
	]
]



enumerate["LevelChoiceHeuristic", {"BottomLeft", "BestFit"}]

(*
	End autogenerated code block.
*)



End[] (* End Private Context *)

EndPackage[]