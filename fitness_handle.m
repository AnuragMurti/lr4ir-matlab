function handle = fitness_handle(trainingset)
  % Returns a handle of the fitness function for the given training set (MAP)
  handle = @(W) MAP_all(W, trainingset);
end


function M = MAP_all(W, trainingset)
  M = NaN(size(W, 1), 1);
  for i = 1:size(W, 1)
      M(i) = MAP_single(W(i,:), trainingset);
  end
end


function m = MAP_single(w, trainingset)
  % Mean Average Precision (MAP)
  qids = unique(trainingset(:,1));
  APs = zeros(length(qids),1);
  for i = 1:length(qids)
      qid_docs = trainingset(:,1) == qids(i);
      model_scores = trainingset(qid_docs,4:47) * w';
      [ignore, model_ranks] = sort(model_scores, 'descend');
      APs(i) = AP(trainingset(qid_docs,3), model_ranks);
  end
  m = sum(APs) / length(qids);
end


function AP = AP(gold_standard, model_ranks)
  % Average Precision (AP)
  if sum(gold_standard) > 0
      i = 1;
      P_k = zeros(1, sum(gold_standard));
      for k = 1:find(gold_standard(model_ranks), 1, 'last')
          if gold_standard(model_ranks(k))
            P_k(i) = P_n(gold_standard, model_ranks, k);
            i = i + 1;
          end
      end
      AP = sum(P_k) / sum(gold_standard);
  else
      AP = 0;
  end
end


function P_n = P_n(gold_standard, model_ranks, n)
  % Precision at position n (P@n)
  P_n = sum(gold_standard(model_ranks(1:n))) / n;
end

