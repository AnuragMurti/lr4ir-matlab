function train(model, dataset)
  % Assuming model is 'PSO' and dataset is 'TD2003':
  % 1) call 'validate_PSO.m' with the validation set;
  % 2) save the return value of 'validate_PSO.m' in 'PSO/TD2003/parameters-fold{1-5}.txt';
  % 3) call 'train_PSO.m' with:
  %    i) the return value of the previous call to 'validate_PSO.m',
  %    ii) a handle of the fitness function for the training dataset;
  % 4) save the weight vector returned by 'train_PSO.m' in
  %    'PSO/TD2003/weights-fold{1-5}.txt'.

  addpath(model);

  rootdir = sprintf('%s/%s', model, dataset);
  if ~isdir(rootdir)
    mkdir(rootdir);
  end

  for fold = 1:5
      weights_file = sprintf('%s/weights-fold%d.txt', rootdir, fold);

      if ~(exist(weights_file, 'file') == 2)
          trainingset = csvread(sprintf('%s/Fold%d/trainingset.csv', dataset, fold));
          validationset = csvread(sprintf('%s/Fold%d/validationset.csv', dataset, fold));

          validate = str2func(sprintf('validate_%s', model));
          train = str2func(sprintf('train_%s', model));

          parameters = validate(validationset);
          fid = fopen(sprintf('%s/parameters-fold%d.txt', rootdir, fold), 'w');
          fprintf(fid, '%f\n', parameters);
          fclose(fid);

          fitness = fitness_handle(trainingset);
          datadir = sprintf('%s/data-fold%d', rootdir, fold);
          if isdir(datadir)
              rmdir(datadir, 's');
          end
          mkdir(datadir);
          weights = train(datadir, parameters, fitness);
          fid = fopen(weights_file, 'w');
          fprintf(fid, '%f\n', weights);
          fclose(fid);
      end
  end
end

