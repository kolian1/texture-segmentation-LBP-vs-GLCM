function momentC = centralMoment( x, nMoment )
if numel(x) ~= length(x)
    x = x(:);
end
momentC = mean(x);
if (nMoment>1)    
        x = x - momentC; % DC = 0.
        momentC = mean(x.^nMoment);
end

end

