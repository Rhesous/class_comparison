import pandas as pd
import numpy as np
from scipy.stats import norm

def var_quanti(myDb, target, varX=None,keep_all=False,threshold=0):
    if (varX == None):
        varX = myDb.select_dtypes(include=[np.number]).columns.tolist()
        # varX = [c for c in varX if len(myDb[c].unique())<20]
    varX = list(set(varX) - set([target]))

    melted = pd.melt(myDb, id_vars=target, value_vars=varX)
    melted = melted.assign(N_=1)

    melted['group_average'] = melted.groupby([target, "variable"])['value'].transform(np.mean)
    melted['group_N'] = melted.groupby([target, "variable"])['N_'].transform(sum)
    melted['overall_average'] = melted.groupby(["variable"])['value'].transform(np.mean)
    melted['overall_N'] = melted.groupby(["variable"])['N_'].transform(sum)
    melted['overall_std'] = melted.groupby(["variable"])['value'].transform(np.std)
    melted.drop('value',axis=1,inplace=True)
    melted.drop_duplicates(inplace=True)
    myDb = melted.reset_index(drop=True)

    # Computing vTest
    myDb['vTest'] = ((myDb['group_average'] - myDb['overall_average']) / (
            np.sqrt(
                ((myDb['overall_N'] - myDb['group_N']) / ((myDb['overall_N'] - 1) * (myDb['group_N'])))) *
            myDb['overall_std']))

    # Computing Prob
    myDb['Prob'] = 1 - norm.cdf(abs(myDb['vTest']))

    # displaying stars
    myDb['vStars'] = pd.cut(myDb['vTest'],
                            bins=[-np.float("Inf"), -5, -2.31, -1.64, -1.28, 1.28, 1.64, 2.31, 5, np.float('Inf')],
                            labels=["****|", "***|", "**|", "*|", "|", "|*", "|**", "|***", "|****"])

    # Filtering on probability
    if (threshold > 0):
        myDb[abs(myDb['Prob']) < threshold]

    myDb.sort_values([target, 'vTest'])

    # Dropping useless
    if (keep_all):
        myDb.drop(['overall_N', 'overall_std'], axis=1, inplace=True)

    return myDb


def var_quali(myDb, target, varX=None,keep_all=False,threshold=0):
    if (varX == None):
        varX = db.select_dtypes(exclude=[np.number]).columns.tolist()
        # varX = [c for c in varX if len(myDb[c].unique())<20]
    varX = list(set(varX) - set([target]))

    melted = pd.melt(myDb, id_vars=target, value_vars=varX)
    melted = melted.assign(N_=1)

    # Basic numbers
    ## Count number of policies per modality
    melted['nkj'] = melted.groupby([target, "variable", "value"])['N_'].transform(sum)
    ## Count number of policies per target value
    melted['nk_'] = melted.groupby([target, "variable"])['N_'].transform(sum)
    ## Count number of policies per variable modality
    melted['n_j'] = melted.groupby(["variable", "value"])['N_'].transform(sum)
    ## Count total number of policies
    melted['n'] = melted.groupby(["variable"])['N_'].transform(sum)

    # Frequencies for Chi-2
    melted["PctIntra"] = melted['nkj'] / melted['nk_']
    melted["PctTot"] = melted['n_j'] / melted['n']
    melted["PctMod"] = melted['nkj'] / melted['n_j']
    melted["vTest"] = (melted['nkj'] - melted['n_j'] / melted['n'] * melted['nk_']) / np.sqrt(
        (melted['n_j'] / melted['n'] * melted['nk_'] *
         (melted['n'] - melted['nk_']) / (melted['n'] - 1)) * (1 - melted['n_j'] / melted['n'])
    )
    myDb = melted.drop_duplicates().copy()
    # Indicators :
    # Computing Prob
    myDb['Prob'] = 1 - norm.cdf(abs(myDb['vTest']))

    # displaying stars
    myDb['vStars'] = pd.cut(myDb['vTest'],
                            bins=[-np.float("Inf"), -5, -2.31, -1.64, -1.28, 1.28, 1.64, 2.31, 5, np.float('Inf')],
                            labels=["****|", "***|", "**|", "*|", "|", "|*", "|**", "|***", "|****"])

    # Filter on prob
    if (threshold != 0):
        myDb = myDb[abs(Prob) < threshold]

    # Sorting
    myDb = myDb.sort_values([target, 'variable', 'vTest'])
    if (keep_all == False):
        myDb = myDb.drop(["nkj", "nk_", "n_j", "n"], axis=1)
    return myDb

