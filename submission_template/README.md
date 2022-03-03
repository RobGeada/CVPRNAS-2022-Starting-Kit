# CVPR-NAS 2022 Submission Template

## Writing your Submission
For a valid submission, there are a number of functions with this template that need to be implemented. In the 
individual files within the template, the inputs and expected outputs are explained in more depth.

For a valid submission, you are asked to implement the following functions within the following classes:
* DataProcessor
  * `__init__()`: This function receives raw data in the form of numpy arrays for the train, valid, and test data, as well the dataset metadata 
  * `process()`: This function must output 3 PyTorch dataloaders for the train, valid, and test data splits
* NAS
  * `__init__()`: This function receives the dataloaders created by the DataProcessor, and the dataset metadata
  * `search()`: This function should search for an optimal architecture for this dataset, and should output a PyTorch model.
* Trainer
    * `__init__()`: This function receives the dataloaders created by the DataProcessor, and the model produced by the NAS class
    * `train()`: This function should fully train your model and return it
    * `predict(test_loader)`: This function should produce a list of predicted class labels over the test_dataloader

 In general, the evaluation script runs the following pipeline for each dataset:
 1. Raw Dataset -> `DataProcessor` -> Train, Valid, and Test dataloaders
 2. Train Dataloader + Valid Dataloaders -> `NAS` -> Model
 3. Model + Train Dataloader + Valid Dataloaders -> `TRAINER.train` -> Fully-trained model
 4. Fully-trained model + Test Dataloader -> `Trainer.predict=` -> Predictions
 
# General Information and Tips
## Datasets
Each of three datasets in the competition will be an n-class classification task over 4-d images of shape (NImages x Channels X Height x Width). Each dataset 
has a pre-divided splits for training, validation, and testing, each of which are labelled accordingly. Each class is equally represented in each split; for example, in a 5-class dataset, each split will be 20% class-0, 20% class-1, etc. 

Additionally, each datasets will contain a metadata dictionary, that contains the following information:
* `num_classes`: The total number of classes in the classification problem
* `input_shape`: The shape of the `train_x` data. All images in each split will have the same channel count, heigh, and width, but the different splits will have different numbers of images.
* `codename`: A unique codename for this dataset to refer to it throughout the competition.
* `benchmark`: The benchmark classification accuracy for this dataset. This is the score that our example submission achieved on the dataset, and is the mark necessary to score 0 points on this dataset. Accuracies above the benchmark will score more points, up to a total of 10 points for a perfect 100% test accuracy. Conversely, accuracies below the benchmark will score negative points, up to -10 at worst. 

## Designing your Pipeline
Each of three pipeline classes (`DataProcessor`, `NAS`, and `Trainer`) will receive the dataset metadata dictionary in their initialization. You can alter this however you want, in case you want to pass messages between your various classes. 

## Runtime
Your submission will have 24 hours total to run on our servers. That means it needs to perform the entire NAS pipeline, training, and test prediction for each of the three final datasets within 24 hours. If your submission exceeds this time, it will be instantly terminated and will receive no score. To help you keep aware of this, the evaluation pipeline will add a field to the metadata dictionary called `time_remaining`. This is an **estimate** of the remaining time your submission has in seconds. You can use this to early-stop your algorithm, tailor your training epochs, adjust your search algorithm, it's up to you. 
