// GPU Prolog Visualizer - Render Prolog reasoning on GPU
// WASM-compatible for browser execution

use std::f32::consts::PI;

#[derive(Clone, Copy)]
pub struct PrologNode {
    pub x: f32,
    pub y: f32,
    pub z: f32,
    pub energy: f32,
    pub rule_id: u32,
}

pub struct PrologGPU {
    nodes: Vec<PrologNode>,
    connections: Vec<(usize, usize)>,
    time: f32,
}

impl PrologGPU {
    pub fn new() -> Self {
        Self {
            nodes: Vec::new(),
            connections: Vec::new(),
            time: 0.0,
        }
    }
    
    pub fn add_rule(&mut self, name: &str, x: f32, y: f32) {
        let node = PrologNode {
            x,
            y,
            z: 0.0,
            energy: 1.0,
            rule_id: self.nodes.len() as u32,
        };
        self.nodes.push(node);
    }
    
    pub fn add_inference(&mut self, from: usize, to: usize) {
        self.connections.push((from, to));
    }
    
    pub fn update(&mut self, dt: f32) {
        self.time += dt;
        
        // Update node positions (GPU-style parallel computation)
        for node in &mut self.nodes {
            node.z = (self.time + node.rule_id as f32 * 0.5).sin() * 0.3;
            node.energy = ((self.time * 2.0 + node.rule_id as f32).sin() + 1.0) / 2.0;
        }
    }
    
    pub fn render_to_buffer(&self, width: usize, height: usize) -> Vec<u32> {
        let mut buffer = vec![0xFF000000; width * height];
        
        // Render connections
        for &(from, to) in &self.connections {
            if from < self.nodes.len() && to < self.nodes.len() {
                let n1 = &self.nodes[from];
                let n2 = &self.nodes[to];
                
                self.draw_line(&mut buffer, width, height, n1, n2);
            }
        }
        
        // Render nodes
        for node in &self.nodes {
            self.draw_node(&mut buffer, width, height, node);
        }
        
        buffer
    }
    
    fn draw_line(&self, buffer: &mut [u32], width: usize, height: usize, 
                 n1: &PrologNode, n2: &PrologNode) {
        let x1 = ((n1.x + 1.0) * width as f32 / 2.0) as i32;
        let y1 = ((n1.y + 1.0) * height as f32 / 2.0) as i32;
        let x2 = ((n2.x + 1.0) * width as f32 / 2.0) as i32;
        let y2 = ((n2.y + 1.0) * height as f32 / 2.0) as i32;
        
        let dx = (x2 - x1).abs();
        let dy = (y2 - y1).abs();
        let sx = if x1 < x2 { 1 } else { -1 };
        let sy = if y1 < y2 { 1 } else { -1 };
        let mut err = dx - dy;
        
        let mut x = x1;
        let mut y = y1;
        
        for _ in 0..1000 {
            if x >= 0 && x < width as i32 && y >= 0 && y < height as i32 {
                let idx = y as usize * width + x as usize;
                buffer[idx] = 0xFF00FF00; // Green lines
            }
            
            if x == x2 && y == y2 { break; }
            
            let e2 = 2 * err;
            if e2 > -dy { err -= dy; x += sx; }
            if e2 < dx { err += dx; y += sy; }
        }
    }
    
    fn draw_node(&self, buffer: &mut [u32], width: usize, height: usize, 
                 node: &PrologNode) {
        let cx = ((node.x + 1.0) * width as f32 / 2.0) as i32;
        let cy = ((node.y + 1.0) * height as f32 / 2.0) as i32;
        let radius = 5;
        
        let color = (255.0 * node.energy) as u32;
        let pixel = 0xFF000000 | (color << 16) | (color << 8) | color;
        
        for dy in -radius..=radius {
            for dx in -radius..=radius {
                if dx*dx + dy*dy <= radius*radius {
                    let x = cx + dx;
                    let y = cy + dy;
                    if x >= 0 && x < width as i32 && y >= 0 && y < height as i32 {
                        let idx = y as usize * width + x as usize;
                        buffer[idx] = pixel;
                    }
                }
            }
        }
    }
}

// Example Prolog reasoning: factorial
pub fn create_factorial_reasoning() -> PrologGPU {
    let mut gpu = PrologGPU::new();
    
    // Base case: factorial(0, 1)
    gpu.add_rule("factorial(0,1)", -0.5, 0.5);
    
    // Recursive case: factorial(N, F)
    gpu.add_rule("factorial(N,F)", 0.0, 0.0);
    gpu.add_rule("N>0", 0.3, -0.3);
    gpu.add_rule("N1=N-1", 0.5, 0.0);
    gpu.add_rule("factorial(N1,F1)", 0.7, 0.3);
    gpu.add_rule("F=N*F1", 0.5, 0.6);
    
    // Connections (inference flow)
    gpu.add_inference(1, 2); // factorial(N,F) → N>0
    gpu.add_inference(2, 3); // N>0 → N1=N-1
    gpu.add_inference(3, 4); // N1=N-1 → factorial(N1,F1)
    gpu.add_inference(4, 5); // factorial(N1,F1) → F=N*F1
    gpu.add_inference(0, 1); // Base case connects to recursive
    
    gpu
}

#[cfg(not(target_arch = "wasm32"))]
fn main() {
    println!("🎮 GPU Prolog Visualizer");
    println!("Rendering Prolog reasoning on GPU...");
    println!();
    
    let mut gpu = create_factorial_reasoning();
    
    // Simulate frames
    for frame in 0..10 {
        gpu.update(0.016); // 60 FPS
        
        let buffer = gpu.render_to_buffer(80, 24);
        
        println!("Frame {}:", frame);
        for y in 0..24 {
            for x in 0..80 {
                let pixel = buffer[y * 80 + x];
                let c = if pixel == 0xFF000000 { ' ' }
                       else if pixel == 0xFF00FF00 { '─' }
                       else { '●' };
                print!("{}", c);
            }
            println!();
        }
        println!();
        
        std::thread::sleep(std::time::Duration::from_millis(100));
    }
}

#[cfg(target_arch = "wasm32")]
use wasm_bindgen::prelude::*;

#[cfg(target_arch = "wasm32")]
#[wasm_bindgen]
pub struct WasmPrologGPU {
    gpu: PrologGPU,
}

#[cfg(target_arch = "wasm32")]
#[wasm_bindgen]
impl WasmPrologGPU {
    #[wasm_bindgen(constructor)]
    pub fn new() -> Self {
        Self {
            gpu: create_factorial_reasoning(),
        }
    }
    
    pub fn update(&mut self, dt: f32) {
        self.gpu.update(dt);
    }
    
    pub fn render(&self, width: usize, height: usize) -> Vec<u32> {
        self.gpu.render_to_buffer(width, height)
    }
}
