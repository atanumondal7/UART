from datetime import datetime
import os
import subprocess
import sys

def run_cmd(cmd, check=True):
    print(f"[INFO] Running command: {' '.join(cmd)}")
    result = subprocess.run(cmd, text=True)
    if check and result.returncode != 0:
        print(f"Error command failed with return code {result.returncode}")
        sys.exit(result.returncode)
        
def run_simulation():
    project_dir = os.getcwd()
    history_log_path = os.path.join(project_dir, "simulation_history.log")
    temp_transcript_path = os.path.join(
        project_dir, "_current_run_transcript.tmp"
    )
    
    start_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    run_cmd(["vlib", "work"])
    run_cmd(["vmap", "work", "work"])
    
    compile_cmd = [
        "vlog",
        "-sv",
        "-f",
        "files.f"
    ]
    run_cmd(compile_cmd)
    
    tcl_commands = (
        "vcd file waves.vcd; "
        "vcd add -r /uart_tb_top/*; "
        "onbreak {resume}; "
        "onElabError {resume}; "
        "set NoQuitOnFinish 1; "
        "run -all; "
        "quit -f; "
        )
    
    vsim_cmd = [
        "vsim",
        "-c",
        "work.uart_tb_top",
        "-l",
        temp_transcript_path,
        "-sv_seed",
        "random",
        "-do",
        tcl_commands,
    ]
    
    run_cmd(vsim_cmd, check=False)
    
    run_output = ""
    if os.path.exists(temp_transcript_path):
        with open(temp_transcript_path, "r") as fh:
            run_output = fh.read()
            
    with open(history_log_path, "a") as fh:
        fh.write("\n")
        fh.write("==================================================\n")
        fh.write(f"SIMULATION RUN STARTED: {start_time}\n")
        fh.write(f"Working Directory: {project_dir}\n")
        fh.write("==================================================\n")
        fh.write(run_output)
        
    print(f"[INFO] Appended this run to: {history_log_path}")
    
    if os.path.exists(temp_transcript_path):
        os.remove(temp_transcript_path)
        
if(__name__ == "__main__"):
    run_simulation()