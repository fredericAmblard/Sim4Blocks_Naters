% function [XSS, Qdem] = steady_state_sys_build(Tin_sp, Text, Ab_c, Bb_c)
% %STEADY_STATE_SYS_BUILD Computes the steady state of a building 
% 
% A_mat = zeros(4,4);
% B_mat = zeros(4,1);
% 
% A_mat(:,1:3) = Ab_c(:,1:3);
% A_mat(:,4) = Bb_c(:,2);
% B_mat(:) = - Ab_c(:,4) * Tin_sp - Bb_c(:,1) * Text;
% 
% SS = A_mat\B_mat;
% XSS = [SS(1:3,1); Tin_sp];
% %USS = [Text; SS(4,1); 0];
% Qdem= SS(4);
% end

function steady_state_sys_build(block)
% Level-2 MATLAB file S-Function to compute the steady state of a building
%   Copyright 1990-2011 The MathWorks, Inc.

  setup(block);
  
%endfunction

function setup(block)
  
  %% Register dialog parameter: LMS step size 
  block.NumDialogPrms = 1;
  block.DialogPrmsTunable = {'Tunable'};
  % block.DialogPrm(1).Name = 'StepSize';
  % block.DialogPrm(1).DataTypeId = 0;
  
  %% Regieste number of input and output ports
  block.NumInputPorts  = 4;
  block.NumOutputPorts = 2;

  %% Setup functional port properties to dynamically
  %% inherited.
  block.SetPreCompInpPortInfoToDynamic;
  block.SetPreCompOutPortInfoToDynamic;

  block.InputPort(1).Complexity   = 'Real'; 
  block.InputPort(1).DataTypeId   = 0;
  block.InputPort(1).SamplingMode = 'Sample';
  block.InputPort(1).Dimensions   = 1;
  block.InputPort(1).DirectFeedthrough = 1;
  
  block.InputPort(2).Complexity   = 'Real';
  block.InputPort(2).DataTypeId   = 0;
  block.InputPort(2).SamplingMode = 'Sample';
  block.InputPort(2).Dimensions   = 1;
  block.InputPort(1).DirectFeedthrough = 1;
  
  block.InputPort(3).Complexity   = 'Real';
  block.InputPort(3).DataTypeId   = 0;
  block.InputPort(3).SamplingMode = 'Sample';
  block.InputPort(3).Dimensions   = [4 4];
  block.InputPort(1).DirectFeedthrough = 1;
  
  block.InputPort(4).Complexity   = 'Real';
  block.InputPort(4).DataTypeId   = 0;
  block.InputPort(4).SamplingMode = 'Sample';
  block.InputPort(4).Dimensions   = [4 3];
  block.InputPort(1).DirectFeedthrough = 1;
  
  block.OutputPort(1).Complexity   = 'Real';
  block.OutputPort(1).DataTypeId   = 0;
  block.OutputPort(1).SamplingMode = 'Sample';
  block.OutputPort(1).Dimensions   = 4;

  block.OutputPort(2).Complexity   = 'Real';
  block.OutputPort(2).DataTypeId   = 0;
  block.OutputPort(2).SamplingMode = 'Sample';
  block.OutputPort(2).Dimensions   = 1;
  
  %% Set the block simStateCompliance to default (i.e., same as a built-in block)
  block.SimStateCompliance = 'DefaultSimState';

  %% Register methods
  %block.RegBlockMethod('CheckParameters',         @CheckPrms);
  %block.RegBlockMethod('ProcessParameters',       @ProcessPrms);
  block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
  block.RegBlockMethod('Start',                   @Start);  
  block.RegBlockMethod('WriteRTW',                @WriteRTW);
  block.RegBlockMethod('Outputs',                 @Outputs);
  
  %% Block runs on TLC in accelerator mode.
  block.SetAccelRunOnTLC(true);
  
%endfunction

% function CheckPrms(block)
%   mu = block.DialogPrm(1).Data;
%   
%   if mu <= 0 || mu > 1
%     error(message('simdemos:adapt_lms:stepSize'));
%   end
  
%endfunction

function DoPostPropSetup(block)

  %% Setup Dwork  
  N = 4;                    %% Filter length   
  block.NumDworks = 2;
  block.Dwork(1).Name = 'Amat'; %% state matrix
  block.Dwork(1).Dimensions      = N; %N*N
  block.Dwork(1).DatatypeID      = 0;
  block.Dwork(1).Complexity      = 'Real';
  block.Dwork(1).UsedAsDiscState = true;
  
  block.Dwork(2).Name = 'Bmat'; %% input matrix
  block.Dwork(2).Dimensions      = N;
  block.Dwork(2).DatatypeID      = 0;
  block.Dwork(2).Complexity      = 'Real';
  block.Dwork(2).UsedAsDiscState = true;

  block.Dwork(2).Name = 'SS'; %% 
  block.Dwork(2).Dimensions      = N;
  block.Dwork(2).DatatypeID      = 0;
  block.Dwork(2).Complexity      = 'Real';
  block.Dwork(2).UsedAsDiscState = true;
  %% Register all tunable parameters as runtime parameters.
  %block.AutoRegRuntimePrms;

%endfunction

% function ProcessPrms(block)
% 
%   block.AutoUpdateRuntimePrms;
%  
%endfunction

function Start(block)
  
  %% Initialize Dwork 
  block.Dwork(1).Data = zeros(N, 1);
  block.Dwork(2).Data = zeros(1, 32);
  block.Dwork(3).Data = zeros(1, 32);
%endfunction

function Outputs(block)
  
  mu = block.RuntimePrm(1).Data;
  N  = 32;
  
  u = block.InputPort(2).Data;
  d = block.InputPort(1).Data;
  t = block.InputPort(3).Data;
  
  X = block.Dwork(1).Data;
  H = block.Dwork(2).Data;
  
  %%
  %% H^(n+1)[i] = H^(n)[i]+mu*(d(n)-y(n))*u(n-i) 
  %% 
  X(2:N) = X(1:N-1);
  X(1)   = u;  
  y      = X'*H;  
  e      = d-y;  
  H      = H+mu*e*X;

  block.Dwork(1).Data = X;
  block.Dwork(2).Data = H;
  block.OutputPort(1).Data = y;

  %% Outputs the difference between the estimated filter coefficients
  %% and the actual coefficients.
  b = evalin('base','b'); %% b is the actual filter coefficients
  block.OutputPort(2).Data = norm(b'-H);
  
%endfunction

function WriteRTW(block)
  
  b = evalin('base','b');
  block.WriteRTWParam('matrix', 'ActualCoefs', b);

%endfunction