function [x, fval] = DE(datadir, f, D, xbnd, xinitbnd, maxFEvals, Np, F, Cr)
  % Implementation of DE/rand/1/bin

  pop = 2 * xinitbnd * rand(Np,D) - xinitbnd;
  fPop = f(pop);
  fEvals = length(fPop);
  trials = zeros(Np, D);

  while fEvals < maxFEvals
      for target = 1:Np
          % Select distinct base, r1 y r2 from Pop \ target
          base = target;
          while base == target
              base = ceil(rand() * Np);
          end
          r1 = target;
          while r1 == target || r1 == base
              r1 = ceil(rand() * Np);
          end
          r2 = target;
          while r2 == target || r2 == base || r2 == r1
              r2 = ceil(rand() * Np);
          end

          % Generate the trial vector
          mutated = pop(base,:) + F*(pop(r1,:) - pop(r2,:));
          for i = 1:D
              if rand() <= Cr
                  trials(target,i) = mutated(i);
              else
                  trials(target,i) = pop(target,i);
              end
          end
          % Ensure trials(target,:) gets at least one component from mutate
          i = ceil(rand() * D);
          trials(target,i) = mutated(i);
      end

      % Clamping
      trials = min(max(trials, -xbnd), xbnd);

      % Substitute target with trial if equal or better
      fTrials = f(trials);
      fEvals = fEvals + length(fTrials);
      for target = 1:Np
          if fTrials(target) >= fPop(target)
              fPop(target) = fTrials(target);
              pop(target,:) = trials(target,:);
          end
      end
  end

  [fval, xindex] = max(fPop);
  x = pop(xindex,:);
end

