{
  description = "zkPrologML - JupyterLite/PipeLite Dashboard";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # JupyterLite build
        jupyterlite = pkgs.python3Packages.buildPythonApplication {
          pname = "jupyterlite";
          version = "0.2.0";
          
          src = pkgs.fetchPypi {
            pname = "jupyterlite-core";
            version = "0.2.0";
            sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
          };
          
          propagatedBuildInputs = with pkgs.python3Packages; [
            jupyter-core
            jupyterlab
            notebook
          ];
        };
        
        # Dashboard content
        dashboardContent = pkgs.writeTextFile {
          name = "dashboard.html";
          text = ''
            <!DOCTYPE html>
            <html>
            <head>
              <title>zkPrologML Dashboard</title>
              <meta charset="utf-8">
              <style>
                body {
                  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                  margin: 0;
                  padding: 20px;
                  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                }
                .container {
                  max-width: 1400px;
                  margin: 0 auto;
                  background: white;
                  border-radius: 10px;
                  padding: 30px;
                  box-shadow: 0 10px 40px rgba(0,0,0,0.3);
                }
                h1 {
                  color: #667eea;
                  text-align: center;
                  margin-bottom: 10px;
                }
                .subtitle {
                  text-align: center;
                  color: #666;
                  margin-bottom: 30px;
                }
                .stats {
                  display: grid;
                  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                  gap: 20px;
                  margin-bottom: 30px;
                }
                .stat-card {
                  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                  color: white;
                  padding: 20px;
                  border-radius: 8px;
                  text-align: center;
                }
                .stat-value {
                  font-size: 2em;
                  font-weight: bold;
                }
                .stat-label {
                  font-size: 0.9em;
                  opacity: 0.9;
                }
                .section {
                  margin: 30px 0;
                  padding: 20px;
                  background: #f8f9fa;
                  border-radius: 8px;
                }
                .section h2 {
                  color: #667eea;
                  margin-top: 0;
                }
                .graph-container {
                  text-align: center;
                  margin: 20px 0;
                }
                .graph-container img {
                  max-width: 100%;
                  border-radius: 8px;
                  box-shadow: 0 4px 6px rgba(0,0,0,0.1);
                }
                .button {
                  display: inline-block;
                  padding: 10px 20px;
                  background: #667eea;
                  color: white;
                  text-decoration: none;
                  border-radius: 5px;
                  margin: 5px;
                }
                .button:hover {
                  background: #764ba2;
                }
                .theorem-list {
                  list-style: none;
                  padding: 0;
                }
                .theorem-list li {
                  padding: 10px;
                  margin: 5px 0;
                  background: white;
                  border-left: 4px solid #667eea;
                  border-radius: 4px;
                }
                .theorem-list li::before {
                  content: "✅ ";
                }
              </style>
            </head>
            <body>
              <div class="container">
                <h1>🔮 zkPrologML Dashboard</h1>
                <p class="subtitle">Monster Group Knowledge System</p>
                
                <div class="stats">
                  <div class="stat-card">
                    <div class="stat-value">8,017,192</div>
                    <div class="stat-label">Files Indexed</div>
                  </div>
                  <div class="stat-card">
                    <div class="stat-value">71</div>
                    <div class="stat-label">Monster Shards</div>
                  </div>
                  <div class="stat-card">
                    <div class="stat-value">42</div>
                    <div class="stat-label">Entities Unified</div>
                  </div>
                  <div class="stat-card">
                    <div class="stat-value">10</div>
                    <div class="stat-label">Theorems Proven</div>
                  </div>
                  <div class="stat-card">
                    <div class="stat-value">250 MB</div>
                    <div class="stat-label">Master Parquet</div>
                  </div>
                  <div class="stat-card">
                    <div class="stat-value">99.6%</div>
                    <div class="stat-label">Prediction Accuracy</div>
                  </div>
                </div>
                
                <div class="section">
                  <h2>📊 Monster Group Visualization</h2>
                  <div class="graph-container">
                    <img src="monster_graph.png" alt="Monster Group Graph">
                  </div>
                  <p>Graph partitioned along Monster Group shards using METIS. 
                     22 vertices colored by shard (hue = shard/71).</p>
                </div>
                
                <div class="section">
                  <h2>✅ Proven Theorems</h2>
                  <ul class="theorem-list">
                    <li><strong>eigenvector_in_monster</strong> (Lean4) - All eigenvector components ∈ [0, 70]</li>
                    <li><strong>transform_preserves_monster</strong> (Lean4) - Transformation preserves Monster Group</li>
                    <li><strong>eigenvector_is_automorphic</strong> (Lean4) - Eigenvector is automorphic</li>
                    <li><strong>classify_total</strong> (Lean4) - Classification is total</li>
                    <li><strong>classify_deterministic</strong> (Lean4) - Classification is deterministic</li>
                    <li><strong>classes_disjoint</strong> (Lean4) - Classes are disjoint</li>
                    <li><strong>all_godel_valid</strong> (Prolog) - All Gödel numbers valid</li>
                    <li><strong>godel_equals_shard</strong> (Prolog) - Gödel = Shard</li>
                    <li><strong>usage_graph_acyclic</strong> (Prolog) - Usage graph is acyclic</li>
                    <li><strong>table_complete</strong> (Prolog) - Global table is complete</li>
                  </ul>
                </div>
                
                <div class="section">
                  <h2>🚀 Quick Actions</h2>
                  <a href="lab/index.html" class="button">Open JupyterLab</a>
                  <a href="notebooks/analysis.ipynb" class="button">Run Analysis</a>
                  <a href="data/master.parquet" class="button">Download Data</a>
                  <a href="proofs/unified_kb.pl" class="button">View Unified KB</a>
                </div>
                
                <div class="section">
                  <h2>📈 Natural Classes Distribution</h2>
                  <table style="width:100%; border-collapse: collapse;">
                    <tr style="background:#667eea; color:white;">
                      <th style="padding:10px; text-align:left;">Class</th>
                      <th style="padding:10px; text-align:right;">Files</th>
                      <th style="padding:10px; text-align:right;">Sum Range</th>
                      <th style="padding:10px; text-align:right;">Percentage</th>
                    </tr>
                    <tr style="background:#f8f9fa;">
                      <td style="padding:10px;">very_low</td>
                      <td style="padding:10px; text-align:right;">2,019,433</td>
                      <td style="padding:10px; text-align:right;">3-49</td>
                      <td style="padding:10px; text-align:right;">25.19%</td>
                    </tr>
                    <tr>
                      <td style="padding:10px;">low</td>
                      <td style="padding:10px; text-align:right;">2,029,679</td>
                      <td style="padding:10px; text-align:right;">50-85</td>
                      <td style="padding:10px; text-align:right;">25.32%</td>
                    </tr>
                    <tr style="background:#f8f9fa;">
                      <td style="padding:10px;">medium</td>
                      <td style="padding:10px; text-align:right;">1,976,504</td>
                      <td style="padding:10px; text-align:right;">86-120</td>
                      <td style="padding:10px; text-align:right;">24.65%</td>
                    </tr>
                    <tr>
                      <td style="padding:10px;">high</td>
                      <td style="padding:10px; text-align:right;">1,635,690</td>
                      <td style="padding:10px; text-align:right;">121-149</td>
                      <td style="padding:10px; text-align:right;">20.40%</td>
                    </tr>
                    <tr style="background:#f8f9fa;">
                      <td style="padding:10px;">very_high</td>
                      <td style="padding:10px; text-align:right;">355,886</td>
                      <td style="padding:10px; text-align:right;">150-173</td>
                      <td style="padding:10px; text-align:right;">4.44%</td>
                    </tr>
                  </table>
                </div>
                
                <div class="section">
                  <h2>🔗 Knowledge Systems</h2>
                  <p>Unified 2^n hierarchical model connecting:</p>
                  <ul>
                    <li><strong>OEIS</strong> (Shard 0) - Integer Sequences</li>
                    <li><strong>LMFDB</strong> (Shard 1) - Modular Forms</li>
                    <li><strong>Zoo</strong> (Shard 2) - Complexity Theory</li>
                    <li><strong>GitHub</strong> (Shard 3) - Source Code</li>
                    <li><strong>HuggingFace</strong> (Shard 4) - ML Models</li>
                    <li><strong>Wikidata</strong> (Shard 5) - Knowledge Base</li>
                    <li><strong>UML/C4</strong> (Shard 6-7) - Architecture</li>
                    <li><strong>ITIL</strong> (Shard 8) - Service Management</li>
                    <li><strong>Monster Group</strong> (Shard 9) - Group Theory</li>
                  </ul>
                </div>
              </div>
            </body>
            </html>
          '';
        };
        
        # Build JupyterLite site
        jupyterliteSite = pkgs.stdenv.mkDerivation {
          name = "zkprologml-jupyterlite";
          
          buildInputs = [ pkgs.python3 pkgs.python3Packages.jupyterlab ];
          
          buildPhase = ''
            mkdir -p $out
            
            # Copy dashboard
            cp ${dashboardContent} $out/index.html
            
            # Copy graph visualization
            cp ${./monster_graph.png} $out/monster_graph.png || true
            
            # Create notebooks directory
            mkdir -p $out/notebooks
            
            # Create data directory
            mkdir -p $out/data
            
            # Create proofs directory
            mkdir -p $out/proofs
            
            echo "JupyterLite site built"
          '';
          
          installPhase = ''
            echo "Site ready at $out/index.html"
          '';
        };
        
      in {
        packages = {
          default = jupyterliteSite;
          dashboard = jupyterliteSite;
        };
        
        apps = {
          serve = {
            type = "app";
            program = toString (pkgs.writeShellScript "serve-dashboard" ''
              cd ${jupyterliteSite}
              echo "🔮 zkPrologML Dashboard"
              echo "======================="
              echo ""
              echo "Starting server at http://localhost:8000"
              echo ""
              ${pkgs.python3}/bin/python -m http.server 8000
            '');
          };
        };
        
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            python3
            python3Packages.jupyterlab
            python3Packages.notebook
            python3Packages.pandas
            python3Packages.pyarrow
          ];
          
          shellHook = ''
            echo "🔮 zkPrologML JupyterLite Environment"
            echo "====================================="
            echo ""
            echo "Commands:"
            echo "  nix run .#serve    - Start dashboard server"
            echo "  nix build          - Build JupyterLite site"
            echo ""
          '';
        };
      }
    );
}
