
%This function generates the uncertain interconnection stiffness matrix for
%an Euler Bernoulli beam element, where we have restricted this uncertain
%object to be +/- p_uncert% around the nominal value, E_nom

%Prepared by: Chris D'Angelo
%Date: May 21, 2018

function [K11,K12,K21,K22,E_uncert] = UncertainStiffnessRange(width,height,length,E_nom,RANGE)


E = ureal('Euncert',E_nom,'Range',RANGE);
L = length;
I = 1/12*width*height^3;

Ke = (E*I)/(L^3) * [12 6*L -12 6*L;...
    6*L 4*L^2 -6*L 2*L^2;...
    -12 -6*L 12 -6*L;...
    6*L 2*L^2 -6*L 4*L^2];

%Partition the stiffness element so that we have the block diagonal and
%cross terms for coupling interface forces / moments and displacements /
%rotations

%Note: the partitioning of this matrix into K11, K12, K21, and K22
%preserves these as uncertain matrices.

K11 = Ke(1:2,1:2);
K12 = Ke(1:2,3:4);
K21 = Ke(3:4,1:2);
K22 = Ke(3:4,3:4);

%Also return the "raw" uncertainty term

E_uncert = E;

end