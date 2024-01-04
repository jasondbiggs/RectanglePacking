BeginTestSection["TestRectanglePacking"]


VerificationTest[
	Needs @ "JasonB`RectanglePacking`"
	,
	Null
	,
	{}
	,
	TestID->"TestRectanglePacking_20240103-MJWS2J"
]


VerificationTest[
	MatchQ[JasonB`RectanglePacking`RectanglePacker @ {200, 120},
		HoldPattern[JasonB`RectanglePacking`RectanglePacker @ _String]
	]
	,
	True
	,
	{}
	,
	TestID->"TestRectanglePacking_20240103-PLEG7Z"
]


VerificationTest[
	Block[{rp = JasonB`RectanglePacking`RectanglePacker @ {200, 120}},
		rp["Insert", {15, 15}]
	]
	,
	{{0, 0}, {15, 15}}
	,
	{}
	,
	TestID->"TestRectanglePacking_20240103-WHQI49"
]


VerificationTest[
	Block[{rp = JasonB`RectanglePacking`RectanglePacker @ {200, 120}},
		rp["Insert", {15, 200}]
	]
	,
	{{0, 0}, {200, 15}}
	,
	{}
	,
	TestID->"TestRectanglePacking_20240103-MUDRI5"
]


VerificationTest[
	Block[{rp = JasonB`RectanglePacking`RectanglePacker[{200, 120}, "AllowFlips" -> False]},
		rp["Insert", {15, 200}]
	]
	,
	Failure["UnplacedRectangle", <|"Input" -> {15, 200}|>]
	,
	{HoldForm[Message[PackRectangles::nopac, 1]]}
	,
	TestID->"TestRectanglePacking_20240103-3T891Y"
]


VerificationTest[
	Block[{rp = JasonB`RectanglePacking`RectanglePacker[{200, 120}, "Skyline"]},
		rp["Insert",
			{
				{12, 7},
				{10, 13},
				{5, 3},
				{2, 14},
				{16, 6},
				{16, 18},
				{14, 9},
				{10, 6},
				{5, 12},
				{3, 15},
				{14, 15},
				{5, 5},
				{11, 18},
				{4, 18},
				{9, 6},
				{18, 17},
				{2, 9},
				{11, 15},
				{4, 11},
				{16, 2}
			}
		]
	]
	,
	{
		{{140, 0}, {152, 7}},
		{{166, 0}, {179, 10}},
		{{39, 0}, {44, 3}},
		{{0, 0}, {14, 2}},
		{{105, 0}, {121, 6}},
		{{39, 3}, {57, 19}},
		{{152, 0}, {166, 9}},
		{{121, 0}, {131, 6}},
		{{88, 0}, {100, 5}},
		{{44, 0}, {59, 3}},
		{{15, 2}, {30, 16}},
		{{100, 0}, {105, 5}},
		{{179, 0}, {197, 11}},
		{{59, 0}, {77, 4}},
		{{131, 0}, {140, 6}},
		{{59, 4}, {77, 21}},
		{{14, 0}, {23, 2}},
		{{0, 2}, {15, 13}},
		{{77, 0}, {88, 4}},
		{{23, 0}, {39, 2}}
	}
	,
	{}
	,
	TestID->"TestRectanglePacking_20240103-LEYWHK"
]


VerificationTest[
	Module[{res, test},
		BlockRandom[
			SeedRandom @ 24;
			test = JasonB`RectanglePacking`RectanglePacker[{120, 60}, "Shelf"];
			res = DeleteCases[test["Insert", RandomInteger[{2, 20}, {500, 2}]], _Failure];
			{Length @ res, test @ "PackedRectangleCount"}
		]
	]
	,
	{84, 84}
	,
	{HoldForm[Message[PackRectangles::nopac, 416]]}
	,
	TestID->"TestRectanglePacking_20240104-0J3FJQ"
]


VerificationTest[
	Module[{res, test},
		BlockRandom[
			SeedRandom @ 24;
			test = JasonB`RectanglePacking`RectanglePacker[{120, 60}, "MaxRectsBestLongSide"];
			res = DeleteCases[test["Insert", RandomInteger[{2, 20}, {500, 2}]], _Failure];
			{Length @ res, test @ "PackedRectangleCount"}
		]
	]
	,
	{34, 34}
	,
	{HoldForm[Message[PackRectangles::nopac, 466]]}
	,
	TestID->"TestRectanglePacking_20240104-FZ16OW"
]


