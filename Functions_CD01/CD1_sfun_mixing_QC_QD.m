function [sys,x0,str,ts] = CD1_sfun_mixing_QC_QD(t,x,u,flag,n_comp,tstep,Cmcl)

% Combination of 2 elements
% In/Output in Q and Concentrations (m3/s, g/m3) as vector  
% sample time: tstep
% vector	Q=1  C= 1..n_comp


switch flag,
  case 0,
    [sys,x0,str,ts] = mdlInitializeSizes(n_comp,tstep);
  case 3,                                                
    sys = mdlOutputs(t,x,u,n_comp,tstep,Cmcl);
  case {1,2,4,9}  
    sys = []; % do nothing
  otherwise
    error(['unhandled flag = ',num2str(flag)]);
end


%=======================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=======================================================================
function [sys,x0,str,ts] = mdlInitializeSizes(n_comp,tstep)

sizes = simsizes;
sizes.NumContStates  = 0;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 2.*(n_comp+1);
sizes.NumInputs      = 2*(n_comp+1);
sizes.DirFeedthrough = 1;
sizes.NumSampleTimes = 1;

sys = simsizes(sizes);

x0  = [];
str = [];
ts  = [tstep 0]; 


%=======================================================================
% mdlOutputs
% Return Return the output vector for the S-function
%=======================================================================
function sys = mdlOutputs(t,x,u,n_comp,tstep,Cmcl)

sys(1) = u(1)+u(n_comp+2);
for i=1:n_comp
   if sys(1)>0
      sys(i+1)=(u(i+1)*u(1)+u(i+n_comp+2)*u(n_comp+2))/sys(1);
   else
      sys(i+1)=0;
   end
   %Flow required for each substance 
   if sys(i+1)>Cmcl(i)
       a=u(1)*(Cmcl(i)-u(i+1))+u(n_comp+2)*(Cmcl(i)-u(2+n_comp+i));
       b=u(2+n_comp+i)-Cmcl(i);
       sys(i+n_comp+1)=a/b;     
   else
       sys(i+n_comp+1)=0;       
   end
   
end

sys((n_comp+1).*2)=max(sys((n_comp+2):(2.*n_comp+1)));