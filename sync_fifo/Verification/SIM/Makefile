# Show available test cases and options
#

run:	info

info:
	@echo "//-------------------------list of alias name available in make file ---------------------//"
	@echo "    along with make pass any of the one parameter to run corresponding test or to open waveform"
	@echo "    all                             ---->   to run all the below test cases use make all command"
	@echo "    base_test                      ---->   to run the sync_fifo_test.sv"
	@echo "    reset_test                    ---->   to run the sync_fifo_reset_test.sv"
	@echo "    write_test                ---->   to run the sync_fifo_write_test.sv"
	@echo "    regression                ---->   to run the regression & source the cmd and open the imc"
	@echo "    waveform                ---->   to open the simvision"
	@echo "    clean                ---->   to delete the previous xrun files and cov files"

	@echo "//---------------------------------------------------------------------------------------//"

# Default target that runs all tests
all: base_test reset_test write_test waveform

# Base test case
base_test:
	@echo "[makefile]  base test case is running"
	xrun -access +rwc -f compile_list.f +UVM_TESTNAME=sync_fifo_test -uvmhome CDNS-1.1d -seed
	@echo "[makefile]  base test case run is completed successfully"

# reset test case
reset_test:
	@echo "[makefile]  reset test case is running"
	xrun -access +rwc -f compile_list.f -uvmhome CDNS-1.1d +UVM_TESTNAME=sync_fifo_write_test
	@echo "[makefile]  reset test case run is completed successfully"

# sync_fifo_write test case
write_test:
	@echo "[makefile]  sync_fifo_write test case running"
	xrun -access +rwc -f compile_list.f +UVM_TESTNAME=sync_fifo_write_test -uvmhome CDNS-1.1d 
	@echo "[makefile]  sync_fifo_write test case run was successful"


#regression
regression:
	@echo "[makefile]  regression running"
	perl sync_fifo_regression.pl test_list.f 1
	source cmd
	imc -exec ./cov_files/cov_merge.cmd
	imc &	
	@echo "[makefile]  regression was successfully completed"

clean :

	rm -rf xrun.log / xrun.history / xcelium.d/ wave.shm/ cov_report.txt / cov_report_html/
	@echo "[makefile]  clean was successfully completed"

# Waveform viewing
waveform:
	simvision wave.shm &

