:: run the GHDL compiler and run GTKwave
:: Univ. Bremerhaven
:: Kai Mueller - 27-APR-2020

@echo off

if %1.==. (
	echo usage: runghdl [toplevel file w/o extension] {stop_time}
	echo example 1: runghdl topl
	echo example 2: runghdl topl 150ns
	goto xend
)

cls
echo Start of processing...
:: source file processing

SETLOCAL ENABLEDELAYEDEXPANSION
for %%A in (*.vhd) do (
	set fname=%%A
	set uname=%%~nA
	if !fname!==!fname:vhd~=! (
		echo exec: ghdl -a !fname!
		ghdl -a !fname!
		if errorlevel 1 goto xerror
		echo exec: ghdl -s !fname!
		ghdl -s !fname!
		if errorlevel 1 goto xerror
		echo exec: ghdl -e !uname!
		ghdl -e !uname!
	if errorlevel 1 goto xerror
	) else (
		echo *** skipping !fname!
	)
)
ENDLOCAL
if %2.==. (
	echo exec: ghdl -r %1 --wave=%1.ghw
	ghdl -r %1 --wave=%1.ghw
) else (
	echo run for %2...
	echo exec: ghdl -r %1 --wave=%1.ghw --stop-time=%2
	ghdl -r %1 --wave=%1.ghw --stop-time=%2
)
if errorlevel 1 goto xerror

:: view waveform
echo exec: gtkwave %1.ghw
gtkwave %1.ghw
goto xend

:xerror
echo *** no success, see error message(s).

:xend
echo simghdl exiting.
