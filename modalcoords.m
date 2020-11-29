
function [Mm,Cm,Km,Pwm,Pum,Am,B1m,B2m,C1m,C2m] = modalcoords(Mcc,Ccc,Kcc,PD,PC,Mmeas,V,D)


%%This function casts the system into modal coordinates.  Out state
%%variables are x = [Omega*q_m; \dot{q}_m], meaning we are casting the
%%system into the modal coordinates 1 from Gawronski's Advanced Structural
%%Dynamics and Active Control of Structures book


Mm = V'*Mcc*V;
Cm = V'*Ccc*V;
Km = V'*Kcc*V;
Pwm = V'*PD;
Pum = V'*PC;

Omega = sqrt(D);

Am = [zeros(size(Mm,1)) Omega;...
    -Omega -(Mm\Cm)*inv(Omega)];

B1m = [zeros(size(Mm,1),size(Pwm,2));... %disturbance input
    Mm\Pwm];
B2m = [zeros(size(Mm,1),size(Pum,2));... %control input
    Mm\Pum];

%We assume that we are able to measure the transverse position and velocity
%at the measurement locations.  Furthermore, our performance output will be
%with respect to these measurement locations.
C1m = [(Mmeas*V)*inv(Omega) zeros(size(Mmeas,1),size(Mmeas,2));...
    zeros(size(Mmeas,1),size(Mmeas,2)), Mmeas*V];
C2m = C1m;


end
