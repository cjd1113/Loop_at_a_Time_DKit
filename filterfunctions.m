

function [alpha] = filterfunctions(D,wc,order)

%%We will perform filter design, here

% Dmodal = zeros(size(C1modal,1),size(B1modal,2));

%What we want to do now is extract the magnitude of the filter function at
%the structure's natural frequencies, so that we can filter our disturbance
%input by scaling the B1 matrix in modal coordinates without increasing the
%dimension of the system

%%

naturalfreqvec = abs(diag(D));

n = length(naturalfreqvec);

s = 1j.*naturalfreqvec;
alpha = zeros(size(s));
for i = 1:n
    FilterFunc = (wc^order)/(s(i)+wc)^order;
    alpha(i) = abs(FilterFunc);
end

%The alpha vector obtained here will be used for scaling the disturbance
%input matrix at the respective modes

end

