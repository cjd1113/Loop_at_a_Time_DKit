
%% Loop-at-a-Time DK Iteration 

%Summary: This is a script for loop-at-a-time D-K iteration.
%For this script we are dealing with the following situation:
%1. Frequency weighting of performance output - this is significant
%2. We are including D12 and D21 terms.  Lim1996 did not do this.  In
%recent experience, this resulted in high-dimensional controllers

%Prepared by: Christopher D'Angelo
%Date: July 19, 2018

%% CREATE BEAM #1

%%YOUNG'S MODULUS DEF'N %%
E = 200E9; %Young's modulus, Pa

%%REMAINING PARAMETER DEFINITIONS
rho = 7.800; %mass density
b = 5; %width, cm
h = .5; %height, cm
TotalLength = 100; %Beam length, cm
Ne = 10; %Number of finite elements

CtrlLoc = [10]; %Control input location, cm
DistLoc = 40; %Dist input location, cm
MeasLoc = [20]; %Meas input location, cm

Nc = round(Ne*(CtrlLoc./TotalLength),0);
Nd = round(Ne*(DistLoc./TotalLength),0);
Meas = round(Ne*(MeasLoc./TotalLength),0);

constraintloc = 1; %constrain beginning of beam, meaning the final two states will be used for coupling

disp('Creating beam generalized model #1...')
pause(0.4)
disp('...')
pause(0.4)
disp('...')

%Generate the beam model
[Mcc,Kcc,KE,ME,Le,PD,PC,Mm] = bernoullibeamFEMfuncboundarydef(E,rho,b,h,Ne,TotalLength,Nc,Nd,Meas,constraintloc);

%Add damping
zeta_r = 0.02; %2 percent damping in each mode
[Ccc,V,D] = addDAMPING(Mcc,Kcc,zeta_r);

%Generate the generalized plant in physical coordinates
[A1, Bw_1, Bu_1, Cz_1, Cy_1, D111, D121, D211] = generalizedplant(Mcc,Ccc,Kcc,PD,PC,...
Mm,V,D,'nofilter','physical');

%Now, we must define or identify, rather, the input and output influence
%matrices that will couple through the interconnection stiffness

Bptemp1 = [zeros(size(A1,1)/2-2,2);eye(2)]; %
Bp_1 = [zeros(size(A1,1)/2,2);Mcc\Bptemp1];
% Cq_1 = [zeros(2,size(A1,1)-2), eye(2)];
Cq_1 = [zeros(2,size(A1,1)/2-2), eye(2), zeros(2,size(A1,2)/2)];

beammodel_1 = struct('A',A1,'B1',Bw_1,'B2',Bu_1,'B3',Bp_1,...
    'C1',Cz_1,'C2',Cy_1,'C3',Cq_1,'D11',D111,'D12',D121,'D21',D211);

%%COMPOSITE SYSTEM REPRESENTATION

%SYSTEM 1
%[A1 | Bw_1 Bu_1 Bp_1;...
%Cz_1|  0  D121  0;...
%Cy_1| D211  0    0;...
%Cq_1|  0    0    0]

pause(0.4)

disp('System 1 has been created:')
disp('[A1 | Bw_1 Bu_1 Bp_1;')
disp('--------------------')
disp('Cz_1|  0  D121  0;')
disp('Cy_1| D211  0    0;')
disp('Cq_1|  0    0    0]')

%% CREATE BEAM #2

%%YOUNG'S MODULUS DEF'N %%
E = 200E9; %Young's modulus, Pa

%%REMAINING PARAMETER DEFINITIONS
rho = 7.800; %mass density
b = 5; %width, cm
h = .5; %height, cm
TotalLength = 150; %Beam length, cm
Ne = 15; %Number of finite elements

CtrlLoc = 75; %Control input location, cm
DistLoc = 100; %Dist input location, cm
MeasLoc = 50; %Meas input location, cm

Nc = round(Ne*(CtrlLoc./TotalLength),0);
Nd = round(Ne*(DistLoc./TotalLength),0);
Meas = round(Ne*(MeasLoc./TotalLength),0);

constraintloc = 1; %constrain beginning of beam, meaning the final two states will be used for coupling

disp('Creating beam generalized model #2...')
pause(0.4)
disp('...')
pause(0.4)
disp('...')

%Generate the beam model
[Mcc,Kcc,KE,ME,Le,PD,PC,Mm] = bernoullibeamFEMfuncboundarydef(E,rho,b,h,Ne,TotalLength,Nc,Nd,Meas,constraintloc);

