function [E,Y] = filt_adapt_VR(D,mu,L)
% Copyright (C) 2020 Corey Cruttenden, University of Minnesota 
% 
% This Software is released under GNU General Public License 3.0
% https://www.gnu.org/licenses/gpl-3.0.en.html
%
% This program is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this program.  If not, see <https://www.gnu.org/licenses/>. 
% 
% filt_adapt_VR  Adaptive virtual referencing. 
%   [E,Y] = filt_adapt_VR(D,mu,L) performs offline adaptive virtual
%   referencing on the data matrix D using step-size mu and tap length L.
%   It is assumed that the data matrix D is [NxK] with N samples from K
%   channels, and that there are more samples than channels (N>=K)
%
%   Outputs:
%   E = residual (filtered signal) = D - Y
%   Y = noise signal estimate 
%
%   Inputs: 
%   D   = multi-channel data matrix 
%   mu  = step size for coefficient update
%   L   = tap length - number of adaptive coefficients per channel
%
%   Author:       Corey Cruttenden (University of Minnesota)
%   Contact:      crutt001@umn.edu, corey.cruttenden@gmail.com
%   Last update:  2020/07/16


% D is [NxK] matrix with N samples from K channels
[N,K] = size(D); 

% Assume that there are more samples than channels (thin matrix)
if K > N                % if D is fat
    D = D.';            % transpose D to make it thin
    [N,K] = size(D);    % update N and K
end 

VR = mean(D,2);         % compute virtual reference from D

% initialize variables
x = zeros(L,1);         % reference signal [Lx1]
E = zeros(N,K);         % residual E [NxK]
Y = E;                  % noise estimate Y [NxK]
W = zeros(L,K);         % adaptive filter coefficients [LxK]

% loop through samples 
for countN = 1:N 
    
    % update reference signal to contain last L samples of VR
    if countN < L
        x(1:countN) = VR(countN:-1:1);
    else
        x(:) = VR(countN:-1:countN-L+1);
    end
    
    Y(countN,:) = (W.'*x).'; % filter to generate noise estimate Y
    
    E(countN,:) = D(countN,:) - Y(countN,:); % compute residual E
    
    %W = W + mu*E(countN,:).*x;     
    W = W + mu*x*E(countN,:);       % update coefficients 
    
end

% EOF