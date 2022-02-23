import json
import numpy as np
import pickle as pkl
import os
import sentry_sdk

from sklearn.metrics import accuracy_score

if __name__ == '__main__':

    sentry_sdk.init(
        "https://038f39e3bc2a46fabc02b955d6c319e8@o1080315.ingest.sentry.io/6227751",
        # Set traces_sample_rate to 1.0 to capture 100%
        # of transactions for performance monitoring.
        # We recommend adjusting this value in production.
        traces_sample_rate=1.0
    )

    # print main header
    print("=" * 75)
    print("="*13 + "    Your CVPR-NAS 2022 Submission is scoring     " + "="*13)
    print("="*75)

    # iterate through datasets
    total_score = 0
    overall_stats = {}
    for dataset in os.listdir("labels"):
        print("== Scoring {} ==".format(dataset))

        # load user predictions from file
        data_path = 'labels/'+dataset
        labels = np.load(os.path.join(data_path, 'test_y.npy'))
        with open(os.path.join(data_path, 'metadata'), "r") as f:
            metadata = json.load(f)
        prediction_file = [prediction for prediction in os.listdir('predictions')
                      if metadata['codename'] == prediction.replace(".npy", "")][0]
        predictions = np.load('predictions/'+prediction_file)
        with open("predictions/{}_stats.pkl".format(metadata['codename']), "rb") as f:
            run_stats = pkl.load(f)

        # produce accuracy score of predictions
        labels = labels[:len(predictions)]

        # normalize score
        raw_score = 100*accuracy_score(labels, predictions)
        benchmark = metadata['benchmark']

        scaling_factor = 10/(100 - benchmark)
        adj_score = (raw_score - benchmark) * scaling_factor
        adj_score = max(-10, adj_score)
        total_score += adj_score

        print("Raw Score:    {:.3f}".format(raw_score))
        print("Adj Score:    {:.3f}".format(adj_score))
        print("Model Params: {:,}".format(run_stats['Params']))
        print("Runtime:      {:,.1f}s".format(run_stats['Runtime']))
        run_stats['Raw_Score'] = float(np.round(raw_score, 3))
        run_stats['Adj_Score'] = float(np.round(adj_score, 3))

        # save overall results
        overall_stats.update({"{}_{}".format(metadata['codename'], k): v for k,v in run_stats.items()})

    print("===========================")
    print("Final Score: {:.3f}".format(total_score))
    overall_stats['Final_Score'] = total_score
    with open("final_results.json", "w") as f:
        json.dump(overall_stats, f)