%Add damping
zeta_r = 0.02; %2 percent damping in each mode
[Ccc,V,D] = addDAMPING(Mcc,Kcc,zeta_r);

%Generate the generalized plant in physical coordinates
[A2, Bw_2, Bu_2, Cz_2, Cy_2, D112, D122, D212] = generalizedplant(Mcc,Ccc,Kcc,PD,PC,...
Mm,V,D,'nofilter','physical');

%Now, we must define or identify, rather, the input and output influence
%matrices that will couple through the interconnection stiffness

Bptemp2 = [zeros(size(A2,1)/2-2,2);eye(2)]; %
Bp_2 = [zeros(size(A2,1)/2,2);Mcc\Bptemp2];
% Cq_2 = [zeros(2,size(A2,1)-2), eye(2)];
Cq_2 = [zeros(2,size(A2,1)/2-2), eye(2), zeros(2,size(A2,2)/2)];

%SYSTEM 2
%[A2 | Bw_2 Bu_2 Bp_2;...
%Cz_2|  0  D122  0;...
%Cy_2| D212  0    0;...
%Cq_2|  0    0    0]

pause(0.4)

disp('System 2 has been created:')
disp('[A2 | Bw_2 Bu_2 Bp_2;')
disp('--------------------')
disp('Cz_2|  0  D122  0;')
disp('Cy_2| D212  0    0;')
disp('Cq_2|  0    0    0]')

beammodel_2 = struct('A',A2,'B1',Bw_2,'B2',Bu_2,'B3',Bp_2,...
    'C1',Cz_2,'C2',Cy_2,'C3',Cq_2,'D11',D112,'D12',D122,'D21',D212);

%% CREATE THE UNCERTAIN INTERFACE STIFFNESS ELEMENT

%Note that we are now dealing with a range for E, instead of a percentage
%difference (this is as of 7/19/18)

% p_uncert = 10;
E_nom = E;
E_percentup = 2.0; %2.0 == 200 percent of nominal
E_percentdown = 0.01; %0.01 == 1 percent of nominal
E_upper = E*E_percentup;
E_down = E*E_percentdown;
RANGE = [E_down,E_upper];
width = b; height = h; length = 10;

[K11,K12,K21,K22,E_uncert] = UncertainStiffnessRange(width,height,length,E_nom,RANGE);

%Multiply interface stiffness matrix by -1 to get forces to be equal and
%opposite
K11 = -K11; K12 = -K12; K21 = -K21; K22 = -K22;

coupling = struct('K11',K11,'K12',K12,'K21',K21,'K22',K22);

%% LOOP SCENARIOS

%'scenario_0' --- COUPLE OPEN LOOP SYSTEMS FOR OPEN LOOP PERFORMANCE VERIFICATION 
%'scenario_1' --- NO CONTROLLERS, SYNTHESIZE K1
%'scenario_2' --- HAVE K1, SYNTHESIZE K2
%'scenario_3' --- HAVE K2, SYNTHESIZE K1
%'scenario_4' --- HAVE K1, K2, FORMULATE COMPOSITE SYSTEM FOR PERFORMANCE VERIFICATION

%INPUTS TO LOOPFORMULATIONS FUNCTION:
%1: open-loop system 1 structure
%2: open-loop system 2 structure
%3: controller 1 structure
%4: controller 2 structure
%5: coupling structure, which may or may not be uncertain (for DK/mu syn
%must be uncertain)
%6: string identifying which "scenario" we are synthesizing around

%OUTPUT STRUCTURE OF LOOPFORMULATIONS FUNCTION:
%system.A = composite system matrix
%system.B = disturbance input / control input augmented matrix
%system.C = performance / measurement output augmented matrix
%system.D = feedforward matrix
%system.ninputs = number of control inputs
%system.moutputs = number of measurements

%NOTES: The ninputs and moutputs are inputs for dksyn --- the system
%augmented input and output vectors are arranged such that the control /
%measurement inputs / outputs are last.  dksyn "knows" to take these as the
%only inputs / outputs used for control

%In this prototype, we will move through the scenarios in serial,
%terminating after the 2rd scenario -- we assume that we get K1 and K2 in
%this case.

%Set dksyn options - used MixedMU
opt = dksynOptions('MixedMU','on');

%% SCENARIO 1

coupledsystemscen1 = loopformulations(beammodel_1,beammodel_2,[],[],coupling,'scenario_1');

nmeas = coupledsystemscen1.moutputs;
ncont = coupledsystemscen1.ninputs;

