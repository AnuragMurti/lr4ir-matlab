function [gbest, gbestCost] = PSO(datadir, f, D, xbnd, xinitbnd, maxFEvals, popsize)
    % Implementation of standard PSO 2007 with lbest topology based on
    % https://www.researchgate.net/publication/248072531_Source_code_for_an_implementation_of_Standard_Particle_Swarm_Optimization

    % PSO parameters -- D. Bratton and J. Kennedy, "Defining a standard 
    % for particle swarm optimization", IEEE SIS, 2007, pp. 120-127.
    chi = 0.72984;
    c1 = 2.05 * chi;
    c2 = 2.05 * chi;

    % Search space boundaries
    xmin = -xbnd * ones(1,D);
    xmax = xbnd * ones(1,D);
    vmin = -xbnd * ones(1,D);
    vmax = xbnd * ones(1,D);

    % Random initial positions
    x = 2 * xinitbnd * rand(popsize,D) - xinitbnd;

    % Zero for initial velocity -- A. Engelbrecht, "Particle swarm
    % optimization: velocity initialization", IEEE CEC, 2012, pp. 70-77.
    v = zeros(popsize,D);

    % Initialize personal best positions as initial positions
    pbest = x;
    pbestCosts = reshape(f(x), 1, popsize);
    fEvals = length(pbestCosts);
    [gbestCost, gbestIndex] = max(pbestCosts);
    gbest = pbest(gbestIndex,:);

    % Update lbest
    [lbest] = updateLBest(pbest, pbestCosts);

    while fEvals < maxFEvals
        % Update velocity (c1 and c2 already multiplied by chi)
        v = chi*v + c1*rand(popsize,D).*(pbest-x) + c2*rand(popsize,D).*(lbest-x);

        % Clamp veloctiy 
        oneForViolation = v < repmat(vmin,popsize,1);
        v = (1-oneForViolation).*v + oneForViolation.*repmat(vmin,popsize,1);
        oneForViolation = v > repmat(vmax,popsize,1); 
        v = (1-oneForViolation).*v + oneForViolation.*repmat(vmax,popsize,1);

        % Update position 
        x = x + v;

        % Reflect-Z for particles out of bounds -- S. Helwig, J. Branke, 
        % and S. Mostaghim, "Experimental Analysis of Bound Handling 
        % Techniques in Particle Swarm Optimization", IEEE TEC, 17(2), 
        % 2013, pp. 259-271.

        % Reflect lower bound
        relectionAmount = repmat(xmin,popsize,1) - x;
        oneForNeedReflection = relectionAmount > zeros(popsize,D);
        relectionAmount = (1-oneForNeedReflection).*zeros(popsize,D) + oneForNeedReflection.*relectionAmount;
        % Clamp first
        x = (1-oneForNeedReflection).*x + oneForNeedReflection.*repmat(xmin,popsize,1);
        % then reflect
        x = x + relectionAmount;
        % Set velocity for reflected particles to zero
        v = (1-oneForNeedReflection).*v + oneForNeedReflection.*zeros(popsize,D);

        % Reflect upper bound
        relectionAmount = repmat(xmax,popsize,1) - x;
        oneForNeedReflection = relectionAmount < zeros(popsize,D);
        relectionAmount = (1-oneForNeedReflection).*zeros(popsize,D) + oneForNeedReflection.*relectionAmount;
        % Clamp first
        x = (1-oneForNeedReflection).*x + oneForNeedReflection.*repmat(xmax,popsize,1);
        % then reflect
        x = x + relectionAmount;
        % Set velocity for reflected particles to zero
        v = (1-oneForNeedReflection).*v + oneForNeedReflection.*zeros(popsize,D);

        % Evaluate the new positions
        newCosts = reshape(f(x), 1, popsize);
        fEvals = fEvals + length(x);

        % Update pbest
        for index = 1:popsize
            if newCosts(index) > pbestCosts(index)
                pbest(index,:) = x(index,:);
                pbestCosts(index) = newCosts(index);
            end
        end

        % Update lbest and gbest
        [lbest] = updateLBest(pbest, pbestCosts);
        [gbestCost, gbestIndex] = max(pbestCosts);
        gbest = pbest(gbestIndex,:);
    end

    gbest = reshape(gbest, D, 1);
end

function [lbest] = updateLBest(pbest, pbestCosts)

    popsize = size(pbest, 1);

    % Particle 1 is neighbours with particle n=popsize
    neighbourhoodCosts(1,1) = pbestCosts(1, popsize);
    neighbourhoodCosts(1,2:3) = pbestCosts(1, 1:2);
    [unused, index] = max(neighbourhoodCosts);
    if index == 1
        lbest(1,:) = pbest(popsize,:);
    else
        lbest(1,:) = pbest(index-1,:);
    end

    for i = 2:popsize-1
        neighbourhoodCosts(1, 1:3) = pbestCosts(1, i-1:i+1);
        [unused, index] = max(neighbourhoodCosts);
        lbest(i,:) = pbest(i+index-2,:);
    end

    % Particle n=popsize is neighbours with particle 1
    neighbourhoodCosts(1,1:2) = pbestCosts(1, popsize-1:popsize);
    neighbourhoodCosts(1,3) = pbestCosts(1, 1);
    [unused, index] = max(neighbourhoodCosts);
    if index == 3
        lbest(popsize,:) = pbest(1,:);
    else
        lbest(popsize,:) = pbest(popsize-2+index,:);
    end
end

