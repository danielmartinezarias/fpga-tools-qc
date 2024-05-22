# ------------------------------------------------------------------------
# File: led.tcl
#
# Do NOT modify this script.
#
# Copyright (c) 2022-2023 Opal Kelly Incorporated
# ------------------------------------------------------------------------
source_ipfile "xgui/led_struct.tcl";set projectBoardFile [::ipxit::get_project_property BOARD];set projectBoardFileNameRaw [lindex [split $projectBoardFile :] 1];set projectBoardFile [regsub {_.*} [string toupper $projectBoardFileNameRaw] ""];set defaultBoard "";proc baselineErrorChecking {} {;variable projectBoardFile;variable supportedBoards;set requestedBoard [get_parameter_property "BOARD"];set check_1 [expr {$projectBoardFile != "" && !($projectBoardFile in [dict keys $supportedBoards])}];set check_2 [expr {$projectBoardFile != "" && $requestedBoard != $projectBoardFile}];if {$check_1 || $check_2} {;return true;} else {;return false;};};proc init_params { PROJECT_PARAM.PART PROJECT_PARAM.BOARD PARAM_VALUE.BOARD PARAM_VALUE.WIDTH PARAM_VALUE.DRIVERTYPE PARAM_VALUE.IOSTANDARD } {;variable supportedBoards;variable projectBoardFile;variable defaultBoard;set_property range [returnSupportedBoards] ${PARAM_VALUE.BOARD};set_property range [returnDriverTypes] ${PARAM_VALUE.DRIVERTYPE};if {$projectBoardFile != "" && $projectBoardFile in [dict keys $supportedBoards]} {;set_property value $projectBoardFile ${PARAM_VALUE.BOARD};set boardContent [dict get $supportedBoards $projectBoardFile];set_property value [lindex $boardContent 1] ${PARAM_VALUE.WIDTH};set_property value [lindex $boardContent 2] ${PARAM_VALUE.DRIVERTYPE};set_property range [lindex $boardContent 6] ${PARAM_VALUE.IOSTANDARD};} else {;set projectPart ${PROJECT_PARAM.PART};foreach {key value} $supportedBoards {;set fpgaPartNumber [lindex $value 0];if {$fpgaPartNumber == $projectPart} {;set defaultBoard $key;break;};};if {$defaultBoard ne ""} {;set_property value $defaultBoard ${PARAM_VALUE.BOARD};};};};proc init_gui { IPINST PROJECT_PARAM.BOARD PARAM_VALUE.BOARD} {;variable supportedBoards;variable projectBoardFile;variable defaultBoard;ipgui::add_param $IPINST -name "Component_Name";set ledTop [ipgui::add_page $IPINST -name "Page 0"];set ipVersion [lindex [split [get_property IPDEF $IPINST] ":"] 3];set ipRevision [get_property CORE_REVISION $IPINST];ipgui::add_static_text $IPINST -name spacer -parent $ledTop -has_hypertext true -text "IP Version: <b>$ipVersion (Rev: $ipRevision)</b><br/><br/>";ipgui::add_static_text $IPINST -name LEDsInfo -parent ${ledTop} -text {The LEDs IP will generate the driver logic and PIN & IOSTANDARD constraints for the LEDs on your Opal Kelly board. <ul><li>To turn on an LED, drive a 1 to the <i>led_in</i> port.</li><li>To turn off the LED, drive a 0.</li><li>Ensure port <i>led_out</i> routes to a top-level port</li><li>LED order matches that of the LED's reference designators on your board's PCB.</li></ul>};set Product [ipgui::add_group $IPINST -name "Product" -parent ${ledTop}];set boardNotPresentPanel [ipgui::add_panel $IPINST -parent $Product -name boardNotPresentPanel -layout vertical] ;set BOARD [ipgui::add_param $IPINST -name "BOARD" -parent ${boardNotPresentPanel} -widget comboBox] ;set_property tooltip {Select your Opal Kelly product} ${BOARD};set_property visible false $boardNotPresentPanel;set boardPresentPanel [ipgui::add_panel $IPINST -parent $Product -name boardPresentPanel -layout vertical] ;ipgui::add_static_text $IPINST -name boardPresentText -parent $boardPresentPanel -text "<br/>The <b>$projectBoardFile</b> Opal Kelly board file has been detected within your project. The LEDs IP will be <br/>configured to use this device.";set_property visible false $boardPresentPanel;set boardNotSupported [ipgui::add_panel $IPINST -parent $ledTop -name boardNotSupported -layout vertical] ;ipgui::add_static_text $IPINST -name boardNotSupportedText -parent ${boardNotSupported} -text "<h1>The $projectBoardFile Board File is not supported by the LEDs IP.<h1/>";set_property visible false $boardNotSupported;set partNotCorrectPanel [ipgui::add_panel $IPINST -parent $ledTop -name partNotCorrectPanel -layout vertical] ;ipgui::add_dynamic_text $IPINST -name label_example_design_info -parent $partNotCorrectPanel  -has_hypertext true -tclproc update_gui_for_PARAM_VALUE.BOARD;set_property visible false $partNotCorrectPanel;set Config [ipgui::add_group $IPINST -name "Config" -parent ${ledTop}];set ioStandardPanel [ipgui::add_panel $IPINST -parent $Config -name ioStandardPanel -layout vertical];ipgui::add_dynamic_text $IPINST -name ioStandard_Info -parent $ioStandardPanel  -tclproc ioStandardPanelText;ipgui::add_param $IPINST -name "IOSTANDARD" -parent $ioStandardPanel -widget comboBox;set_property visible false $Config;if { $projectBoardFile == ""} {;set_property visible true $boardNotPresentPanel;if {$defaultBoard eq ""} {;set_property errmsg "The FPGA Part of the currently configured Vivado project does not match any of those on any of our current board offerings. Please select the correct FPGA part for your board or utilize one of our Vivado Board Files that handle FPGA part selection for you." [ipgui::get_paramspec -name BOARD -of $IPINST] -quiet;};} elseif {$projectBoardFile in [dict keys $supportedBoards]} {;set_property visible true $boardPresentPanel;} else {;set_property visible true $boardNotSupported;set_property errmsg "The $projectBoardFile Board File is not supported by the LEDs IP." [ipgui::get_paramspec -name BOARD -of $IPINST] -quiet;};};proc ioStandardPanelText {IPINST PARAM_VALUE.BOARD} {  ;if {[baselineErrorChecking]} {;return;};variable supportedBoards;set productDropDown ${PARAM_VALUE.BOARD};set productDropDownValue [get_property value ${productDropDown}];set boardContent [dict get $supportedBoards $productDropDownValue];set deviceSettingsParam [lindex $boardContent 4];set ledBank [lindex $boardContent 5];set text "The LEDs connected to the <b>$productDropDownValue</b> are on <b>I/O Bank $ledBank</b>, which is powered by <b>$deviceSettingsParam</b> (configured through <i>Device Settings</i>).<br/>";append text "Ensure that <b>$deviceSettingsParam</b> is powered for the LEDs to operate. Please view our getting started guide for setting the <i>Device Settings</i> on your board.<br/>";append text "DRC will warn if you have conflicting IOSTANDARDs on the same I/O bank. Select the IOSTANDARD to be used based on the setting for <b>$deviceSettingsParam</b>";return $text;};proc update_gui_for_PARAM_VALUE.BOARD {IPINST PARAM_VALUE.BOARD PROJECT_PARAM.PART } { ;variable supportedBoards;set projectPart ${PROJECT_PARAM.PART};set productDropDown ${PARAM_VALUE.BOARD};set productDropDownValue [get_property value ${productDropDown}];set_property visible false [ipgui::get_groupspec Config -of $IPINST];set_property visible false [ipgui::get_panelspec partNotCorrectPanel -of $IPINST];if {[baselineErrorChecking]} {;return;};set boardContent [dict get $supportedBoards $productDropDownValue];if {[lindex $boardContent 3] == "true"} {;set_property visible true [ipgui::get_groupspec Config -of $IPINST];};set requestedBoardFPGAPart [lindex $boardContent 0];if {$projectPart != $requestedBoardFPGAPart} {;set_property visible true [ipgui::get_panelspec partNotCorrectPanel -of $IPINST];};return "NOTICE - Project is not configured with the correct FPGA part for this board. Please create a new project with the following FPGA part: <b>$requestedBoardFPGAPart</b>";};proc update_PARAM_VALUE.BOARD {PARAM_VALUE.BOARD PROJECT_PARAM.BOARD} {;variable defaultBoard;variable projectBoardFile;set productDropDown ${PARAM_VALUE.BOARD};set productDropDownValue [get_property value ${productDropDown}];if {$defaultBoard eq "" && $projectBoardFile == ""} {;set_property errmsg "The FPGA Part of the currently configured Vivado project does not match any of those on any of our current board offerings. Please select the correct FPGA part for your board or utilize one of our Vivado Board Files that handle FPGA part selection for you. $defaultBoard" $productDropDown  -quiet;};};proc validate_PARAM_VALUE.BOARD {PARAM_VALUE.BOARD PROJECT_PARAM.PART PROJECT_PARAM.BOARD} {;variable supportedBoards;variable projectBoardFile;variable defaultBoard;set productDropDown ${PARAM_VALUE.BOARD};set productDropDownValue [get_property value ${productDropDown}];set projectPart ${PROJECT_PARAM.PART};if {${PROJECT_PARAM.BOARD} != "" && !($projectBoardFile in [dict keys $supportedBoards])} {;set_property errmsg "The \"$projectBoardFile\" board file is NOT supported by the LEDs IP. Please configure your Vivado project with a compatible board file." $productDropDown;return false;};if {${PROJECT_PARAM.BOARD} != "" && $projectBoardFile != $productDropDownValue} {;set_property errmsg "The project's board file is: \"$projectBoardFile\". This is NOT equal to the requested board: \"$productDropDownValue\". Please configure your Vivado project with the correct board file." $productDropDown;return false;};set boardContent [dict get $supportedBoards $productDropDownValue];set boardPart [lindex $boardContent 0];if {$projectPart != $boardPart} {;set_property errmsg "The project's FPGA Part is: \"$projectPart\". This is NOT equal to the requested $productDropDownValue's FPGA Part of: \"$boardPart\". Please change your project's FPGA Part to the $productDropDownValue's onboard \"$boardPart\" FPGA." $productDropDown;};if {$defaultBoard eq "" && $projectBoardFile == ""} {;set_property errmsg "The FPGA Part of the currently configured Vivado project does not match any of those on any of our current board offerings. Please select the correct FPGA part for your board or utilize one of our Vivado Board Files that handle FPGA part selection for you. $defaultBoard" $productDropDown;};return true;};proc update_PARAM_VALUE.DRIVERTYPE { PARAM_VALUE.DRIVERTYPE PARAM_VALUE.BOARD } {;if {[baselineErrorChecking]} {;return;};variable supportedBoards;set productDropDown ${PARAM_VALUE.BOARD};set productDropDownValue [get_property value ${productDropDown}];set boardContent [dict get $supportedBoards $productDropDownValue];set_property value [lindex $boardContent 2] ${PARAM_VALUE.DRIVERTYPE};};proc validate_PARAM_VALUE.DRIVERTYPE { PARAM_VALUE.DRIVERTYPE PARAM_VALUE.BOARD } {;if {[baselineErrorChecking]} {;return true;};variable supportedBoards;set productDropDownValue [get_property value ${PARAM_VALUE.BOARD}];set configDriverType [get_property value ${PARAM_VALUE.DRIVERTYPE}];set boardContent [dict get $supportedBoards $productDropDownValue];set boardDrivertype [lindex $boardContent 2];if {$configDriverType != $boardDrivertype} {;set_property errmsg "CONFIG.DRIVERTYPE is an internal parameter, do NOT edit this parameter. On the $productDropDownValue, \"$boardDrivertype\" is the only supported value for DRIVERTYPE." ${PARAM_VALUE.DRIVERTYPE};return false;};return true;};proc update_PARAM_VALUE.WIDTH { PARAM_VALUE.WIDTH PARAM_VALUE.BOARD } {;if {[baselineErrorChecking]} {;return;};variable supportedBoards;set productDropDown ${PARAM_VALUE.BOARD};set productDropDownValue [get_property value ${productDropDown}];set boardContent [dict get $supportedBoards $productDropDownValue];set width ${PARAM_VALUE.WIDTH};set_property value [lindex $boardContent 1] $width;};proc validate_PARAM_VALUE.WIDTH { PARAM_VALUE.WIDTH PARAM_VALUE.BOARD} {;if {[baselineErrorChecking]} {;return true;};variable supportedBoards;set productDropDownValue [get_property value ${PARAM_VALUE.BOARD}];set configWidth [get_property value ${PARAM_VALUE.WIDTH}];set boardContent [dict get $supportedBoards $productDropDownValue];set boardWidth [lindex $boardContent 1];if {$configWidth != $boardWidth} {;set_property errmsg "CONFIG.WIDTH is an internal parameter, do NOT edit this parameter. On the $productDropDownValue, \"$boardWidth\" is the only supported value for WIDTH" ${PARAM_VALUE.WIDTH};return false;};return true;};proc update_PARAM_VALUE.IOSTANDARD { PARAM_VALUE.IOSTANDARD PARAM_VALUE.BOARD } {;if {[baselineErrorChecking]} {;return;};variable supportedBoards;set productDropDownValue [get_property value ${PARAM_VALUE.BOARD}];set boardContent [dict get $supportedBoards $productDropDownValue];set_property range [lindex $boardContent 6] ${PARAM_VALUE.IOSTANDARD};};proc validate_PARAM_VALUE.IOSTANDARD { PARAM_VALUE.IOSTANDARD PARAM_VALUE.BOARD } {;if {[baselineErrorChecking]} {;return true;};variable supportedBoards;set productDropDownValue [get_property value ${PARAM_VALUE.BOARD}];set configIOSTANDARD [get_property value ${PARAM_VALUE.IOSTANDARD}];set boardContent [dict get $supportedBoards $productDropDownValue];set boardIsIOSTANDARDSupported [lindex $boardContent 3];set boardIOSTANDARDS [lindex $boardContent 6];if {$boardIsIOSTANDARDSupported == "false" &&  $configIOSTANDARD != "LVCMOS12"} {;set_property errmsg "Setting CONFIG.IOSTANDARD is not supported on the $productDropDownValue" ${PARAM_VALUE.IOSTANDARD};return false;} elseif {$boardIsIOSTANDARDSupported == "true" &&  !($configIOSTANDARD in [split $boardIOSTANDARDS ","])} {;set_property errmsg "\"$configIOSTANDARD\" CONFIG.IOSTANDARD is not supported on the $productDropDownValue. Supported values are: \"$boardIOSTANDARDS\"" ${PARAM_VALUE.IOSTANDARD};return false;};return true;};proc update_PARAM_VALUE.LED_OUT_BOARD_INTERFACE { PARAM_VALUE.LED_OUT_BOARD_INTERFACE IPINST PROJECT_PARAM.BOARD } {;set param_range [get_board_interface_param_range $IPINST -name "LED_OUT_BOARD_INTERFACE"];set_property range $param_range ${PARAM_VALUE.LED_OUT_BOARD_INTERFACE};};proc validate_PARAM_VALUE.LED_OUT_BOARD_INTERFACE { PARAM_VALUE.LED_OUT_BOARD_INTERFACE } {;return true;};proc update_PARAM_VALUE.LED_OUT_TRISTATE_BOARD_INTERFACE { PARAM_VALUE.LED_OUT_TRISTATE_BOARD_INTERFACE IPINST PROJECT_PARAM.BOARD } {;set param_range [get_board_interface_param_range $IPINST -name "LED_OUT_TRISTATE_BOARD_INTERFACE"];set_property range $param_range ${PARAM_VALUE.LED_OUT_TRISTATE_BOARD_INTERFACE};};proc validate_PARAM_VALUE.LED_OUT_TRISTATE_BOARD_INTERFACE { PARAM_VALUE.LED_OUT_TRISTATE_BOARD_INTERFACE } {;return true;};