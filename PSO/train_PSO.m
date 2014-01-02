function weights = train_PSO(datadir, parameters, fitness)
  D = 44;
  xbnd = 1;
  xinitbnd = 1;
  popsize = 100;
  maxFEvals = 10000;

  rand('state', sum(100 * clock));
  [weights, MAP] = PSO(restartdir, fitness, D, xbnd, xinitbnd, maxFEvals, popsize);
end

