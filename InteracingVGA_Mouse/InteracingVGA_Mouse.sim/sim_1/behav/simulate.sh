#!/bin/sh -f
xv_path="/opt/Xilinx/Vivado/2015.2"
ExecStep()
{
"$@"
RETVAL=$?
if [ $RETVAL -ne 0 ]
then
exit $RETVAL
fi
}
ExecStep $xv_path/bin/xsim ProcessorSim_behav -key {Behavioral:sim_1:Functional:ProcessorSim} -tclbatch ProcessorSim.tcl -log simulate.log
