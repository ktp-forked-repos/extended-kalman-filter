%EKF_UPDATE1  1st order Extended Kalman Filter update step
%
% Syntax:
%   [M,P,K,MU,S,LH] = EKF_UPDATE1(M,P,Y,H,R,[h,V,param])
%
% In:
%   M  - Nx1 mean state estimate after prediction step
%   P  - NxN state covariance after prediction step
%   Y  - Dx1 measurement vector.
%   H  - Derivative of h() with respect to state as matrix,
%        inline function, function handle or name
%        of function in form H(x,param)
%   R  - Measurement noise covariance.
%   h  - Mean prediction (innovation) as vector,
%        inline function, function handle or name
%        of function in form h(x,param).               (optional, default H(x)*X)
%   V  - Derivative of h() with respect to noise as matrix,
%        inline function, function handle or name
%        of function in form V(x,param).               (optional, default identity)
%   param - Parameters of h                            (optional, default empty)
%
% Out:
%   M  - Updated state mean
%   P  - Updated state covariance
%   K  - Computed Kalman gain
%   MU - Predictive mean of Y
%   S  - Predictive covariance of Y
%   LH - Predictive probability (likelihood) of measurement.
%   
% Description:
%   Extended Kalman Filter measurement update step.
%   EKF model is
%
%     y[k] = h(x[k],r),   r ~ N(0,R)
%
% See also:
%   EKF_PREDICT1, EKF_PREDICT2, EKF_UPDATE2, DER_CHECK,
%   LTI_DISC, KF_UPDATE, KF_PREDICT

% Copyright (C) 2002-2006 Simo S�rkk�
%
% $Id: ekf_update1.m 137 2008-02-20 11:46:08Z jmjharti $
%
% This software is distributed under the GNU General Public 
% Licence (version 2 or later); please refer to the file 
% Licence.txt, included with the software, for details.

function [M,P,K,MU,S,LH] = ekf_updateparam1(X,M,P,y,H,C,R,h,V,param)


  %
  % Check which arguments are there
  %
  if nargin < 7
    error('Too few arguments');
  end
  if nargin < 8
    h = [];
  end
  if nargin < 9
    V = [];
  end
  if nargin < 10
    param = [];
  end

  %
  % Apply defaults
  %
  if isempty(V)
    V = eye(size(R,1));
  end

  %
  % Evaluate matrices
  %
  if isnumeric(H)
    % nop
  elseif isstr(H) | strcmp(class(H),'function_handle')
    H = feval(H,X,param);
  else
    H = H(X,param);
  end

  if isnumeric(C)
    % nop
  elseif isstr(C) | strcmp(class(C),'function_handle')
    C = feval(C,X,param);
  else
    C = C(X,param);
  end
  
  
  if isempty(h)
    MU = H*M;
  elseif isnumeric(h)
    MU = h;
  elseif isstr(h) | strcmp(class(h),'function_handle')
    MU = feval(h,X,param);
  else
    MU = h(X,param);
  end

  if isnumeric(V)
    % nop
  elseif isstr(V) | strcmp(class(V),'function_handle')
    V = feval(V,M,param);
  else
    V = V(M,param);
  end

  
  %
  % update step
  %  
  
  S = (V*R*V' + C*P*C');
  
  K = P*C'/S;
  M = M + K * (y-MU);
  P = P - K*S*K';

  if nargout > 5
    LH = gauss_pdf(y,MU,S);
  end
