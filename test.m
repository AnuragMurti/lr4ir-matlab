function test(model, dataset)
  % Assuming model is 'PSO' and dataset is 'TD2003':
  % 1) read 'PSO/TD2003/weights-fold{1-5}.txt' -- weight vector;
  % 1) calculate the scores for the documents in the testset;
  % 2) write 'PSO/TD2003/scores-fold{1-5}.txt' -- scores for each testset.

  rootdir = sprintf('%s/%s-%s', model, dataset);

  for fold = 1:5
      testset = csvread(sprintf('%s/Fold%d/testset.csv', dataset, fold));
      weights = importdata(sprintf('%s/weights-fold%d.txt', rootdir, fold));

      model_scores = testset(:,4:47) * weights;
      fid = fopen(sprintf('%s/scores-fold%d.txt', rootdir, fold), 'w');
      fprintf(fid, '%f\n', model_scores);
      fclose(fid);
  end
end

