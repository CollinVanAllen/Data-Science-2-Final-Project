# Data-Science-2-Final-Project  
This project is the culmination of the topics and content studied in my Data Science 2 class at UW-Platteville in Fall of 2022. This project uses a dataset called AVONET found in [this study][avo-link], with the main data used in this project being found [here][data-link]. The main data focused on is a single sheet from the supplemental dataset 1 found in this dataset.  

## Goal of the Project  
The goal of this project was to use a large dataset and perform dimensionality reduction methods as well as machine learning methods learned within the class for a classification task. The subject of this dataset is morphological features found in roughly 10,000 species of birds. The measurements range from bone measurements to wingspan measurements, and lifestyle and niche data. The main classification done in this project was to see if any given model could predict the niche of a bird using k-nearest neighbors, the family of the bird, and using PCA to find the best measurements of a bird. The project was also extended into my free time to see if the application of a catboost model would be beneficial to predict the order of birds.  

## Skills Usaed:
- Data Cleaning
- Exploratory Data Analysis
- Dimensionality Reduction and Feature Selection
- Machine Learning Algorithms  

## Basic Exploratory Data Analysis  
My main goal during the exploratory data analysis phase was to explor the categorical data to see which features might be the best to predict on. Given the wide range of values found within the primary niche of the birds I decided I would use that with the k-nearest neighbors model. Similarly I used the large number of families found in birds to try using a decision tree.  

![niche](https://github.com/cvanallen/Data-Science-2-Final-Project/assets/100979971/6d0c1dd6-cf70-46df-8acf-b9ccca27d59f)  
<br>

## Machine Learning  
### kNN Model  
Using a collection of morphological features found in the dataset, primarily quantitative values, I used a k-nearest neighbors model to try and predict the primary niche. In the first model I used I attempted to test if the beak measurements alone would be enough to predict the niche of a bird. Through multiple iterations of cross validation I found that the model was not sufficient in predicting niche with the beak measurements alone.  

![knn](https://github.com/cvanallen/Data-Science-2-Final-Project/assets/100979971/a5a1f91e-3dbe-474d-87c7-a14d4968738f)  
<br>

After running the first model I proceeded to add in some variables related to bone measurements of the birds as well as the wingspan of the birds. After multiple iterations of cross validation again I found that this model did a much better job at predicting the niche of the birds. When comparing the two methods it is clear to see that the addition of more features improved the classification power of k-nearest neighbors.  

![knn2](https://github.com/cvanallen/Data-Science-2-Final-Project/assets/100979971/0fc9f10e-3042-4e25-ab64-9ea0b2732b50)  
<br>
![knncompare](https://github.com/cvanallen/Data-Science-2-Final-Project/assets/100979971/d1cabaf8-1372-47fa-981c-4618629fec19)  
<br>

### Decision Tree
After running the k-nearest neighbors methods, I decided to try and use a decision tree to try and predict the family of the birds within the dataset. For the first model I used the measurements of the bird to try and predict the family and overall it did poorly. Similarly the second model that had included habitat and lifestyle of the birds did poorly. The second model perform better than the first by roughly 0.2%. Overall the models were not good at classifying on the family of birds.  
<br>

Model 1
<br>
![tree1](https://github.com/cvanallen/Data-Science-2-Final-Project/assets/100979971/e63c0e79-ed7d-4d68-8269-b24ad073417e)
<br>

Model 2
<br>
![tree2](https://github.com/cvanallen/Data-Science-2-Final-Project/assets/100979971/afc2ae0c-a7c1-49a0-a178-1c009dea99df)
<br>

### catboost Model
As an additional side project after being introduced to the catboost model in early 2023, I decided to try and apply it to the dataset to see its effectiveness in predicting the order of the bird. The model was very successful overall with a high accuracy of nearly 97%. This was by far the best model I had tested the dataset with as all other models did a poor job at predicting multiple of the categorical features.  

## Dimensionality Reduction  
A section of our course was dedicated to dimensionality reduction so I figured I would do a portion of my project on it. The goal was to see how well the variables were at predicting the niche and family as done in the previous machine learning models. Given the 2 PCA tests done on the two calssifier variables, it is clear to see that the variables themselves do a good job at predicting their respective variables of either niche or family. This leads me to believe that there are other models that could be used to predict them.  

PCA for Trophic Niche
<br>
![screeniche](https://github.com/cvanallen/Data-Science-2-Final-Project/assets/100979971/9d98231a-9a50-4158-95f8-8dabe9c1d7df)
<br>

PCA for Family
<br>
![screefamily](https://github.com/cvanallen/Data-Science-2-Final-Project/assets/100979971/1fd11205-e14e-417d-88a5-913ea0de6230)
<br>

## Conclusions
Overall I think this project was a success in testing the content I learned within the Data Science 2 class. I think there is more work to be done with the machine learning models and their predictive capabilities. Additonally I believe there may be more to look at within the dataset and I may visit it in the future. I also plan in the future to see if the morphological features can be used to create an accurate hierarchical tree of the birds when compared to an actual evolutionary systematics tree.



[avo-link]: https://onlinelibrary.wiley.com/doi/full/10.1111/ele.13898
[data-link]: https://figshare.com/s/b990722d72a26b5bfead
