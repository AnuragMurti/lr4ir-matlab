#!/usr/bin/env python

# Run Eval-Score.pl for all folds and compile the output files in a CSV

import sys
import subprocess


def calculate_measures(model, dataset, objfun):
    base_args = ('perl', 'Eval-Score.pl')
    for fold in xrange(1, 6):
        feature_file = '%s/Fold%d/testset.txt' % (dataset, fold)
        prediction_file = '%s/%s-%s/scores-fold%d.txt' % (model, dataset, objfun, fold)
        measure_file = '%s/%s-%s/measures-fold%d.txt' % (model, dataset, objfun, fold)
        flag = '0'
        args = base_args + (feature_file, prediction_file, measure_file, flag)
        subprocess.call(args)


def summarize_measures(model, dataset, objfun):
    MAP = []
    P = [[] for x in range(10)]
    NDCG = [[] for x in range(10)]
    for fold in xrange(1, 6):
        measure_file = '%s/%s-%s/measures-fold%d.txt' % (model, dataset, objfun, fold)
        with open(measure_file) as f:
            for line in (l.strip() for l in f):
                if line.startswith('precision:'):
                    line = line[11:]
                    parts = line.split()
                    for i in xrange(10):
                        P[i].append(float(parts[i]))
                elif line.startswith('MAP:'):
                    line = line[5:]
                    MAP.append(float(line))
                elif line.startswith('NDCG:'):
                    line = line[6:]
                    parts = line.split()
                    for i in xrange(10):
                        NDCG[i].append(float(parts[i]))
    summary_file = '%s/%s-%s/measures.csv' % (model, dataset, objfun)
    with open(summary_file, 'w') as f:
        f.write('MAP,%f\n' % (sum(MAP) / 5.0))
        for i in xrange(10):
            f.write('P@%d,%f\n' % (i + 1, sum(P[i]) / 5.0))
        for i in xrange(10):
            f.write('NDCG@%d,%f\n' % (i + 1, sum(NDCG[i]) / 5.0))


def main(model, dataset, objfun):
    calculate_measures(model, dataset, objfun)
    summarize_measures(model, dataset, objfun)


if __name__ == '__main__':
    if len(sys.argv) == 4:
        main(sys.argv[1], sys.argv[2], sys.argv[3])
        sys.exit(0)
    else:
        print >> sys.stderr, 'Eval-Score.py <model> <dataset> <objfun>'
        sys.exit(1)

