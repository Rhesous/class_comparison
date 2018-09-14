# Macros for class description

Characterize a dataset by distribution of modalities (or mean) for qualitatives variables (or quantitatives) with respect to one class variable. This macros can give usefull insights, but can be improved.


## How to use ?

Once run, two functions are added.
The functions have the same parameters, which are :
- myDb - dataframe: No default value, name of your database.
- target - string: No default value, name of the class variable.
- varX - list: NULL by default, name of the variables on which you want to perform the analysis.
- keep.all - boolean: False by default, whether you want to keep some extra informations.
- Threshold - float: 0 by default, higher bound in the p-values for results. If 0, no filtering is applied.

Then call the macro with your database
For instance, with R :

## Example

For R, you can run this with the Aids database:

```{r}
library(MASS)
data(Aids2)

var_quali(Aids2,"status", varX = c("state", "sex","T.categ"))
```

The head of the output is :

| status | variable | value | PctIntra    | PctTot      | PctMod    | vTest      | Prob         | vStars |
|--------|----------|-------|-------------|-------------|-----------|------------|--------------|--------|
| A      | sex      | M     | 0.966728281 | 0.968695040 | 0.3798112 | -0.4719512 | 3.184808e-01 | \|      |
| A      | sex      | F     | 0.033271719 | 0.031304960 | 0.4044944 | 0.4719512  | 3.184808e-01 | \|      |
| A      | state    | QLD   | 0.072088725 | 0.079493493 | 0.3451327 | -1.1438741 | 1.263379e-01 | \|      |

The most important columns are
- 1st column (name of target): the class studied 
- variable: the variable studied on the line
- value: the value taken by the variable for this line
- Prob: the probability of having the same distribution between global and this class

The vStars is just a visualization, it goes from * to ****, with the pipe that gives the signe, either the value is over representend (\|*) or under represented (*\|).

For quantitatives data :
```{r}  
var_quanti(Aids2,"sex", varX = c("age"))
```
The results are quite similar :

| status | variable | group.average | group.n | overall.average | vTest     | Prob        | vStars |
|--------|----------|---------------|---------|-----------------|-----------|-------------|--------|
| A      | age      | 36.78373      | 1082    | 37.40907        | -2.596714 | 0.004706012 | ***\|   |
| D      | age      | 37.79330      | 1761    | 37.40907        | 2.596714  | 0.004706012 | \|***   |

Here we can see that the group average is lower than global average for people alive, and higher for the deceased.
Hence, the vStars show that the average age for the alive is significantly lower, and significantly higher for the other.
