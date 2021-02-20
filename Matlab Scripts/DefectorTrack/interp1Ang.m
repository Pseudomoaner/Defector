function vq = interp1Ang(x,v,xq,method,angMin,angMax)
%INTERP1ANG performs 1D interpolation using interp1, but applies
%wrap-around to account for circularity of the response variable.
%
%   INPUTS:
%       -x: Points where input variable has been sampled (e.g. timepoints)
%       -v: Corresponding values of response variable 
%       -xq: Desired points for interpolation
%       -method: String defining the method for interpolation. Can be any
%       used by the interp1 function.
%       -angMin: Minimal value of the circular response variable
%       -angMax: Maximal value of the circular response variable
%
%   OUTPUTS:
%       -vq: Interpolated values of the response variable at the desired
%       sampling points
%
%   Author: Oliver J. Meacock, (c) 2021

%Select default method
if isempty(method)
    method = 'linear';
end

%Map response variable data linearly to range -pi:pi, then unwrap
v = (((v-angMin)/(angMax-angMin))*2*pi)-pi;
vUnwrap = unwrap(v);

%Apply linear interpolation to unwrapped data
vqUnwrap = interp1(x,vUnwrap,xq,method);

%And wrap output response variable back to original, circular domain
vqCirc = wrapToPi(vqUnwrap);
vq = (((vqCirc + pi)/(2*pi))*(angMax-angMin))+angMin;