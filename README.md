# L-TMCMC for 1D Magnetotelluric Inversion

This repository provides a MATLAB implementation of Langevin Transitional Markov Chain Monte Carlo (L-TMCMC) for solving 1D Magnetotelluric (MT) inversion problems. The algorithm enhances the original TMCMC method by introducing gradient-based Langevin proposals to improve sampling efficiency and convergence.

The code supports full posterior sampling of layer resistivities and thicknesses based on apparent resistivity and phase data.

Simply run the main script in MATLAB:
```matlab
>> inverse_flex