VerificationTest[
	Module[{res, test},
		BlockRandom[
			SeedRandom @ 24;
			test = JasonB`RectanglePacking`RectanglePacker[{120, 60}, "Shelf"];
			res = Quiet[
				DeleteCases[
					Map[test["Insert", #]&,
						RandomInteger[{2, 20}, {500, 2}]
					],
					_Failure
				]
			];
			{Length @ res, test @ "PackedRectangleCount"}
		]
	]
	,
	{84, 84}
	,
	{}
	,
	TestID->"TestRectanglePacking_20240104-KVWU7R"
]


VerificationTest[
	Module[{res, test},
		BlockRandom[
			SeedRandom @ 24;
			test = JasonB`RectanglePacking`RectanglePacker @ {120, 60};
			res = Quiet[
				DeleteCases[
					Map[test["Insert", #]&,
						RandomInteger[{2, 20}, {500, 2}]
					],
					_Failure
				]
			];
			{Length @ res, test @ "PackedRectangleCount"}
		]
	]
	,
	{85, 85}
	,
	{}
	,
	TestID->"TestRectanglePacking_20240104-1JYJ5Q"
]


VerificationTest[
	Module[{res, test},
		BlockRandom[
			SeedRandom @ 24;
			test = JasonB`RectanglePacking`RectanglePacker @ {120, 60};
			res = Quiet[
				DeleteCases[
					Function[test["Insert", #]][RandomInteger[{2, 20}, {500, 2}]],
					_Failure
				]
			];
			{Length @ res, test @ "PackedRectangleCount"}
		]
	]
	,
	{30, 30}
	,
	{}
	,
	TestID->"TestRectanglePacking_20240104-YC6WL1"
]


VerificationTest[
	Module[{res, test},
		BlockRandom[
			SeedRandom @ 24;
			test = JasonB`RectanglePacking`RectanglePacker[{120, 60}, "Skyline"];
			res = Quiet[
				DeleteCases[
					Function[test["Insert", #]][RandomInteger[{2, 20}, {500, 2}]],
					_Failure
				]
			];
			{Length @ res, test @ "PackedRectangleCount"}
		]
	]
	,
	{162, 162}
	,
	{}
	,
	TestID->"TestRectanglePacking_20240104-3XLET6"
]


VerificationTest[
	Module[{res, test},
		BlockRandom[
			SeedRandom @ 24;
			test = JasonB`RectanglePacking`RectanglePacker[{120, 60}, "Skyline"];
			res = Quiet[
				DeleteCases[
					Map[test["Insert", #]&,
						RandomInteger[{2, 20}, {500, 2}]
					],
					_Failure
				]
			];
			{Length @ res, test @ "PackedRectangleCount"}
		]
	]
	,
	{82, 82}
	,
	{}
	,
	TestID->"TestRectanglePacking_20240104-PCNN1S"
]


VerificationTest[
	FailureQ[JasonB`RectanglePacking`RectanglePacker[{120, -60}, "Skyline"]]
	,
	True
	,
	{}
	,
	TestID->"TestRectanglePacking_20240104-QR33GI"
]


VerificationTest[
	FailureQ[JasonB`RectanglePacking`RectanglePacker[{120, 60.}, "Skyline"]]
	,
	True
	,
	{PackRectangles::notrec}
	,
	TestID->"TestRectanglePacking_20240104-P8XURG"
]


VerificationTest[
	FailureQ[JasonB`RectanglePacking`RectanglePacker[{120, 60.}, "Skyline"]]
	,
	True
	,
	{HoldForm[Message[PackRectangles::notrec, {120, 60.}]]}
	,
	TestID->"TestRectanglePacking_20240104-6G604A"
]


VerificationTest[
	BlockRandom[
		SameQ[
			SeedRandom @ 22;
			JasonB`RectanglePacking`PackRectangles[{200, 100}, RandomInteger[{10, 18}, {67, 2}]],
			SeedRandom @ 22;
			JasonB`RectanglePacking`PackRectangles[{200, 100}, RandomInteger[{10, 18}, {67, 2}], "MaxRects"]
		]
	]
	,
	True
	,
	{}
	,
	TestID->"TestRectanglePacking_20240104-FCO4HK"
]


VerificationTest[
	BlockRandom[
		SeedRandom @ 22;
		ArrayQ[
			JasonB`RectanglePacking`PackRectangles[{200, 100}, RandomInteger[{10, 18}, {67, 2}]]
		]
	]
	,
	True
	,
	{}
	,
	TestID->"TestRectanglePacking_20240104-O9NJD8"
]


VerificationTest[
	BlockRandom[
		SeedRandom @ 22;
		FailureQ[
			JasonB`RectanglePacking`PackRectangles[{200, -100}, RandomInteger[{10, 18}, {67, 2}]]
		]
	]
	,
	True
	,
	{}
	,
	TestID->"TestRectanglePacking_20240104-80J3K3"
]


VerificationTest[
	BlockRandom[
		SeedRandom @ 22;
		FailureQ[
			JasonB`RectanglePacking`PackRectangles[{200, 100}, RandomInteger[{10, 18}, {67, 2}], "NotAMethod"]
		]
	]
	,
	True
	,
	{}
	,
	TestID->"TestRectanglePacking_20240104-KSNAZ2"
]


VerificationTest[
	BlockRandom[
		SeedRandom @ 22;
		FailureQ[
			JasonB`RectanglePacking`PackRectangles[{200, 100},
				RandomInteger[{10, 18}, {67, 2}],
				"Skyline",
				JasonB`RectanglePacking`Private`FixedRectangles -> {{{62, 33}, {84, 66}}}
			]
		]
	]
	,
	True
	,
	{}
	,
	TestID->"TestRectanglePacking_20240104-YC1IBT"
]


VerificationTest[
	BlockRandom[
		SeedRandom @ 22;
		ArrayQ[
			JasonB`RectanglePacking`PackRectangles[{200, 100},
				RandomInteger[{10, 18}, {67, 2}],
				JasonB`RectanglePacking`Private`FixedRectangles -> {{{62, 33}, {84, 66}}}
			]
		]
	]
	,
	True
	,
	{}
	,
	TestID->"TestRectanglePacking_20240104-C1WUJF"
]


EndTestSection[]
