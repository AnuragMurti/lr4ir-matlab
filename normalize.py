#!/usr/bin/env python

# Normalize the features in the TD200{3,4} LETOR2.0 datasets

import os
import sys
import fileinput


def parse_line(line):
    parts = line.strip().split()
    label = int(parts[0])
    qid = int(parts[1].split(':')[-1])
    features = []
    for i in xrange(2, 46):
        features.append(float(parts[i].split(':')[-1]))
    docid = int(parts[-1])
    return qid, docid, label, features 


def calculate_extrema(dataset):
    print >> sys.stderr, 'Calculating extrema for %s...' % dataset,
    minima, maxima = {}, {}
    data_file = os.path.join(dataset, 'All', '%s.txt' % dataset)
    for line in open(data_file):
        qid, docid, label, features = parse_line(line)
        if qid not in minima:
            minima[qid] = {}
            maxima[qid] = {}
        for i in xrange(44):
            minima[qid][i] = min(minima[qid][i], features[i]) if i in minima[qid] else features[i]
            maxima[qid][i] = max(maxima[qid][i], features[i]) if i in maxima[qid] else features[i]
    print >> sys.stderr,  'DONE.'
    return minima, maxima


def normalize_folds(dataset, minima, maxima):
    for fold in xrange(1, 6):
        for subset in ('test', 'training', 'validation'):
            input_file = os.path.join(dataset, 'Fold%d' % fold, '%sset.txt' % subset)
            print >> sys.stderr, 'Normalizing %s...' % input_file,
            output_file = os.path.join(dataset, 'Fold%d' % fold, '%sset.csv' % subset)
            output = open(output_file, 'w')
            for input_line in open(input_file):
                qid, docid, label, features = parse_line(input_line)
                output_line = '%s,%s,%s' % (qid, docid, label)
                for i in xrange(44):
                    if maxima[qid][i] != minima[qid][i]:
                        normalized_feature = (features[i] - minima[qid][i]) / (maxima[qid][i] - minima[qid][i])
                    else:
                        normalized_feature = 0
                    output_line += ',%.6e' % normalized_feature
                output.write('%s\n' % output_line)
            output.close()
            print >> sys.stderr,  'DONE.'


def main():
    for dataset in ('TD2003', 'TD2004'):
        minima, maxima = calculate_extrema(dataset)
        normalize_folds(dataset, minima, maxima)


if __name__ == '__main__':
    main()

