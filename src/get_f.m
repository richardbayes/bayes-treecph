function [f_final,marg_y,Omegainv] =  get_f(ns,a,b,Z,tau,l,nugget,eps)
    if(size(Z,1) < size(Z,2))
        error('Z must be a column vector');
    end
    K = length(Z);
    % Get ML estimmmmate to start newton's algorithm
    fhat = log(ns) - log(a + b);
    ind = isfinite(fhat);
    %sum(ind)
    f_interp = interp1(Z(ind),fhat(ind),Z(~ind));
    fhat(~ind) = f_interp;
    
    %Sigma_exp = ;
    Sigma = tau^2 * exp(-(1/(2*l^2)) * squareform(pdist(Z,'squaredeuclidean')) ) + diag(ones(1,K)*nugget);
    %Sigmainv = 1/(tau^2) * inv(Sigma_exp);
    Sigmainv = inv(Sigma);
    
    
    f = fhat; % Initial value for Newton's method
    ok = 0;
    cntr = 0;
    cntr_max = 100;
    while(~ok)
       thehess = get_hess(f,a,b,Sigmainv);
       thegrad = get_grad(f,a,b,Sigmainv,ns);
       fnew = f - thehess \ thegrad;
       if (sum(abs(fnew - f)) < eps) || (cntr == cntr_max)
           ok = 1;
           f_final = fnew;
       end
       if cntr == cntr_max
           disp('Maximum number of iterations reached in Newtons method');
       end
       f = fnew;
       cntr = cntr + 1;
    end
    if nargout == 1
        return;
    else
        g0val = sum(ns .* f_final) - sum(exp(f_final) .* (a + b)) - ...
            .5* f_final' * (Sigma \ f_final);
        Omegainv = -get_hess(f_final,a,b,Sigmainv);
        marg_y = -.5*ldet(Omegainv) + g0val - .5 * ldet(Sigma);
    end
end