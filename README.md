# Nonlocal Metalens Inverse Design

MATLAB pipeline for inverse-designing nonlocal metalenses used as a wavefront-engineering platform in phased arrays. The pipeline supports two operating regimes — **angular-channel compression** (scan-resolution enhancement) and **coherent-aperture expansion** (scan-range preservation) — each implementable as a **flat** or **cylindrical** lens geometry, for a total of four design cases.

Developed and tested with MATLAB R2023b and R2024b.

## Requirements

- MATLAB R2023b or R2024b
- GPU acceleration is optional and controlled via `params.solver.useGPU`; large cylindrical cases (caseID 2, 4) are configured for GPU-accelerated solves by default
- Approximate compute resources per case (single-GPU, A100):

| caseID | Function | Shape | CPU cores | RAM | GPU mem | Time |
|---|---|---|---|---|---|---|
| 1 | Angular-channel compression | Flat | 10 | 100 GB | 40 GB | ~30 h | without field plot
| 2 | Angular-channel compression | Cylindrical | 10 | 60 GB | 40 GB | ~13 h |
| 3 | Coherent-aperture expansion | Flat | 10 | 100 GB | 40 GB | ~48 h |
| 4 | Coherent-aperture expansion | Cylindrical | 10 | 60 GB | 40 GB | ~9 h |

## How to run

1. Open `Main.m`.
2. Set `params.caseID` to one of:
   - `1` — Angular-channel compression, flat lens
   - `2` — Angular-channel compression, cylindrical lens
   - `3` — Coherent-aperture expansion, flat lens
   - `4` — Coherent-aperture expansion, cylindrical lens
3. Adjust top-level parameters as needed (all defined in Section 2–6 of `Main.m`):
   - `params.f0` — operating frequency (default 30 GHz)
   - `params.array.de` — array element spacing (default 0.5λ₀)
   - `params.solver.maxIter`, `params.solver.stepSize` — optimization settings (case-dependent defaults)
   - `params.solver.useGPU` — toggle GPU acceleration
   - `params.material.epsMin` / `epsMax` — allowable relative permittivity range
4. Run `Main.m`. The script will:
   - Build the configuration and target response (`createConfig`, `setupGeometry`)
   - Initialize the design (`initializeDesign`)
   - Run the inverse-design solver (`Solver`)
   - Analyze the final design (`analyzeDesign`)
   - Generate post-processing outputs, including HFSS automation exports (`PostProcessing`)

## Repository structure

```
Main.m
│
├── Config/
│   └── createConfig.m
│
├── Geometry/
│   └── setupGeometry.m
│         ├── setupFlatLens.m
│         └── setupCylindricalLens.m
│
├── InitializeDesign/
│   ├── setupFlatLens.m
│   ├── setupCylindricalLens.m
│   ├── IncidentEpatchArray.m
│   ├── Exx_Calc.m
│   ├── QXX.m
│   └── self_term_H02_rect.m
│
├── Solver/
│   ├── Solver.m
│   ├── ForwardBackwardSolver.m
│   ├── MappingFunction.m
│   ├── CostPlot.m
│   ├── GradientPlot.m
│   └── SaveData.m
│
├── PostProcessing/
│   ├── PostProcessing.m
│   ├── HFSSautomationFlatLens.m
│   ├── Define_New_Design_Variable.m
│   ├── Creat_Permittivity_Box.m
│   ├── HFSSautomationCylindricalLens.m
│   └── Creat_Permittivity_Sector.m
│
├── Analysis/
│   ├── analyzeDesign.m
│   ├── plotFieldsFlatLens.m
│   ├── plotDirectivityExpanding.m
│   ├── plotDirectivityCompressing.m
│   ├── plotSpectrumFlatLens.m
│   ├── plotPermittivityProfileFlatLens.m
│   ├── plotSpatialTransferMatrix.m
│   ├── plotPermittivityProfileCylindricalLens.m
│   ├── plotFieldsCylindricalLens.m
│   └── calcIPR.m
│
└── SaveResults/
```

## Parameter reference

<details>
<summary>Full <code>params</code> / <code>design</code> struct hierarchy (click to expand)</summary>

```
params
├── lambda0, f0, freq_range, caseID, folderPath, mainFilename
├── physics       (mu0, ep0, eta0, c)
├── units         (GHz, cm, mm)
├── lens          (width, thickness, shape, Wout, dxS, drS, dyS, dphiS,
│                  NSX, NSr/NSh, NSY, NStheta/NSt, NS, xS_values, rS_values,
│                  yS_values, phiS_values, xv_Out, xv_In1, xv_In2,
│                  macrocell_t, macrocell_h, Base_P, nLayers, Base_d,
│                  Teeth_n, NBase_P, beta1, beta2, beta3, p0,
│                  bx, br, by, bphi, PhiMax)
├── solver        (dl, maxIter, stepSize, useGPU, Apply_IterBatching,
│                  IterBatchSize, BinarizationIter, iter)
├── material      (tanDelta, epsMin, epsMax)
├── array         (de, Win, Ne, xj, yj, patch_a, patch_b, patch_er,
│                  patch_h, phi_i)
├── geometry      (Fo, dlp, NpX, NpY, xP_values, yP_values, nA, xsA, ysA,
│                  NYvec, Y_vec, xF, yF)
├── Config        (function, nF, nG, phi_s, phi_t, Nphi, dphi, Phi,
│                  range, bb0, nP)
├── analyzer      (Gradient_Display_Flag, Gradient_Iter_Save_Flag,
│                  Cost_per_Iter_Save_Flag, LegendTitles,
│                  Spatial_Transfer_Matrix_Flag, Directivity_Display_Flag,
│                  Permittivity_Display_Flag, Field_Display_Flag,
│                  Display_Spectrum, FontSize, PlotWidth)
└── postprocessing (box_x, Quantization_Levels_Vec)

design
├── Dir_goal, Dir_inc, omega_vec, k_vec
├── EiF, Gvv, Gff, Gv_F, Gv_In, Gv_Out1, Gv_Out2
├── Gl_ai, Gao_l, Gao_ai
├── EffFi, E_Aperturei_F, E_Aperturei_F_Out1, E_Aperturei_F_Out2
├── JF, JA, EiA, X, p
├── Dir_mag, Delta_U_hat
├── cost, Eff, eps_r_vec
└── new_gg, new_bb
```

</details>

## License

All rights reserved.
