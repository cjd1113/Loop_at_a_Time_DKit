
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

Observe that the generalized plant models (on lines 60 and 142) are packed into Matlab data structures, which makes moving these objects around cleaner, as they end up being fed to downstream functions.

Lines 145 -- 166 are where I define an uncertain interconnection stiffness element.  This uncertain stiffness element will exist as a subsystem and is used to join the two beam models that were created previously.

# UncertainStiffnessRange
This is the function that I wrote that parameterizes the Young's modulus of the stiffness element as existing within some interval range (real, parametric, norm-bounded uncertainty).  On line 165, I create a Matlab data structure which makes carrying these parameters around cleaner.  

Now we can bring your attention to lines 167 to 231.  This is where generalized plants are again formed by connecting the two beam models through the uncertain stiffness element.  Control design is also performed.  Scenarios 1 and 2 are carried out, here.  We will detail the loop formulations, as I wrote a function for flexibly handling this task, given that I was dealing with high-dimensional system models that possess a fair bit of meaning/complexity.  Let us now detail the loopformulations.m function, which is first called on line 206.

# loopformulations.m
The output of this function is a structure, which is a new, uncertain generalied plant model.  This generalized plant model is our "design model", as it is passed to another function for performing controller synthesis.  Two systems, two controllers (if provided), the uncertain coupling subsystem, and the loop formulation scenario are provided as inputs.  Note that most of these inputs are provided as Matlab structures.  Hence, you will see them get unpacked at the header of this function.  Depending upon the scenario that is called, a new generalized plant is formed.  These scenarios are detailed in chapter 6 of my dissertation.

We now return to the main invoking script, loopatatimeDKItfiltered.m.  

Controller synthesis, which is performed using mu synthesis via D/K iterations, is called on line 235.  Note that one decentralized controller (if it exists) will be synthesized at this step.  Then, we move into Scenario 2, which attempts to close the loop around an already-closed loop.  This is why this is called "loop at a time" synthesis.  The process is repeated, and if successful, we end up with two decentralized robust controllers.  By repeated, I mean that we are moving into a new loop formulation scenario followed by mu synthesis via D/K iterations for controller synthesis.  The dksyn command is one that is internal to Matlab, and is a part of the robust control toolbox.  I could have written my own code to accomplish this, but that would not have been efficient: I have detailed all of the relevant theory in my dissertation, though, and how I end up exploiting the conservatism and sub-optimality of this powerful, elegent control synthesis approach in order to advance the state of the art in synthesis of decentralized, probabilistic robust dynamic output feedback controllers.  

At certain points, the data that results from this process are saved.  Note that this process and the resulting controllers are used as inputs to another optimization problem that I end up solving.  That other optimization problem will be detailed in another repository.  


