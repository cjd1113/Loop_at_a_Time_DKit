
function [Ared,Bred,Cred,Dred,Wcbardiag,epsilon] = balancedreduction(A,B,C,D,lb,states)


Wc = lyap(A,B*B'); %calculation of the controllability gramian
Wo = lyap(A',C'*C); %calculation of the observability gramian

Wco = Wc*Wo;
[T,~] = eig(Wco); %find the eigenvectors of the product of the observability/controllability gramians which will represent our state transformation for balanced reduction

%A state transformation is defined s.t. x(t) = Tx_b(t) where x_b(t)
%represents our "balanced" coordinates

Atilde = T\A*T; %Transformed A matrix
Btilde = T\B; %Transformed B matrix
Ctilde = C*T; %Transformed C matrix

Wcbar = lyap(Atilde,Btilde*Btilde');

Wcbardiag = diag(Wcbar); %singular values of the transformed system

lowerbound = lb; %This is the lower-bounding SV that we are going to truncate

if isempty(states)

    for i = 1:length(Wcbardiag)
        if Wcbardiag(i)<=lowerbound
            ind = i;
            if mod(ind+1,2)==0
                ind = ind+1;
            end
            break
        end
        if i == length(Wcbardiag)
            ind = i;
        end
    end

else
    
    ind = states;
    
end

Ared = Atilde(1:ind,1:ind); %Reduced, or truncated, balanced system
Bred = Btilde(1:ind,:);
Cred = Ctilde(:,1:ind);
Dred = D;

fullsys = ss(A,B,C,D); %Generate the full system
sysred = ss(Ared,Bred,Cred,Dred); %Generate the reduced system


%Calculate the infinity norm of the difference between the two systems
epsilon = norm(fullsys-sysred,Inf);

%Calculate the upper bound by summing the singular values that were part of
%the "truncated" space
% upperbound = 2*sum(Wcbardiag(ind+1:end));

end
