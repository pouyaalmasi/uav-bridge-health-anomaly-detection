# Automated Bridge Deck Health Evaluation using UAV Imaging and Sparse Autoencoders

A lightweight, unsupervised anomaly detection framework for automated bridge deck condition assessment using UAV-acquired imagery and sparse autoencoder-based anomaly mapping aligned with National Bridge Inventory (NBI) rating concepts.

This repository contains:
- MATLAB implementation of the sparse autoencoder framework
- Training script
- Prediction/inference script
- UAV-based bridge deck anomaly heatmap generation
- Bridge-level anomaly summary report

> This repository accompanies a study accepted for publication in the Transportation Research Record (TRR) Journal. Since the paper is accepted but not yet published, selected implementation details, calibration procedures, and datasets are intentionally simplified or not fully disclosed.

---

# Overview

This repository presents an unsupervised anomaly detection framework for bridge deck health evaluation using UAV imagery and sparse autoencoders.

The framework learns normal concrete surface patterns from healthy image patches. During prediction, image patches with higher reconstruction error are treated as potential anomalies.

Potential anomaly types include:
- Cracks
- Surface deterioration
- Staining
- Texture irregularities
- Localized material degradation

The framework generates anomaly heatmaps and summarizes patch-level reconstruction errors into bridge-level indicators.

---

# Key Features

## Unsupervised Learning
- No pixel-level defect labels required
- Sparse autoencoder trained on healthy concrete patches
- Reconstruction-error-based anomaly detection

## UAV-Based Bridge Inspection
- Supports UAV-acquired bridge deck imagery
- Processes high-resolution images using 64 × 64 patches
- Generates heatmap overlays for visual interpretation

## Anomaly Quantification
The framework computes:
- Average reconstruction error
- Anomalous area percentage
- Severity score
- Bridge-level condition summary

---

# Repository Structure

```text
├── code/
│   ├── train_autoencoder.m
│   └── prediction_inference.m
│
├── sample_images/
│   ├── 01.png
│   ├── 02.png
│   └── ...
│
├── sample_results/
│   ├── heatmap_01.png
│   ├── heatmap_02.png
│   └── ...
│
├── model/
│   └── autoencoder_model.mat
│
├── LICENSE
└── README.md
```

---

# Requirements

## Software
- MATLAB R2025a  
  Earlier R202x releases may also work if the required toolboxes are available.

## Required MATLAB Toolboxes
- Deep Learning Toolbox
- Image Processing Toolbox
- Computer Vision Toolbox
- Parallel Computing Toolbox recommended for faster processing

---

# Dataset

The full UAV bridge inspection dataset used in the study is not publicly distributed at this time.

A small number of sample images may be included for demonstration purposes.

Expected image format:
- UAV-acquired RGB bridge deck images
- `.jpg` or `.png`
- Concrete bridge deck regions preferred

---

# Training

The training script is:

```text
code/train_autoencoder.m
```

It trains a sparse autoencoder using healthy concrete image patches.

Run from MATLAB:

```matlab
cd code
train_autoencoder
```

---

# Prediction / Inference

The prediction script is:

```text
code/prediction_inference.m
```

Before running, place input images in:

```text
sample_images/
```

and place the trained model in:

```text
model/autoencoder_model.mat
```

Then run:

```matlab
cd code
prediction_inference
```

Outputs are saved in:

```text
sample_results/
```

Generated outputs include:
- Heatmap overlay images
- Bridge-level anomaly report in the MATLAB Command Window
- Average reconstruction error
- Anomalous area percentage
- Severity score
- Estimated condition category

---

# Methodology Summary

The framework follows these main steps:

1. Load UAV-acquired bridge deck images
2. Convert images to grayscale
3. Divide each image into 64 × 64 patches
4. Normalize and flatten each patch
5. Reconstruct each patch using the trained sparse autoencoder
6. Compute reconstruction error for each patch
7. Generate image-level anomaly heatmaps
8. Aggregate patch-level errors into bridge-level metrics

---

# Important Notes

This repository intentionally does not include:
- Full UAV dataset
- Full calibration dataset
- Complete threshold sensitivity workflow
- Full publication-level implementation details

This is to avoid fully disclosing unpublished research contributions before journal publication.

The included implementation is intended for:
- Research demonstration
- Educational use
- Reproducibility support
- Preliminary UAV-based anomaly visualization

---

# Related Paper

**Automated Bridge Deck Health Evaluation Aligned with NBI Ratings via UAV Imaging and Label-Free Sparse Autoencoder-Based Anomaly Mapping**

Accepted for publication in:

**Transportation Research Record (TRR) Journal**

---

# Citation

```bibtex
@article{almasi2026autoencoder,
  title={Automated Bridge Deck Health Evaluation Aligned with NBI Ratings via UAV Imaging and Label-Free Sparse Autoencoder-Based Anomaly Mapping},
  author={Almasi, Pouya and Premadasa, Roshira and Jauregui, David and Zhang, Qianyun},
  journal={Transportation Research Record},
  note={Accepted for publication},
  year={2026}
}
```

---

# Author

Pouya Almasi  
Ph.D. Candidate in Civil Engineering  
New Mexico State University

Research Areas:
- Structural Health Monitoring
- UAV-based Infrastructure Inspection
- Unsupervised Learning
- Sparse Autoencoders
- Bridge Condition Assessment
- Computer Vision

---

# License

This project is licensed under the MIT License.

---

# Acknowledgment

The research reported in this work was conducted under a long-term project sponsored by the New Mexico Department of Transportation (NMDOT) Research Bureau. Q. Zhang acknowledges the startup fund from the College of Engineering at New Mexico State University.
