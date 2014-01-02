function weights = train_DE(datadir, parameters, fitness)
  D = 44;
  xbnd = 1;
  xinitbnd = 1;
  Np = 50;
  F = 0.5;
  Cr = 0.5;
  maxFEvals = 10000;

  rand('state', sum(100 * clock));
  [weights, MAP] = DE(restartdir, fitness, D, xbnd, xinitbnd, maxFEvals, Np, F, Cr);
end