%%We now want to filter the performance output matrix by scaling in modal
%%coordinates

Anominal = coupledsystemscen1.A.NominalValue;
[V,D] = eig(Anominal);
order = 1;
wc = 500;
alpha = filterfunctions(D,wc,order);
C1 = coupledsystemscen1.C(1:end-nmeas,:);
C1modal = C1*V;
C1modalweighted = zeros(size(C1modal));
for i = 1:size(C1modal,1)
    C1modalweighted(i,:) = alpha'.*C1modal(i,:);
end
C1physicalweighted = real(C1modalweighted/V); %The imaginary components are negligible - close to machine epsilon

coupledsystemscen1.C = [C1physicalweighted;...
    coupledsystemscen1.C(size(C1physicalweighted,1)+1:end,:)];

%Formulate the plant prior to performing mu synthesis
PLANT = ss(coupledsystemscen1.A,coupledsystemscen1.B,coupledsystemscen1.C,coupledsystemscen1.D);

%return

[K,clp,mu_c,infoc] = dksyn(PLANT,nmeas,ncont,opt);

mu_c

SolutionOutScen1.K = K;
SolutionOutScen1.clp = clp;
SolutionOutScen1.mu_c = mu_c;
SolutionOutScen1.infoc = infoc;
SolutionOutScen1.system = coupledsystemscen1;

%Perform a balanced reduction on the controller order, forcing it to be
%equal to the size of substructure #1

[Akred,Bkred,Ckred,Dkred,~,~] = balancedreduction(K.A,K.B,K.C,K.D,[],size(A1,1));

Akred = real(Akred); Bkred = real(Bkred); Ckred = real(Ckred); Dkred = real(Dkred);

Kred = ss(Akred,Bkred,Ckred,Dkred);

SolutionOutScen1.Kred = Kred;

DKOutput = sprintf('DKOutputScen1.mat');
save(DKOutput,'SolutionOutScen1','-mat','-v7.3')



%% SCENARIO 2

Ak_1 = Akred; Bk_1 = Bkred; Ck_1 = Ckred; Dk_1 = Dkred;

%Create controller structure with reduced controller #1

controller1.Ak = Ak_1; controller1.Bk = Bk_1; 
controller1.Ck = Ck_1; controller1.Dk = Dk_1;

%Create controller structure
% controller1.Ak = K.A; controller1.Bk = K.B; 
% controller1.Ck = K.C; controller1.Dk = K.D;

coupledsystemscen2 = loopformulations(beammodel_1,beammodel_2,controller1,...
    [],coupling,'scenario_2');


nmeas = coupledsystemscen2.moutputs;
ncont = coupledsystemscen2.ninputs;

%%We now want to filter the performance output matrix by scaling in modal
%%coordinates

Anominal = coupledsystemscen2.A.NominalValue;
[V,D] = eig(Anominal);
order = 1;
wc = 500;
alpha = filterfunctions(D,wc,order);
C1 = coupledsystemscen2.C(1:end-nmeas,:);
C1modal = C1*V;
C1modalweighted = zeros(size(C1modal));
for i = 1:size(C1modal,1)
    C1modalweighted(i,:) = alpha'.*C1modal(i,:);
end
C1physicalweighted = real(C1modalweighted/V); %The imaginary components are negligible - close to machine epsilon

coupledsystemscen2.C = [C1physicalweighted;...
    coupledsystemscen2.C(size(C1physicalweighted,1)+1:end,:)];

PLANT = ss(coupledsystemscen2.A,coupledsystemscen2.B,coupledsystemscen2.C,coupledsystemscen2.D);

[K,clp,mu_c,infoc] = dksyn(PLANT,nmeas,ncont,opt);

mu_c

SolutionOutScen2.K = K;
SolutionOutScen2.clp = clp;
SolutionOutScen2.mu_c = mu_c;
SolutionOutScen2.infoc = infoc;
SolutionOutScen2.system = coupledsystemscen2;

%Perform a balanced reduction on the controller order, forcing it to be
%equal to the size of substructure #2

[Akred,Bkred,Ckred,Dkred,~,~] = balancedreduction(K.A,K.B,K.C,K.D,[],size(A2,1));

Akred = real(Akred); Bkred = real(Bkred); Ckred = real(Ckred); Dkred = real(Dkred);

Kred = ss(Akred,Bkred,Ckred,Dkred);

SolutionOutScen2.Kred = Kred;


DKOutput = sprintf('DKOutputScen2.mat');
save(DKOutput,'SolutionOutScen2','-mat','-v7.3')








