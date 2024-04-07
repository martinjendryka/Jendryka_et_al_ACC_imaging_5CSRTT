function closestind = Findclosestval(N,M,method)
% N: indices for all strings
% M: single index number for which the closest index shall be founnd in N 
% method:
% -1: occurs after
% 1: occurs before
% 0: nearest
distancefromval = N - M;
if isequal(method,1)
    distancefromval(distancefromval > 0) = -Inf;
    [~, closestind] = max(distancefromval);
elseif isequal(method,-1)
    distancefromval(distancefromval < 0) = Inf;
    [~, closestind] = min(distancefromval);
else
    [~, closestind] = min(abs(distancefromval));
end