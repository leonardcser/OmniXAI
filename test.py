import json
import os
import pprint
import sklearn
from devai.explainers.tabular.agnostic.shap2 import Shap2Tabular
import xgboost
import numpy as np
import pandas as pd
from omnixai.data.tabular import Tabular
from omnixai.preprocessing.tabular import TabularTransform

pp = pprint.PrettyPrinter(indent=4)

feature_names = [
    "Age", "Workclass", "fnlwgt", "Education",
    "Education-Num", "Marital Status", "Occupation",
    "Relationship", "Race", "Sex", "Capital Gain",
    "Capital Loss", "Hours per week", "Country", "label"
]
data = np.genfromtxt(os.path.join('./data', 'adult.data'), delimiter=', ', dtype=str)
tabular_data = Tabular(
    data,
    feature_columns=feature_names,
    categorical_columns=[feature_names[i] for i in [1, 3, 5, 6, 7, 8, 9, 13]],
    target_column='label'
)
pp.pprint(tabular_data)

np.random.seed(1)
transformer = TabularTransform().fit(tabular_data)
class_names = transformer.class_names
x = transformer.transform(tabular_data)
train, test, labels_train, labels_test = \
    sklearn.model_selection.train_test_split(x[:, :-1], x[:, -1], train_size=0.80)
pp.pprint('Training data shape: {}'.format(train.shape))
pp.pprint('Test data shape:     {}'.format(test.shape))

gbtree = xgboost.XGBClassifier(n_estimators=300, max_depth=5)
gbtree.fit(train, labels_train)
pp.pprint('Test accuracy: {}'.format(
    sklearn.metrics.accuracy_score(labels_test, gbtree.predict(test))))

predict_function=lambda z: gbtree.predict_proba(transformer.transform(z))


explainer = Shap2Tabular(
    training_data=tabular_data,
    predict_function=predict_function,
    nsamples=100
)
# Apply an inverse transform, i.e., converting the numpy array back to `Tabular`
test_instances = transformer.invert(test)
test_x = test_instances[1653:1655]

explanations = explainer.explain(test_x)
pp.pprint(explanations)

fig = explanations.plot()
fig.savefig("explanations.png")