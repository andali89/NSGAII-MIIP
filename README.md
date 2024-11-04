
This is the Matlab code of a feature selection algorithm called NSGAII-MIIP. This algorithm is designed for selecting key process features in complex manufacturing processes.

# Requirements
- This code requres the [weka.jar](lib/Weka-3-7/weka.jar) package. [Weka](https://www.cs.waikato.ac.nz/ml/weka/) is a Machine Learning Software in Java.
- The data in in Weka format (.arff). If you need to use data with other formats, please convert it to Weka format.

# To run the code
- Please click on [main.m](nsga2miip/main.m) in the folder `nsga2miip` for an example to run the algorithm.

# Introduction of the code
- The code of main procedure of NSGAII-MIIP is in the `NSGAIIMIIP.m` file.
- To select the ideal point method, use `perfectpoint.m` file.
