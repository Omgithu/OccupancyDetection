%Kalman Filter Design Preliminary
%Author: Hasnain Cheena

%load test data
tlvStream = load('C:\Users\hasna\Documents\GitHub\OccupancyDetection\Data\Matlab Data\slowWalk.mat');
tlvStream = tlvStream.tlvStream; %get the tlv data from the actual struct object

%tlv parsing 


delT = 0.05;
%A matrix, is the system matrix 
A = [1 delT 0 0;
    0 1 0 0;
    0 0 1 delT;
    0 0 0 1];

%no B matrix as no input (u)
B = zeros(4,1);

%C/H matrix state variables we can measure 
H = [1 0 0 0; 
    0 0 1 0];

%no D matrix (no transmission matrix)
D = 0;

%observability check 
obCheck = obsv(A,H);
unob = length(A)-rank(obCheck);

Q = eye(4); %gaussian acceleration noise
R = eye(2,1); % R is a 2 by 1 as we measure both range and azimuth (they both have error)

%note that F = e^A*(det)
%F is the state transition matrix
F = expm(A*delT);

x = [ 0 ; 10];
P = [ 10 0; 0 10 ];

z = [2.5 1 4 2.5 5.5];
for i=1:5
[xpred, Ppred] = predict(x, P, F, Q);
[nu, S] = innovation(xpred, Ppred, z(i), H, R);
[x, P] = innovation_update(xpred, Ppred, nu, S, H);
end


function [xpred, Ppred] = predict(x, P, F, Q)
xpred = F*x;
Ppred = F*P*F' + Q;
end

function [nu, S] = innovation(xpred, Ppred, z, H, R)
nu = z - H*xpred; %% innovation
S = R + H*Ppred*H'; %% innovation covariance
end

function [xnew, Pnew] = innovation_update(xpred, Ppred, nu, S, H)
K = Ppred*H'*inv(S); %% Kalman gain
xnew = xpred + K*nu; %% new state
Pnew = Ppred - K*S*K'; %% new covariance
end

function TLV