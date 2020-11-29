
# Loop-at-a-Time D/K Iterations
The main file to start with is loopatatimeDKItfiltered.m.  This repository implements all of Chapter 6 of my PhD dissertation.  Several sub-functions will be detailed.  


# loopatatimeDKItfiltered.m

Lines 13--79 create a generalized plant state space representation of a fixed-free Euler-Bernoulli beam finite element model.  Within these lines of code, I invoke other custom functions that I wrote: 

# bernoullibeamFEMfuncboundarydef.m
This is a function that I wrote that takes several inputs in creating a coupled set of nonhomogeneous second-order differential equations which represent a dynamical model of an Euler-Bernoulli beam.  The user is able to define/change all material parameters, the geometry, the number of elements included (which affects the bandwidth of the resulting model), along with desired boundary conditions.  In this manner, a free-free, fixed-free, or fixed-fixed configuration is possible. Think of this as my own ANSYS model, which assembles a beam model that is derived using finite element theory and the direct stiffness approach.  Details behind the theory are included in Appendix B of my dissertation. 

# addDAMPING.m
This function adds modal damping to the second-order coupled (undamped) Euler-Bernoulli beam that was created.  I use a neat transformation that allows me to generate a positive definite damping matrix in physical coordinates.

# generalizedplant.m
This function transforms the second-order, nonhomogenous, damped equations of motion into state-variable form -- and specifically, a generalized plant representation.  Let us now return to the main invoking function, loopatatimeDKItfiltered.m.

# loopatatimeDKItfiltered.m
Lines 80--144 are essentially coincident with those detailed above.  In this part of my research, I created two slightly different systems that are to be joined with some dynamics that are uncertain.  In this repository, I treat the uncertainty as being parametric and norm-bounded.  All of this code exists as a step in my research, as I generate initial solutions for a later stochastic optimization problem that I pose and solve, where I color the interconnection element uncertainty with probability distributions.

Lines 145 -- 166 are where I define an uncertain interconnection stiffness element, where I also 

