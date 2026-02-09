# L-TMCMC for 1D Magnetotelluric Inversion

**[Summary](#summary) | [Authors](#authors) | [Repository Structure](#repository-structure) | [Features](#features) | [Usage](#usage) | [Method Overview](#method-overview) | [Applications](#applications) | [Example](#example-1d-mt-inversion-result)**

## Summary

**Plain language summary:**

Geophysical inversion aims to reconstruct subsurface physical properties from indirect surface measurements, but the problem is typically ill-posed and computationally expensive. Bayesian inference methods such as Markov Chain Monte Carlo (MCMC) are widely used because they provide rigorous uncertainty quantification. However, conventional MCMC methods often suffer from slow convergence and high computational cost, especially for nonlinear geophysical inverse problems.

This repository provides a MATLAB implementation of **Langevin Transitional Markov Chain Monte Carlo (L-TMCMC)** for solving **1D magnetotelluric (MT) inversion** problems. The method enhances the original Transitional MCMC framework by incorporating gradient-based Langevin proposals, enabling efficient posterior exploration while preserving robust uncertainty quantification. The framework supports joint inversion of layer resistivities and thicknesses using apparent resistivity and phase data, and is applicable to both synthetic benchmarks and field MT datasets.

---
## Authors

**Ziang Zhang**  
Department of Electrical and Computer Engineering, University of Houston  
📧 Email: zzhang88@cougarnet.uh.edu  
(Primary contact for questions and issues)

**Xiaolong Wei**  
Department of Earth, Ocean and Atmospheric Sciences, University of British Columbia  

**Jiajia Sun**  
Department of Earth and Atmospheric Sciences, University of Houston  

**Yueqin Huang**  
Department of Information Science Technology, Cullen College of Engineering, University of Houston  

**Xuqing Wu**  
Department of Information Science Technology, Cullen College of Engineering, University of Houston  

**Jiefu Chen**  
Department of Electrical and Computer Engineering, University of Houston  


---
## Repository Structure
```
├── inverse_flex.m % Main script for L-TMCMC-based MT inversion
├── ltmcmc_par.m % L-TMCMC algorithm implementation
├── MTmodeling1D.m % 1D magnetotelluric forward modeling
├── generateSynData.m % Synthetic MT data generation
├── draw_Stair.m % Visualization of layered resistivity models
├── README.md
└── LICENSE
```

## Features

This package has the following features:

- Bayesian inversion of 1D layered magnetotelluric models
- Joint estimation of layer resistivities and thicknesses
- Langevin gradient-based proposals for improved sampling efficiency
- Transitional MCMC framework for stable posterior exploration
- Full posterior uncertainty quantification
- Validation on synthetic benchmark functions
- Applications to synthetic and field MT data

---

## Usage

To run the package locally, ensure that MATLAB is installed and properly configured.

Simply execute the main inversion script in MATLAB:

```matlab
>> inverse_flex

```
The script performs forward MT response calculation, likelihood evaluation based on apparent resistivity and phase data, and L-TMCMC sampling across multiple transitional stages. Prior ranges, inversion parameters, and model settings can be modified directly within the script.

---

## Method Overview

Geophysical inversion is a critical technique for reconstructing subsurface physical properties from indirect measurements, with wide applications in natural resource exploration, including mineral exploration and hydrocarbon prospecting. Markov Chain Monte Carlo (MCMC) sampling is a popular Bayesian inference method for geophysical inversion due to its ability to provide rigorous uncertainty quantification. However, traditional MCMC methods often suffer from slow convergence and high computational cost.

To address these limitations, this work proposes the Langevin Transitional Markov Chain Monte Carlo (L-TMCMC) method, which integrates gradient-based Langevin proposals into the Transitional MCMC framework. By incorporating local gradient information of the log-posterior distribution, the method significantly enhances sampling efficiency while maintaining robust uncertainty quantification.

In this study, L-TMCMC is first validated using synthetic benchmark functions, including the Rosenbrock and Beale functions, both of which exhibit complex parameter landscapes with multiple local minima. Comparisons with standard TMCMC demonstrate that L-TMCMC achieves faster convergence and improved parameter estimation accuracy.

---

## Applications

The L-TMCMC framework is applied to both synthetic and field magnetotelluric datasets:

Synthetic benchmark functions
L-TMCMC is tested on Rosenbrock and Beale functions to evaluate its performance in complex nonlinear parameter spaces. Results show superior convergence behavior compared to standard TMCMC.

Synthetic MT inversion
The method is applied to synthetic magnetotelluric data generated from multi-layer subsurface models. L-TMCMC successfully recovers major resistivity transitions, producing posterior estimates that align well with the true geological structures.

Field MT inversion
A field application is conducted using magnetotelluric data collected over the offshore region of the Cocos Plate near Nicaragua. The estimated subducting plate boundary is consistent with previous studies, and the method provides reliable uncertainty quantification in the form of posterior confidence intervals for the inverted parameters.

Overall, the proposed L-TMCMC framework balances computational efficiency with rigorous uncertainty assessment, making it well suited for challenging geophysical inverse problems.

---

## Example: 1D MT Inversion Result

<p align="center">
  <img src="example/result.png" alt="L-TMCMC 1D MT inversion result with uncertainty" width="520">
</p>

**Figure:** Posterior inversion result for a 1D magnetotelluric model using L-TMCMC.  
The blue solid line denotes the true resistivity model, the green dashed line represents the posterior mean, and the shaded area indicates the 5%–95% posterior uncertainty interval. The result demonstrates that L-TMCMC accurately recovers major resistivity contrasts while providing reliable uncertainty quantification for both resistivity and layer thickness.

The scripts and data used to generate this figure are provided in the `examples/` directory.
