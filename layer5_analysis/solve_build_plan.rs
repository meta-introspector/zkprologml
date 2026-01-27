use std::process::Command;
use std::fs;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("🔍 Detecting system resources...\n");
    
    // Detect CPUs
    let cpus = num_cpus()?;
    println!("  CPUs: {}", cpus);
    
    // Detect memory
    let memory_gb = detect_memory_gb()?;
    println!("  Memory: {}GB\n", memory_gb);
    
    // Generate MiniZinc data file
    let data = format!(
        "NUM_CPUS = {};\nMEMORY_GB = {};\n",
        cpus, memory_gb
    );
    
    fs::write("build_plan.dzn", &data)?;
    println!("✅ Generated: build_plan.dzn");
    
    // Run MiniZinc solver
    println!("\n🧮 Solving with MiniZinc...\n");
    
    let output = Command::new("minizinc")
        .arg("--solver")
        .arg("gecode")
        .arg("shared/nix/optimal_build_plan.mzn")
        .arg("build_plan.dzn")
        .output()?;
    
    if output.status.success() {
        let result = String::from_utf8_lossy(&output.stdout);
        println!("{}", result);
        
        // Save result
        fs::write("data/docs/OPTIMAL_BUILD_PLAN.txt", result.as_bytes())?;
        println!("✅ Saved: data/docs/OPTIMAL_BUILD_PLAN.txt");
    } else {
        eprintln!("❌ MiniZinc error: {}", String::from_utf8_lossy(&output.stderr));
    }
    
    Ok(())
}

fn num_cpus() -> Result<usize, Box<dyn std::error::Error>> {
    let output = Command::new("nproc").output()?;
    let cpus = String::from_utf8(output.stdout)?.trim().parse()?;
    Ok(cpus)
}

fn detect_memory_gb() -> Result<usize, Box<dyn std::error::Error>> {
    let output = Command::new("sh")
        .arg("-c")
        .arg("free -g | awk '/^Mem:/ {print $2}'")
        .output()?;
    let mem = String::from_utf8(output.stdout)?.trim().parse()?;
    Ok(mem)
}
