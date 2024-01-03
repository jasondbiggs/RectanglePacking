


#=============================================
#==========  Post Install WL code ============
#=============================================


			
set(WL_RUN_TESTS
			[===[
			(*SetOptions["stdout", PageWidth -> Infinity];*)
			PacletDirectoryLoad["${CMAKE_INSTALL_PREFIX}"];
			print[args___] := Print[OutputForm[Row[{args}]]];
			If[Head[testfile] =!= String, Print["No test file ", testfile];Exit[1]];
			TestDataDirectory = "${TESTDATA_DIRECTORY}";
			res = TestReport[testfile, ProgressReporting -> False];
			If[TrueQ[res["ReportSucceeded"]],
				print[FileBaseName[testfile],": ",Length[res["ResultsByOutcome"]["Success"]], " tests passed in ", res["AbsoluteTimeUsed"]];
				Exit[0],
				print[FileBaseName[testfile],": ","Tests failed"];
				Print[KeyDrop[res["ResultsByOutcome"], "Success"]];
				Exit[1]
			]
			]===])


string(REGEX REPLACE "[\t\r\n]+" "" WL_RUN_TESTS "${WL_RUN_TESTS}")
string(CONFIGURE "${WL_RUN_TESTS}" WL_RUN_TESTS)

add_custom_target(wltest)


file(GLOB_RECURSE TEST_FILES "${TESTFILE_DIR}/*.wlt")
foreach(file ${TEST_FILES})
	get_filename_component(base_filename ${file} NAME)
	add_custom_command(TARGET wltest
		COMMAND ${WOLFRAMKERNEL_DEFAULT} -noprompt -run "testfile = \"${file}\"; ${WL_RUN_TESTS}"
		COMMENT "Running test file ${base_filename}"
		VERBATIM
	)
endforeach()
